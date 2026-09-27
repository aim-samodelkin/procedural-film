#!/usr/bin/env python3
"""check-join.py : check that join.sh kept the sound in sync with the picture (reference/series.md).

Lives at the root of the film folder next to join.sh. For each part it takes 1 s of audio from the
middle of the part's master NN-*/exports/<FILM>-partN.mp4 and finds that spot in exports/<FILM>-full.mp4
by cross-correlation. The offset must be 0 ms (tolerance +-2 ms); the search window catches drifts up to
+-100 ms; a positive offset means the sound comes late, a negative one early.
Exits 1 if any part is off. Needs ffmpeg, ffprobe and numpy.

    FILM=my-film python3 check-join.py      # or: python3 check-join.py my-film
"""
import glob, os, re, subprocess, sys
import numpy as np

os.chdir(os.path.dirname(os.path.abspath(__file__)))
FILM = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('FILM', 'film')  # prefix of the part masters, as in join.sh
FFMPEG = os.environ.get('FFMPEG', 'ffmpeg')
FFPROBE = os.environ.get('FFPROBE', 'ffprobe')
FULL = f'exports/{FILM}-full.mp4'
SR = 48000
PROBE = 1.0      # seconds of audio taken from the middle of each part
SEARCH = 0.1     # seconds searched on each side of the expected position
TOL_MS = 2


def pcm(f, ss, d):
    out = subprocess.run([FFMPEG, '-v', 'error', '-ss', str(ss), '-t', str(d), '-i', f,
                          '-ac', '1', '-ar', str(SR), '-f', 'f32le', '-'], capture_output=True, check=True).stdout
    return np.frombuffer(out, dtype=np.float32)


def dur(f):
    return float(subprocess.run([FFPROBE, '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=duration',
                                 '-of', 'csv=p=0', f], capture_output=True, text=True, check=True).stdout)


if not os.path.exists(FULL):
    sys.exit(f'no joined film {FULL}; run join.sh first (and check FILM={FILM})')
start, bad, parts = 0.0, 0, 0
for d in sorted(glob.glob('[0-9][0-9]-*/')):
    n = int(re.match(r'(\d+)', d).group(1))
    f = f'{d}exports/{FILM}-part{n}.mp4'
    if not os.path.exists(f):
        break
    D = dur(f)
    mid = round(D / 2, 3)
    a = pcm(f, mid - PROBE / 2, PROBE)
    b = pcm(FULL, start + mid - PROBE / 2 - SEARCH, PROBE + 2 * SEARCH)
    if not a.any():
        print(f'part {n}: silent in the middle, skipped')
    else:
        lag = int(np.argmax(np.correlate(b, a, 'valid')))
        ms = (lag / SR - SEARCH) * 1000
        ok = abs(ms) <= TOL_MS
        bad += not ok
        print(f'part {n}: starts at {start:.3f} s, audio offset {ms:+.1f} ms {"ok" if ok else "OFF"}')
    start += D
    parts += 1
if parts == 0:
    sys.exit(f'no part masters NN-*/exports/{FILM}-partN.mp4 found')
print(f'sum of parts {start:.3f} s, joined video {dur(FULL):.3f} s')
sys.exit(1 if bad else 0)
