#!/usr/bin/env bash
# join.sh : join a film made of parts (reference/series.md). Lives at the root of the film folder.
# Takes NN-*/exports/<FILM>-partN.mp4 in folder order and stops at the first part without a master.
# Video joins cut to cut. Audio keeps sync: each part's audio is trimmed or padded with silence to the exact
# length of its video, fades out and in over 10 ms at every seam, and the parts are concatenated with no overlap.
# (A crossfade overlaps the two sides and eats its length: every later part's sound starts that much early,
# and the drift adds up seam by seam.) Check the result with check-join.py.
# Writes exports/<FILM>-full.mp4 (crf 18), -phone.mp4 (720 wide, crf 24) and -light.mp4 (540 wide, crf 28),
# the transcodes normalised to -14 LUFS. Set FILM to the film's slug (the masters' prefix).
set -euo pipefail
cd "$(dirname "$0")"
FFMPEG="${FFMPEG:-ffmpeg}"
FFPROBE="${FFPROBE:-ffprobe}"
FILM="${FILM:-film}"   # set to the prefix of the part masters, e.g. FILM=my-film
FADE=0.01              # fade out and in at each seam, seconds; long enough to avoid a click, too short to hear
inputs=()
for dir in [0-9][0-9]-*/; do
  nn="${dir%%-*}"
  n=$((10#$nn))
  f="${dir}exports/${FILM}-part${n}.mp4"
  if [[ ! -f "$f" ]]; then
    echo "part $n: no master $f; joining the parts before it"
    break
  fi
  inputs+=("$f")
done
count=${#inputs[@]}
if (( count == 0 )); then echo "no part masters found"; exit 1; fi
echo "joining $count part(s)"
args=()
vin=""
ain=""
filter=""
for i in "${!inputs[@]}"; do
  args+=(-i "${inputs[$i]}")
  vin+="[$i:v]"
  # the part's exact length is its video duration; its audio is trimmed or padded to that length
  d=$("$FFPROBE" -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 "${inputs[$i]}")
  chain="[$i:a]atrim=0:${d},asetpts=PTS-STARTPTS,apad=whole_dur=${d}"
  (( i > 0 )) && chain+=",afade=t=in:d=${FADE}"
  (( i < count - 1 )) && chain+=",afade=t=out:st=$(awk "BEGIN{print $d - $FADE}"):d=${FADE}"
  filter+="${chain}[a$i];"
  ain+="[a$i]"
done
filter+="${vin}concat=n=${count}:v=1:a=0[v];${ain}concat=n=${count}:v=0:a=1[a]"
mkdir -p exports
"$FFMPEG" -loglevel error -y "${args[@]}" -filter_complex "$filter" -map "[v]" -map "[a]" \
  -c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p -c:a aac -b:a 192k exports/${FILM}-full.mp4
"$FFMPEG" -loglevel error -y -i exports/${FILM}-full.mp4 -vf scale=720:-2 -c:v libx264 -crf 24 -preset medium \
  -af loudnorm=I=-14:TP=-1.5:LRA=11 -c:a aac -b:a 128k exports/${FILM}-full-phone.mp4
"$FFMPEG" -loglevel error -y -i exports/${FILM}-full.mp4 -vf scale=540:-2 -c:v libx264 -crf 28 -preset medium \
  -af loudnorm=I=-14:TP=-1.5:LRA=11 -c:a aac -b:a 128k exports/${FILM}-full-light.mp4
ls -la exports/${FILM}-full*.mp4
