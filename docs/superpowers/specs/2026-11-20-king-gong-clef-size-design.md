# King Gong (Godot): a smaller clef and key signature, each on its line

Short design. Project: `godot-implementations/king-gong/`. Written 2026-11-20 for a later
session.

## Why

The clef and the key signature are pinned to the left of the screen while the level scrolls
behind them. They are drawn at full notation size for a staff whose space is 72 px, a tenth
of the window's height, so they take up a lot of it. With 7 sharps the key signature runs
from x 258 to about x 690 (in a 1280 px wide window). The camera keeps the gorilla 30% in, at
x 384, so it hangs in among the signs, and the branches pass behind them.

The user compared screenshots of one moment of a song, with 7 sharps and with 7 flats, in
both clefs. They saw the signs at 100, 70, 60, 50 and 40%, the clef full size or shrinking
with them, and the gorilla at 0.3, 0.4 and 0.5 of the width. They picked:

- **the signs at 40%,**
- **the clef at 40% too,**
- **the gorilla where it is, at 0.3.**

The treble clef also sits a little low today (Design notes). The clefs are placed by hand,
so this change places them in code, on their lines.

## Goals

- **One size for both.** The clef and the key signature are drawn at 40% of today's size.
  The 40% comes from one constant, so it can be tuned later.
- **The clef sits on its line.** Each clef is placed in code from the line it names, the way
  the key signature already is:
  - **Treble:** the centre of the curl on the G line (G4, `Staff.y_of(4)`).
  - **Bass:** the head on the F line (F3, `Staff.y_of(8)` in the bass clef), with the two
    dots in the spaces just above and below it.
- **Each sign stays on its line or space,** as today: the sharp's middle, and the flat's stem
  level with the middle of its bowl (`art/CREDITS.md`). The gap from one sign to the next
  shrinks by the same factor.
- **Left to right:**
  - The clef's left edge stays about where it is, at x 7 to 13.
  - The key signature follows the clef with today's gap, shrunk by the same factor.
  - In the preview the user picked from, the first sign's left edge was at about x 108 in
    the treble clef and x 102 in the bass clef, and 7 signs ended by about x 270. That is
    well clear of the gorilla at x 384.
- **Crisp at any window size.** The project stretches (`canvas_items`). The smaller signs and
  clef must look clean both at 1280×720 and full screen: no jagged edges, no shimmer.

## Non-goals

- The gorilla's place on screen. `_camera_x()` in `game.gd` keeps 0.3.
- The staff itself: `Staff.STEP`, the staff-line bushes, the branches.
- The signs on branches (macaw, bat, blossom).
- The chord logs' little staff and its sharps and flats.
- New clef art. The clefs stay font glyphs.
- The menus.

## Approaches

- **Hand-tune the new sizes.** Lower the two font sizes in `main.tscn` to 40%, move the
  Labels by eye, and shrink the signs. This is the smallest change. But every later size
  change means tuning by eye again, and the treble clef's place stays a guess.
- **Place the clefs in code from an anchor point (chosen; my call).** The signs already work
  this way, with `SHARP_CORNER` and `FLAT_CORNER`. Each clef gets the point in its glyph that
  goes on its line, as a fraction of the font size. The code sets the font size from the
  scale and puts that point on the line. One constant changes the size, and everything stays
  on its lines.
- **Draw the clefs as SVGs** like `sharp.svg` and `flat.svg`, with the origin on the line.
  This is the most exact, and it doesn't depend on the font. But it needs clef art, and under
  the project's asset rule that means a search for a human-made CC0 or public-domain set
  first. Left out for now. It is the next step if the font's glyph turns out to differ
  between machines.

## Design notes

- **Where things are today:**
  - **The clefs** are two Labels under the `Clef` Parallax2D in `main.tscn`. `Treble` is at
    offset (7.2, −71.4) with font size 468, and `Bass` is at (13.3, −36.7) with font size 330.
    Their font is a SystemFont: Segoe UI Symbol, then Noto Music, then serif.
  - **`game.gd` `restart()`** shows one of the clefs and calls
    `$Clef/KeySignature.show_key(fifths, clef)`.
  - **`scripts/key_signature.gd`** places the signs. `AFTER_CLEF` (258 in the treble clef,
    236 in the bass clef) is the first sign's left edge.
- **What I measured,** by drawing the staff lines over a screenshot:
  - **The bass clef is right.** The head is on the F line and the dots straddle it. In the
    Label, the F line is at y ≈ 210 at font size 330, which is 0.64 of the font size.
  - **The treble clef is low.** The centre of its curl is about a third to half a space
    (roughly 25 to 35 px) below the G line at font size 468. This was judged by eye: measure
    it again.
- **The preview the user picked from:**
  - It scaled each Label around one point: the Label's left edge across, and the clef's line
    down.
  - It moved the key signature's left edge to
    `clef_left + (AFTER_CLEF − clef_left) × 0.4`.
  - Matching both gives the look the user picked. The treble clef's anchor fix moves the
    clef up slightly from what they saw, which is intended.
- **Keeping it crisp:**
  - A Sprite2D scaled to 0.4 without mipmaps aliases.
  - Rasterising the SVG at 0.4 (`svg/scale` in its `.import` file) would blur when the window
    is larger than 1280×720.
  - Mipmaps with a mipmap filter, or rasterising at a scale that covers full screen, both
    work.
  - For the Labels, a smaller `font_size` keeps the glyph sharp, while scaling the Label
    doesn't.
- **Builder's calls:**
  - whether clef placement goes into `key_signature.gd` or into a new script next to it
  - how the textures stay crisp
  - the exact gap after the clef
  - how the anchor points are measured
  - node and constant names

## Check

- **Unchanged results:** every existing `--autoplay` run gives the same results as before.
- **New in the dev bot (`scripts/dev_autoplay.gd`):** once a level with a key signature is
  built, the bot checks that the key signature's right edge is left of the gorilla's place on
  screen (30% of the width). It prints `key: <n> sharps, clear of the gorilla` (or `flats`).
  With no key signature it prints `key: none`.
- **Screenshots for the user,** with `--autoplay --shots=<dir>`:
  - Mary's Lamb in D (`--song=6`, 2 sharps) and Für Elise in F minor (`--song=9`, 4 flats).
  - Each one in the treble clef and again with `--bass`.
  - The user judges whether the clefs sit on their lines.
- **README:**
  - In "Key signatures." under Differences from the spike, say that the clef and key
    signature are drawn small, at 40%, so they stay clear of the gorilla.
  - Add any new script to the file map.
