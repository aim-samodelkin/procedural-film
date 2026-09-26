# Series: a film made of parts

How to make a long film as several parts, each its own project and its own session, that join into one video without visible seams. Read it at the brief when the user says the film has (or may get) more parts, and again before storyboarding any part after the first.

## Why parts

A long film does not fit one agent's context: the scene files, lib and music of one part are already thousands of lines. Each part is its own project folder, rendered on its own, and the parts are joined at the end. What carries the continuity between sessions is not the code but two documents: the film's **series document** and each part's **passport**.

## Layout: one folder for the whole film

Keep every part inside one film folder, with one document for the whole film at its root:

```
<film-slug>/
  FILM.md               the series document (templates/series-FILM.md)
  join.sh               joins the finished parts into one video (templates/join.sh)
  exports/              the joined film
  01-<part-slug>/       part 1: a full project (src/, tools/, docs/, exports/) with its PART.md
  02-<part-slug>/       part 2
  ...
```

- **`FILM.md` at the root** holds what is true for every part: the parts table (number, subject, folder, length, series clock, status), the locked series decisions, the seam rule as code, how to join the film and the checklist for a new part. A fresh session reads it first.
- **`PART.md` in each part** is that part's passport, from `templates/FILM.md`: its shots, the helpers it added to `src/lib.js`, its own decisions, both of its seams as exact code, its commands and history. It points back to `../FILM.md` and does not repeat the series decisions.
- **Part folders are numbered** `NN-<slug>` so the folder order is the film order, and each part renders its master under one agreed name (for example `exports/<film>-partN.mp4`), which `join.sh` picks up in folder order.

When a single film grows into a series, move it into this layout: the film's folder becomes `01-<slug>/`, its `FILM.md` becomes `PART.md`, and the series decisions move up into the new root `FILM.md`.

## Part 1 decides for the whole series

The first part fixes, and the series `FILM.md` records as locked:

- frame, fps, safe area;
- bpm, key, chord loop and the instrument voices;
- plates, palette, recurring layout (headers, progress devices, cards);
- reading rhythm — how long a finished frame holds;
- the **length unit**: every part's duration is a whole multiple of the background's loop period (if the background repeats every 8 beats, a multiple of 8 beats). Then the background is in the same phase at every seam.

Later parts copy part 1's folder without its scenes and exports, keep `src/lib.js` and `src/music.js`, and port any shared fix back to every part that uses the file.

## The seam: last frame of part N = first frame of part N+1

Design the end of every part as a **clean seam frame**: no must-read text, only the continuous background and the recurring devices (a header, a progress marker that hands off). A seam frame that still shows the part's text forces the next part to redraw that text.

1. **Series clock.** Everything that moves by global time — backgrounds, drifting elements, noise — reads `T + FILM.TIMELINE.clock`, where `clock` is the total length of the earlier parts. Part N+1's frame 0 then continues part N's last frame by exactly one frame. Beat-locked pulses need no offset when every part is a whole number of beats.
2. **Reproducible end state.** Express the last frame as helper calls with fixed arguments (the background helper with its options, plus the state of every recurring device) and write that code into the part's `PART.md`; write the general rule (what the recurring devices show at the end of part N) into the series `FILM.md`. Part N+1's first shot starts from exactly that call.
3. **Still for comparison.** Save the last frame to `docs/last-frame.jpg`. The seam check snaps part N at its last frame and part N+1 at `T 0` and compares them: everything matches except one frame of motion.
4. **Audio.** End part N on a sustained chord with the drums silent and name its notes in `PART.md`. Part N+1 opens on the same chord and notes for at least a bar, then brings in its groove. Join with a short audio crossfade (20 ms) so the output fades of the two renders do not click (`templates/join.sh` does this for every seam of the film):

   ```bash
   ffmpeg -i part1.mp4 -i part2.mp4 -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0[v];[0:a][1:a]acrossfade=d=0.02[a]" -map "[v]" -map "[a]" film.mp4
   ```

5. **Hand-off device.** Let one element of the seam frame point at what comes next — the next item's marker lighting up, a shape that the next part opens from. Part N+1's first shot grows out of it, so the join reads as one move.

## When the seam cannot match

Sometimes the next part needs a different plate, layout or tempo, or part N is already rendered without a clean seam. Then invent a transition and bake it into the **start of part N+1**: the core's `transitionIn` works only between shots inside one film, never across two renders.

- Part N+1's first shot redraws part N's last frame exactly (from its `FILM.md` seam code and `docs/last-frame.jpg`) and transforms it: a flash to white, an iris or a wipe into the new plate, a push-in through the hand-off element, a dissolve of the old background into the new one.
- Keep the transition on the beat grid of the new part and start it on a downbeat.
- For a tempo change, end part N on a held chord without a pulse and start part N+1 with its new pulse after the transition.
- Record the transition in both parts' `PART.md`.

## Checklist for every part after the first

- [ ] Read the series `FILM.md`, then the previous part's `PART.md` and its seam.
- [ ] Copy the previous part's folder to the next `NN-<slug>/` without scenes, exports and renders; set `clock` in the timeline from the parts table; start its `PART.md`.
- [ ] Agree the brief and the storyboard with the user; the first shot starts from the seam.
- [ ] Keep the locked decisions; ask before changing any.
- [ ] Design the part's end as the next seam frame and write it into its `PART.md`.
- [ ] Snap and compare both sides of the seam (they should differ no more than two neighbouring frames that change grain); run `join.sh`.
- [ ] Update the parts table in the series `FILM.md`: status, length, and the next part's `clock`.
