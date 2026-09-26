#!/usr/bin/env bash
# join.sh : join a film made of parts (reference/series.md). Lives at the root of the film folder.
# Takes NN-*/exports/<FILM>-partN.mp4 in folder order and stops at the first part without a master.
# Video joins cut to cut, audio with a 20 ms crossfade on every seam.
# Writes exports/<FILM>-full.mp4 (crf 18), -phone.mp4 (720 wide, crf 24) and -light.mp4 (540 wide, crf 28),
# the transcodes normalised to -14 LUFS. Set FILM to the film's slug (the masters' prefix).
set -euo pipefail
cd "$(dirname "$0")"
FFMPEG="${FFMPEG:-ffmpeg}"
FILM="${FILM:-film}"   # set to the prefix of the part masters, e.g. FILM=my-film
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
for i in "${!inputs[@]}"; do
  args+=(-i "${inputs[$i]}")
  vin+="[$i:v]"
done
filter="${vin}concat=n=${count}:v=1:a=0[v]"
if (( count == 1 )); then
  filter+=";[0:a]anull[a]"
else
  prev="[0:a]"
  for ((i = 1; i < count; i++)); do
    out="[a$i]"
    (( i == count - 1 )) && out="[a]"
    filter+=";${prev}[$i:a]acrossfade=d=0.02${out}"
    prev="[a$i]"
  done
fi
mkdir -p exports
"$FFMPEG" -loglevel error -y "${args[@]}" -filter_complex "$filter" -map "[v]" -map "[a]" \
  -c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p -c:a aac -b:a 192k exports/${FILM}-full.mp4
"$FFMPEG" -loglevel error -y -i exports/${FILM}-full.mp4 -vf scale=720:1280 -c:v libx264 -crf 24 -preset medium \
  -af loudnorm=I=-14:TP=-1.5:LRA=11 -c:a aac -b:a 128k exports/${FILM}-full-phone.mp4
"$FFMPEG" -loglevel error -y -i exports/${FILM}-full.mp4 -vf scale=540:960 -c:v libx264 -crf 28 -preset medium \
  -af loudnorm=I=-14:TP=-1.5:LRA=11 -c:a aac -b:a 128k exports/${FILM}-full-light.mp4
ls -la exports/${FILM}-full*.mp4
