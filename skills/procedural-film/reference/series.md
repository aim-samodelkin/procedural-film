# Series: a film made of parts

How to make a long film as several parts, each its own project and its own session, that join into one video without visible seams. Read it at the brief when the user says the film has (or may get) more parts, and again before storyboarding any part after the first.

## Why parts

A long film does not fit one agent's context: the scene files, lib and music of one part are already thousands of lines. Each part is its own project folder, rendered on its own, and the parts are joined at the end. What carries the continuity between sessions is not the code but the **passport**, `FILM.md` (template in `templates/FILM.md`): the locked decisions, the file map and the exact seam.

## Part 1 decides for the whole series

The first part fixes, and its `FILM.md` records as locked:

- frame, fps, safe area;
- bpm, key, chord loop and the instrument voices;
- plates, palette, recurring layout (headers, progress devices, cards);
- reading rhythm — how long a finished frame holds;
- the **length unit**: every part's duration is a whole multiple of the background's loop period (for a scrolling floor that repeats every beat and props every 8 beats, a multiple of 8 beats). Then the background is in the same phase at every seam.

Later parts copy part 1's folder without its scenes and exports, keep `src/lib.js` and `src/music.js`, and port any shared fix back to every part that uses the file.

## The seam: last frame of part N = first frame of part N+1

Design the end of every part as a **clean seam frame**: no must-read text, only the continuous background and the recurring devices (a header, a progress dot that hands off). A seam frame that still shows the part's text forces the next part to redraw that text.

1. **Series clock.** Everything that moves by global time — backgrounds, props, stars, noise — reads `T + FILM.TIMELINE.clock`, where `clock` is the total length of the earlier parts. Part N+1's frame 0 then continues part N's last frame by exactly one frame. Beat-locked pulses need no offset when every part is a whole number of beats.
2. **Reproducible end state.** Express the last frame as helper calls with fixed arguments (for example `swBack(ctx, T, { dim: 0.25 })` plus a header state) and write that code into `FILM.md`. Part N+1's first shot starts from exactly that call.
3. **Still for comparison.** Save the last frame to `docs/last-frame.jpg`. The seam check snaps part N at its last frame and part N+1 at `T 0` and compares them: everything matches except one frame of motion.
4. **Audio.** End part N on a sustained chord with the drums silent and name its notes in `FILM.md`. Part N+1 opens on the same chord and notes for at least a bar, then brings in its groove. Join with a short audio crossfade (20 ms) so the output fades of the two renders do not click:

   ```bash
   ffmpeg -i part1.mp4 -i part2.mp4 -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0[v];[0:a][1:a]acrossfade=d=0.02[a]" -map "[v]" -map "[a]" film.mp4
   ```

5. **Hand-off device.** Let one element of the seam frame point at what comes next — the next item's dot glowing, a shape that the next part opens from. Part N+1's first shot grows out of it, so the join reads as one move.

## When the seam cannot match

Sometimes the next part needs a different plate, layout or tempo, or part N is already rendered without a clean seam. Then invent a transition and bake it into the **start of part N+1**: the core's `transitionIn` works only between shots inside one film, never across two renders.

- Part N+1's first shot redraws part N's last frame exactly (from its `FILM.md` seam code and `docs/last-frame.jpg`) and transforms it: a flash to white, an iris or a wipe into the new plate, a push-in through the hand-off element, a dissolve of the old background into the new one.
- Keep the transition on the beat grid of the new part and start it on a downbeat.
- For a tempo change, end part N on a held chord without a pulse and start part N+1 with its new pulse after the transition.
- Record the transition in both passports.

## Checklist for every part after the first

- [ ] Read the series passport (part 1's `FILM.md`) and the previous part's seam.
- [ ] Copy the previous part's folder without scenes, exports and renders; set `clock` in the timeline.
- [ ] Agree the brief and the storyboard with the user; the first shot starts from the seam.
- [ ] Keep the locked decisions; ask before changing any.
- [ ] Design the part's end as the next seam frame and write it into the new passport.
- [ ] Snap and compare both sides of the seam; join with the crossfade command.
- [ ] Update the series table in part 1's passport.
