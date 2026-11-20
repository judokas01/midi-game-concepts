# King Gong: a smaller clef and key signature, each on its line — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The clef and key signature are drawn at 40% of today's size, from one constant, each
clef placed in code on the line it names, crisp at any window size.

**Architecture:** A new `scripts/clef.gd` on the `Clef` Parallax2D sizes and places the clef
Labels from an anchor point per glyph (a fraction of the font size) and tells the key
signature where to start and how big to draw. `key_signature.gd` scales its signs and their
spacing; the sign textures get mipmaps and a mipmap filter.

**Tech Stack:** Godot 4.7.2, typed GDScript, `main.tscn`.

**Spec:** [clef size](../specs/2026-11-20-king-gong-clef-size-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`. Godot 4.7.2. No commits: the user commits.
- The signs and the clef at **40%**; the gorilla stays at 0.3 of the width (`_camera_x()`).
- Unchanged: `Staff.STEP`, the staff bushes, the branches, the branch signs, the chord logs'
  staff, the menus, the clef glyphs (Segoe UI Symbol, Noto Music, serif).
- Test runs: the rows this touches while building; the full suite once at the end.

## Measured (2026-11-20, Segoe UI Symbol, glyph rendered and scanned)

- Treble: the lower bowl (the curl) spans 0.767–1.083 of the font size below the Label's top;
  its middle, **0.925**, goes on the G line (G4, `Staff.y_of(4)`). Today it sits ~44 px below
  it at font size 468 (the spec's eye estimate: 25–35).
- Bass: the two dots' midpoint at **0.636** of the font size goes on the F line (F3,
  `Staff.y_of(8)`); today it is within a pixel of it.
- Same fractions at 468/330 and at 187/132, within half a pixel.

## Decided here

- `clef.gd` holds `SIZE := 0.4`, the full font sizes (468, 330), the anchors, the Labels' left
  edges (7.2, 13.3) and the full-size key start (258, 236). Font size `roundi(full * SIZE)`;
  the key's left edge `left + (after − left) * SIZE`.
- `KeySignature.show_key(fifths, clef, left, size)`; each sign `scale = size`, spacing ×size.
- Crisp: `mipmaps/generate=true` for `art/sharp.svg` and `art/flat.svg`, and the KeySignature
  node draws with `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`. The clefs stay Labels with a smaller
  font size (font oversampling keeps them sharp when the window stretches).
- `main.tscn` gets the 40% sizes and placed offsets too, so the editor shows what runs.

## Review Focus

1. Full screen (stretch 1.5× or more): the signs neither shimmer nor blur; the clef is sharp.
2. 7 sharps / 7 flats in both clefs end clear of the gorilla (x 384).
3. A sign stays on its line or space after scaling (the origin on the line, not the corner).
4. Switching clef or key on the board (the level redraws behind the menu) leaves no old signs
   or a stale clef.
5. A key change between songs in a row (Play again, Restart) redraws at the same size.

Tests: 2 → bot check (level key and the ±7 extremes); 3, 4, 5 → screenshots and code reading
(the bot checks the key once per run); 1 → screenshots at 1280×720 and 1920×1080.

---

### Task 1: Clef and key signature at 40%, on their lines

**Files:** Create `scripts/clef.gd`; modify `scripts/key_signature.gd`, `scripts/game.gd`
(`restart()` calls `$Clef.show_clef(clef, fifths)`), `main.tscn`, `art/sharp.svg.import`,
`art/flat.svg.import`, `scripts/dev_autoplay.gd`, `README.md`.

**Interfaces — Produces:** `clef.gd` `show_clef(clef: Song.Clef, fifths: int) -> void`;
`key_signature.gd` `show_key(fifths: int, clef: Song.Clef, left: float, size: float) -> void`.

- [ ] **Step 1: Failing check.** Bot: once a level is built, the key signature's right edge is
  left of 0.3 of the width; prints `key: <n> sharps, clear of the gorilla` (or `flats`), or
  `key: none`; and a copy of the Clef node shows 7 sharps and 7 flats in both clefs, each
  clear too.
- [ ] **Step 2: Run** `--song=9 --bpm=120` (4 flats) — Expected: an error, the flats reach
  past x 384.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** `--song=9`, `--song=6`, each with `--bass` too, with `--shots` —
  Expected: `key: 4 flats, clear of the gorilla`, `key: 2 sharps, …`; the screenshots show
  each clef on its line. Then the full suite once.
