# King Gong: what is selected on a menu is plain to see — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Gold means "selected" and nothing else: the yellow button rests in a dull ochre and
turns gold (and grows 4%) only while selected; a selected plank also gets a gold edge.

**Architecture:** The theme keeps "the selected look" where `menu_cursor.gd` already reads
it, in each variation's `hover` style: `StartButton`'s resting `normal` becomes a new ochre
style and today's gold becomes its `hover`; `Plank`'s `hover` gets a new texture,
`art/plank_lit.svg`, the plank with a gold rim, so the edge tilts and grows with the plank.
The four yellow buttons get `plank.gd` (tilt 0) so `reach()` grows them as it grows planks.

**Tech Stack:** Godot 4.7.2, typed GDScript, `ui/theme.tres`, `main.tscn`, SVG art.

**Spec:** [docs/superpowers/specs/2026-11-19-king-gong-menu-selection-design.md](../specs/2026-11-19-king-gong-menu-selection-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`; paths below are relative to it.
- Godot: `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe` (console build `…_console.exe` for
  headless checks). Never kill Godot processes you didn't start.
- Gold is `#f2c230` (`MenuCursor.MARK`). The resting ochre: text contrast at least 4.5:1, and
  clearly not gold next to the sign's lit keys.
- No change to what any key or click does, or to where the selection starts. Framed rows
  (board rows, cell rows, the chord grid and its Done) keep their look. Disabled planks
  (Tutorial, Campaign) never change. Godot's own hover look stays off.
- No commits. The user commits their own work.
- Code style: typed GDScript, tabs, `##` doc comments in the project's plain-English voice.
- Dev check: `.superpowers/sdd/2026-11-19-king-gong-menu-selection/check.sh "<expected>" [flags]`,
  the banner plan's `check.sh` with `menu:` and `look:` added to its grep.

## Review Focus

1. **The mouse on a yellow button**: pointing selects it, so it turns gold with dark text and
   no outline; leaving it on another button returns it to ochre with cream outlined text.
2. **Pressing the yellow button with the mouse** shows the darker pressed gold, dark text.
3. **A plank's gold rim under the hover brighten** (`modulate_color` 1.18, 1.13, 1.05) still
   reads as gold, not lemon, and keeps its corners when the 9-slice stretches it wide (Exit
   game, Restart song).
4. **A wider window**: the 4% growth pivots on the button's centre in every container (the
   end panel's row, the boards' Foot, the pause menu's column), never shifting a neighbour.
5. **The chord grid's Done and the board rows' frames** look exactly as before.

---

### Task 1: The looks, and the cursor check that pins them

**Files:**
- Create: `art/plank_lit.svg` (a copy of `art/plank.svg` plus a gold rim)
- Modify: `ui/theme.tres` (StartButton styles and colours, Plank hover texture)
- Modify: `main.tscn` (the four `StartButton` nodes get `script = ExtResource("19_plank")`)
- Modify: `scripts/plank.gd` (doc comment), `scripts/menu_cursor.gd` (`_light`, header)
- Modify: `scripts/dev_cursor_check.gd` (the looks), `art/CREDITS.md` (one line)

**Interfaces — Produces:** the theme's `hover` style of `Plank` and of `StartButton` is "the
selected look"; a button shows it when `get_theme_stylebox(&"normal") ==
ThemeDB.get_project_theme().get_stylebox(&"hover", variation)`. Task 2's bot reads it so.

- [ ] **Step 1: Write the failing check** in `dev_cursor_check.gd`, before the final print:
  a new HBox line with `back` (Plank) and `start` (StartButton), both `Button`s with
  `plank.gd` set before entering the tree; `cursor.use([MenuCursor.cells([back, start], 1)], 0, null, true)`.
  After each move wait 0.3 s (`await create_timer(0.3).timeout`), then `_expect_look(on, off, when)`:
  - `on`'s `normal` stylebox is the theme's `hover` for its variation; `off`'s is the
    theme's `normal` for its variation;
  - `on.scale ≈ Vector2.ONE * 1.04`, `off.scale ≈ Vector2.ONE`;
  - a selected StartButton's `font_color` is the theme's `font_hover_color` and its
    `outline_size` 0; a resting one's `font_color` is the theme's `font_color`.

  Sequence: Start selected → `LEFT` → Back selected → `RIGHT` → Start selected. Then the
  theme itself: `_contrast(StartButton font_color, StartButton normal bg_color) >= 4.5`, and
  the normal bg's luminance under half of `MenuCursor.MARK`'s (both via
  `srgb_to_linear().get_luminance()`, WCAG `(l1 + 0.05) / (l2 + 0.05)`).

- [ ] **Step 2: Run it to see it fail**

  Run: `"C:/game-dev/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_cursor_check.gd`
  Expected: `cursor: failed`, with errors for Start not growing (no `reach()` yet) and for
  the resting colour (gold today) not being under half the gold's luminance.

- [ ] **Step 3: The looks**
  - `art/plank_lit.svg`: `plank.svg` with, last, a rim `rect x=2.25 y=2.25 w=115.5 h=36.5
    rx=7` `fill="none" stroke="#cdac2e" stroke-width="3"` — `#cdac2e` times the hover
    modulate (1.18, 1.13, 1.05) is ≈ `#f2c230`. Import it (`--headless --import`).
  - `theme.tres`: `StyleBoxTexture_plank_hover` takes `plank_lit.svg`. New
    `StyleBoxFlat_start_rest`: as `StyleBoxFlat_start` with `bg_color #7d5a12` (ochre, about
    the wood's brightness) and the same shadow. StartButton: `normal` = rest, `hover` and
    `hover_pressed` = `StyleBoxFlat_start` (today's gold), `pressed` unchanged;
    `font_color`/`font_focus_color` = the plank's cream `(0.968627, 0.905882, 0.65098)`,
    `font_hover_color`/`font_hover_pressed_color`/`font_pressed_color` = today's dark,
    `font_outline_color` = the plank's, `constants/outline_size = 4`. Remove
    `StyleBoxFlat_start_hover` (unused).
  - `main.tscn`: Start (both boards), Continue, Play again get `script = ExtResource("19_plank")`.
  - `plank.gd` doc: also the yellow button, which hangs straight (tilt 0) and grows.
  - `menu_cursor.gd` `_light`: when `on` and the variation is `StartButton`, override
    `outline_size` to 0 (dark text on gold needs none); remove it when off. Header: gold
    marks what is selected — a frame, a plank's gold edge, the yellow button lit gold.
  - `CREDITS.md`: `plank_lit.svg` is the plank with a gold rim, for the selected plank.

- [ ] **Step 4: Run it to see it pass**

  Same command. Expected: `cursor: ok`, no errors.

### Task 2: The bot looks at every menu, and the README

**Files:**
- Modify: `scripts/dev_autoplay.gd`, `README.md`

**Interfaces — Consumes:** Task 1's "selected look" test.

- [ ] **Step 1: Write the failing checks** in the bot:
  - `_expect_lit(buttons: Array, which: Button, where: String)`: `which` alone of `buttons`
    shows the selected look (Task 1's test), else `_expect` fails naming the ones that do.
  - `_look(name: String)`: with `--shots`, saves `<dir>/look_<name>.png` from the viewport
    (the frame before, so it must follow a step that left the menu still for a while).
  - The walk gets two steps after `"pick"` in both step lists: `"foot_back"` —
    `_look("<page>_start")`, `_expect_lit([Back, Start], Start)`, `_note("E", 3)` — and
    `"foot_start"` — `_look("<page>_back")`, `_expect_lit([Back, Start], Back)`,
    `_note("F", 5)`. `<page>` is `play`, `learn` or `drill`.
  - At the start of `"pick"`: `_look("main")` and `_expect_lit(<the Main/Column buttons>, Play)`.
  - End panel: at `end: guard ok`, `_look("end_again")` and `_expect_lit([Again, Menu], Again)`.
    With `--menu`, F then waits `MENU_STEP_MS` before A: `_expect_lit(…, Menu)` after F,
    `_look("end_menu")` before A.
  - The first pause: at half of `PAUSE_FOR_MS`, `_look("pause_continue")`,
    `_expect_lit([Continue, Restart, Menu], Continue)`, `_note("D", 4)`; at `PAUSE_FOR_MS`,
    `_look("pause_restart")`, `_expect_lit(…, Restart)`, `_note("C", 4)`, then the walk as now.
  - Prints `menu: looks ok` once the board's two steps have passed with no error.

  To watch it fail, run it before Task 1's theme (or with the old theme restored):
  `check.sh "menu: looks ok" --menu --bpm=120` → an `_expect_lit` error.

- [ ] **Step 2: Run the suite** (all must pass, no `ERROR`):

  | Flags | Expected |
  |---|---|
  | `--menu --bpm=120` | `menu: looks ok`, `menu: back on PLAY` |
  | `--menu --learn --bpm=120` | `menu: looks ok`, `menu: back on LEARN` |
  | `--menu --drill --bpm=120` | `menu: looks ok`, `menu: kinds ok`, `menu: back on DRILL` |
  | `--menu --chords --bpm=120` | `menu: back on PLAY` |
  | `--pause --chords --bpm=120` | `pause: bass clef ok`, `WON falls=3 bananas=4` |
  | `--bpm=120`, `--drill --bpm=120` | `WON falls=2 bananas=5`, `WON falls=0 bananas=4 misses=1` |

  Plus `dev_cursor_check.gd` → `cursor: ok`.

- [ ] **Step 3: The shots**

  Run `--autoplay --menu --pause --bpm=120 --shots=<scratch>` and `--autoplay --menu --drill
  --bpm=120 --shots=<scratch>`; open the `look_*.png`. Expected: on each, one gold thing.

- [ ] **Step 4: README**
  - Controls, "MIDI notes on the menus": gold marks what is selected — a gold frame round a
    row, a gold edge on a plank, the yellow button (Start, Continue, Play again) gold and a
    touch bigger; at rest the yellow button is ochre.
  - File map: `plank.gd` also grows the yellow button.
  - Dev check: `--menu` also checks the looks on the main page, the board's Back | Start, the
    end panel (and the pause menu with `--pause`) and prints `menu: looks ok`; with `--shots`
    it saves `look_<menu>_<selected>.png` of each.

- [ ] **Step 5: Hand over** — no commit; what changed and the run command.
