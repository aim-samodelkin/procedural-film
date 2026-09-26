# Film passport: <FILM TITLE>

Read this file first. Open only the files it points to. Do not read `src/lib.js` or `src/music.js` whole: the places that matter are named below with line numbers.

Updated: <date>, after <step or part>.

*This is the handoff document. The next agent — a fresh session, a resumed one, or the agent making the next part of a series — starts here instead of re-reading the whole project. Keep it short, current and specific: numbers, names, paths. Update it at the end of every pipeline step and before every session ends. Rewrite stale lines; do not append a diary.*

## What this is

*One paragraph: the subject, the source material (a document, a brief), the audience and where the film will be shown (phone feed or a screen), the mode.*

*If the film is one part of a series, the series table:*

| Part | What | Folder | Length | Status |
|---|---|---|---|---|
| 1 | *…* | *path* | *s* | *done / in progress / not started* |

## Locked decisions

*Everything the user chose or approved that the next agent must not change without asking: frame and safe area, bpm and key, the chosen instrument voices, palette and plates, recurring layout (header, cards, captions), the reading rhythm (how long a finished frame holds), text rules, the length unit of a part. One line each, with the reason when it is not obvious.*

## File map

| File | What is in it | Read? |
|---|---|---|
| `FILM.md` | this passport | yes, first |
| `src/timeline.js` | length, shots, on-screen texts, cues | yes |
| `docs/storyboard.md` | *…* | *by section* |
| `src/lib.js` | engine + this film's additions (below) | *only the named functions* |
| `src/music.js` | engine + score (below) | *only the score* |
| `docs/last-frame.jpg` | the final frame, for the seam | *when working on the seam* |

*Mark stale documents explicitly ("stale, do not read") rather than leaving the next agent to discover it.*

### Additions to `src/lib.js`

*Function, approximate line, signature, one line of purpose. Shared helpers every scene calls (backgrounds, headers, cards) go here, so no agent has to search for them.*

### Additions to `src/music.js`

*New instruments, the chord table, the section/arrangement table, how score() finds its sections.*

## Commands

*The exact commands for gate, snaps, audio check, render, transcodes and build, with anything project-specific (delivery sizes, loudness, upload limits).*

## Shots

| # | Id | Time, s | What |
|---|---|---|---|

## Seam

*The exact state of the last frame (what is visible, alphas, which element carries the hand-off) and of the audio at the end (chord, held notes, what is silent). The code that reproduces it as the next part's first frame. The series clock offset. How to check the seam and how to join the parts. See the skill's `reference/series.md`.*

## Next

*What the next session does first, the plan for the next part, and what must be agreed with the user before work starts.*

## Decision log

*Short: what changed and why, so the next agent does not undo a deliberate choice.*
