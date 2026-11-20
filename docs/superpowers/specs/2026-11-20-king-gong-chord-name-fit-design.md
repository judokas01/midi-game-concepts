# King Gong (Godot): long chord names fit their sign, centred

Short design. Project: `godot-implementations/king-gong/`. Written 2026-11-20 for a later
session.

## Why

Each chord log carries a board with the chord's name on it. A long name, such as A#dim,
Ebmaj7 or F#m7, runs off the right side of the board and sits right of centre. Short names
(C, Am, G7, C#m) are fine.

The code already means to shrink a long name to fit: `setup()` in `scripts/chord_log.gd`
scales the Name label down by the label's width over the text's width (`# "Cmaj7" shrinks to
fit the board`). The shrink itself is right. A layout change one frame later undoes it.

**What happens (measured).** A throwaway probe ran `setup()` headless for a few names and
measured where the text is drawn, in the sign's own pixels, right after `setup()` and again a
frame later. The board's light face runs from x −45 to 45, its dark edge to ±48.

| Name   | Width at 40 px | Scale | Drawn at setup | Drawn a frame later | Right of centre |
|--------|---------------:|------:|----------------|---------------------|----------------:|
| C#m    |             85 |  1.00 | −42.5 .. 42.5  | the same            |               0 |
| F#m7   |            104 |  0.85 | −44 .. 44      | −38.9 .. 49.1       |             5.1 |
| A#dim  |            125 |  0.70 | −44 .. 44      | −32.4 .. 55.6       |            11.6 |
| Ebmaj7 |            139 |  0.63 | −44 .. 44      | −29.1 .. 58.9       |            14.9 |

**Why it happens.**

- The Name label is 92 px wide (offsets −46 to 46).
- A text wider than that raises the label's minimum width. Godot applies the new minimum a
  frame later (deferred) and grows the label to the text's width.
- The label grows to the right only, because `grow_horizontal` is the default, End.
- `setup()` has already taken `scale` and `pivot_offset` from the 92 px size. So the centred
  text moves right by `scale × (text width − 92) / 2`, and its right end passes the board.

Every name wider than 92 px at font size 40 is hit: every maj7, the dim and aug chords, and
most sevenths and minor chords on a sharp or flat root.

## Goals

- **Inside the face.** Every chord name sits inside the board's light face, at most 88 px
  wide. That is the width `setup()` aims for today.
- **Centred.** Each name sits in the middle of the board, across and down, within a pixel.
- **Short names unchanged.** A name that fits at full size keeps it. C, Am, G7 and C#m stay
  at font size 40.
- **Long names as big as fits.** A long name gets the largest font size at which it fits.
  Nothing else changes: same font, same colour, one line.
- **Crisp.** The name is drawn at the smaller font size, not as a 40 px Label scaled down.
  The clef spec found the same: a scaled Label goes soft, a smaller `font_size` stays sharp
  at any window size.

## Non-goals

- The board's size and art. It stays 100 × 74 (`art/chord_sign.svg`).
- Writing ♯ and ♭ instead of # and b.
- Chord-symbol style, with the quality smaller and raised (C with a small "maj7").
- The bass-clef sign, the computer key under the board, and the chord grid's buttons.

## Approaches

- **Fix the pivot, keep the scale.** The label grows from its centre (`grow_horizontal`
  Both), and the pivot comes from the text's width, not the stale 92 px. This is the
  smallest change. But the name is still drawn at 40 px and scaled down to as little as
  0.63, which is softer than the font drawn at that size.
- **Lower the font size instead (chosen; my call).** Find the largest whole font size at
  which the name is at most 88 px wide, and use it. The label then never grows past its
  92 px, so it stays centred where it is, and no scale or pivot is needed.
  - Catch: `LabelSettings_name` is one sub-resource shared by every log. Changing its
    `font_size` would change every sign on screen. Each log needs its own copy:
    `resource_local_to_scene` on the sub-resource, or a `duplicate()` in `setup()`.
- **A wider board for long names, or a smaller font for every name.** Both change signs that
  look right today. Left out.

## Design notes

- **Where things are today:**
  - **`scenes/chord_log.tscn`:**
    - `Top/Sign/Board` shows `art/chord_sign.svg`: 100 × 74, with a 90 × 64 light face.
    - `Top/Sign/Name` is a Label at offsets (−46, −34, 46, 34), centred both ways, with
      `LabelSettings_name`: bold Segoe UI, 40 px.
  - **`scripts/chord_log.gd` `setup()`,** lines 52–55, sets the text, measures it with
    `get_string_size`, then sets `pivot_offset` and `scale`. That code goes; the scale stays
    at 1.
- **The longest names** the game deals are Ebmaj7 (139 px at 40) and F#maj7 (137 px). The
  smallest size should land near 25 px.
- **Builder's calls:**
  - how each log gets its own LabelSettings
  - whether to step the size down from 40 or compute it and then check it
  - the 88 px target, if the face's edge looks tight

## Check

- **New in `scripts/dev_sign_check.gd`.** It already builds the sign for every chord in
  `Drill.all_chords()`. Add, with the name showing:
  - The drawn text lies within x −45 .. 45 of the board.
  - Its centre is within 1 px of the board's centre.
  - A name 88 px wide or less at 40 px keeps font size 40.
  - Run the same checks for the chords of the songs in `Song.library()`, which may be spelt
    differently.
  - **Measure a frame after `setup()`** (`await process_frame`). The bug only shows once the
    deferred layout has run; measured straight after `setup()`, today's code passes.
  - Failures print as `sign <chord>: …` like the rest of the script, which still ends
    `sign: ok`.
- **Unchanged results:** the rest of `dev_sign_check.gd` and the `--autoplay` runs give the
  same results as before. The full suite runs once, at the end.
- **A screenshot for the user:** `--autoplay --drill --shots=<dir>` deals every chord the
  grid offers. The user judges whether the smallest names (Ebmaj7, F#maj7) are still easy to
  read.
- **README:**
  - Under Chord drill, after the taller board for a seventh, say that a long name (Ebmaj7) is
    written smaller so it fits its board.
  - In the dev checks, the sign check's description adds that every name fits inside its
    board, centred.
