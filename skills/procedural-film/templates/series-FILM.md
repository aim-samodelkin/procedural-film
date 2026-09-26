# Film: <FILM TITLE>

The document for the whole film. Read it first, then the passport of the part you work on (`NN-<slug>/PART.md`). Do not read the parts' code whole.

Updated: <date>. Done: <which parts>.

*This file sits at the root of the film folder, above the part folders (`reference/series.md`, "Layout"). It holds only what is true for every part. Each part's own shots, helpers, seams and history live in its `PART.md`. Update the parts table every time a part changes status.*

## What this is

*One paragraph: the subject, the source material, the audience and where the film will be shown, the mode. Then: the film is N parts, each its own project in its own folder; the last frame of part N is the first frame of part N+1, so the parts join into one video without seams.*

## Folder layout

```
<film-slug>/
  FILM.md                this document
  join.sh                joins the finished parts into one video
  exports/               the joined film (not in git)
  01-<slug>/             part 1: PART.md, src/, docs/, tools/, exports/
  02-<slug>/             part 2
```

## Parts

| # | What | Source | Folder | Length | `clock` | Status |
|---|---|---|---|---|---|---|
| 1 | *…* | *page / section* | `01-<slug>/` | *s* | 0 | *done / in progress / not started* |
| 2 | *…* | | `02-<slug>/` | *s* | *length of part 1* | |

*`clock` of a part is the sum of the lengths of all parts before it. Fill in the next part's `clock` when the current part is done. Each part renders its master as `exports/<film>-partN.mp4`; `join.sh` picks it up by that name.*

## Series decisions

*Everything the user chose or approved for every part, one line each: frame, fps and safe area; bpm, key and chord loop; the instrument voices; palette, plates and the recurring layout (header, progress device, cards); how a part enters and leaves (the hand-off device); the reading rhythm; the length unit of a part; text rules. Change one only with the user's consent, and then in every part.*

## Seams

*The rule every seam follows, as code with the part number as a parameter: the background call with the series clock, the recurring devices' state on the last frame (which progress dot glows at the end of part N), and the sustained chord (notes) that ends one part and opens the next. How to check a seam: snap the last frame of part N and frame 0 of part N+1; they differ no more than two neighbouring frames of the same part. The exact code of each seam lives in the parts' `PART.md`.*

## Joining the film

```bash
./join.sh          # every finished part in folder order → exports/<film>-full.mp4, -phone.mp4, -light.mp4
```

*The script stops at the first part without a master. Video joins cut to cut, audio with a 20 ms crossfade on every seam. Say which transcode goes to the user and any upload limit.*

## A new part

1. Copy the previous part's folder to the next `NN-<slug>/` without `src/scenes/`, `exports/`, `.frames/`, `.tmp/`, `dist/`.
2. Set `clock` in its `src/timeline.js` from the parts table; start its `PART.md` from the previous part's.
3. Agree the brief and the storyboard with the user. The first shot starts from the previous seam; the last shot ends on the next seam.
4. Stubs, music, scenes, the gate, the master render under the agreed name.
5. Check both seams on snaps, run `join.sh`, update the parts table here.

## Shared code

*Each part has its own copies of `src/lib.js` and `src/music.js`. Say where each part adds its own helpers, and that a fix to a shared helper is ported to every part and those parts re-rendered.*
