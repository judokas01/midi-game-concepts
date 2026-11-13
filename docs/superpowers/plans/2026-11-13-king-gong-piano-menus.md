# King Gong: working the menus from the piano — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every menu is worked with six white keys in any octave (C ▲ D ▼ E ◀ F ▶ A ✓ B ✕),
mimicked by ↑ ↓ ← → Enter/Space Esc, with a wooden sign beside the selection showing which
keys do something there.

**Architecture:** One new `MenuCursor` (a full-screen Control on top of the HUD) holds the
current menu's rows, moves the selection, applies the six actions, draws the row and cell
frames, lights planks and yellow buttons, and places a `MenuSign` child (the one-octave sign,
drawn in code). Each menu hands its rows over (`cursor_rows()`); `hud.gd` picks the menu that
is up and feeds the cursor notes and keys; `game.gd` routes notes, arrows, Enter, Space and
Esc there while a menu is up, and does the Esc work when the cursor asks to go back.

**Tech Stack:** Godot 4.7.2, typed GDScript, `main.tscn` untouched (the cursor is made in code).

**Spec:** [docs/superpowers/specs/2026-11-13-king-gong-piano-menus-design.md](../specs/2026-11-13-king-gong-piano-menus-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`; paths below are relative to it.
- Godot: `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe` (`..._console.exe` for headless).
- Dev check: `bash .superpowers/sdd/2026-11-13-king-gong-piano-menus/check.sh "<expected>" [flags]`
  from the repo root: runs `-- --autoplay [flags]` (timeout 200 s), prints the `paused`,
  `resumed`, `autoplay`, `menu:`, `pause:`, `end:` and `drill:` lines, passes only on the
  expected line and no `SCRIPT ERROR` / `ERROR`. Godot sometimes segfaults at quit; judge by
  the printed lines.
- Note → action by pitch class, any octave: 0 C ▲ up, 2 D ▼ down, 4 E ◀, 5 F ▶, 9 A ✓ press,
  11 B ✕ back. G and black keys: nothing. Keys: ↑ ↓ ← → as C D E F, Enter **and** Space as A,
  Esc as B. Computer-keyboard note letters never work menus.
- Sign colours: keys white `#f4f1e6`, black `#23201c`, edge `#5b564c`, lit `#f2c230`, marks
  `#2b2620`, flash `#b9860c`; wood `#a7774a` → `#80562f` → `#62401f`, pointed left. About
  130 × 60 px. Frames: `#f2c230`, border alpha 1, fill alpha 0.08 (the chord grid's mark).
- The sign lights exactly the keys that would do something now; ✕ everywhere but the main page.
- End panel: notes do nothing for its first 1.0 s and the sign shows only after it; keys work
  at once.
- No commits. The user commits their own work.
- Code style: typed GDScript, tabs, `##` doc comments in the project's plain-English voice.

## Review Focus

1. **Keys move the selection while the mouse rests on another button**: only the selected one
   may look selected (hover looks are the cursor's, not Godot's). Pinned in Task 1 (mouse
   pointing selects) and by eye in Task 4.
2. **A row that appears or hides** (Chord sign with a chords part; Practice vs Keyboard hint):
   C/D skip hidden rows and land on shown ones. Pinned by `--menu --chords` (Task 2).
3. **Tempo at 120 BPM**: ▶ unlit, F does nothing. Pinned by `--pause --bpm=120` (Task 3).
4. **The note that presses Start, Continue or Play again is let go inside the song**: ignored.
   Pinned in Task 3 (`_menu_notes` empty after release, nothing counted).
5. **Enter / Esc on the end panel inside its first second** work at once. By hand (Task 4).

---

### Task 1: MenuCursor and MenuSign

**Files:**
- Create: `scripts/menu_cursor.gd`, `scripts/menu_sign.gd`, `scripts/dev_cursor_check.gd`

**Interfaces — Produces** (`const MenuCursor := preload("res://scripts/menu_cursor.gd")`):
- `extends Control`; `enum Act { UP, DOWN, LEFT, RIGHT, PRESS, BACK }`;
  `const NOTE_ACTS := {0: Act.UP, 2: Act.DOWN, 4: Act.LEFT, 5: Act.RIGHT, 9: Act.PRESS, 11: Act.BACK}`;
  `const KEY_ACTS := {KEY_UP: Act.UP, KEY_DOWN: Act.DOWN, KEY_LEFT: Act.LEFT, KEY_RIGHT: Act.RIGHT}`;
  `signal back_requested`.
- `class Row` (kind PRESS / CELLS / CHOICE / VALUE, `cells: Array[Button]`, `cell: int`,
  `step: Callable`, `can_step: Callable`, `parts: Array[Control]`). A row is shown while
  `parts[0].is_visible_in_tree()`. Made only by:
  - `static func press(button: Button, parts: Array = []) -> Row` — A presses; a toggle
    without a ButtonGroup also flips with E/F. `parts` defaults to `[button]`.
  - `static func cells(buttons: Array, start := 0, parts: Array = []) -> Row` — E/F walk the
    cells, wrapping; A presses the cell. `parts` defaults to `[buttons[0].get_parent()]`.
  - `static func choice(buttons: Array, parts: Array) -> Row` — a radio: E/F press the option
    before/after the pressed one, stopping at the ends; A nothing.
  - `static func value(step: Callable, can_step: Callable, parts: Array) -> Row` — E/F call
    `step(-1)`/`step(1)` when `can_step(by)`; A nothing.
- `func use(rows: Array, start: int, anchor: Control, back: bool, sign_after_s := 0.0) -> void`
  — `anchor`: the board whose right edge the sign sits outside, null on the main page (then
  beside the selected button). `start` < 0 means the last row.
- `func clear() -> void` — no menu: nothing selected, no frames, no sign.
- `func act(a: Act) -> void` — does `a` if it is lit, and flashes its key on the sign; BACK
  emits `back_requested`.
- `func lit() -> Array[int]` — the acts that would do something now, in Act order.
- `func selected() -> Control` — the button under the cursor; a CHOICE/VALUE row's last part.
- `func sign_shown() -> bool`.
- `menu_sign.gd` (`extends Control`, made by the cursor as child `Sign`):
  `func show_acts(acts: Array) -> void`, `func flash(act: int) -> void` (acts are Act numbers;
  the sign maps them to keys C D E F A B, white-key indices 0 1 2 3 5 6).

Decisions the code must follow:
- Pressing a button is done as `chord_menu.gd`'s `play()` does it today: plain button →
  `pressed.emit()`; toggle in a group → `button_pressed = true`; toggle → flip. Disabled: nothing.
- Up/down wrap and skip hidden rows. Into a CELLS row from a CELLS row: the cell whose centre x
  is nearest the old cell's; from any other row: the target row's own `cell` (kept as it was
  left, initially `start`).
- Looks: on `use()`, every BaseButton among the rows' cells and inside their parts gets its
  hover styles and hover font colours set to its normal/pressed ones (kept once, by meta), so
  Godot's hover never shows. The selected button, if `theme_type_variation` is `Plank` or
  `StartButton`, gets the theme's hover style as its normal one, and a Plank also `reach(true)`
  (Task 2 adds `reach` to `plank.gd`; call it only `if has_method("reach")`). Otherwise the
  cursor draws the row frame (merged parts rect grown 4 px) and, on a CELLS row, a cell frame.
- Mouse: `mouse_entered` on any of those buttons selects its row (and the cell, if it is one).
  Hook each button once.
- Sign: vertically centred on the selected row; x = anchor's right edge + 8 (or the selected
  button's right edge + 8 without anchor), clamped inside the viewport but never left of the
  row's right edge + 4. Hidden until `sign_after_s` has passed since `use()`. Lit keys gold with
  their mark drawn as shapes (triangles, a tick, a cross — no glyphs); a flashed key `#b9860c`
  for 0.15 s. `process_mode = ALWAYS` (it works the pause menu).

- [ ] **Step 1: Write `scripts/dev_cursor_check.gd`** (`extends SceneTree`, run headless). In
  `_initialize`, build in a VBoxContainer added to `root`: row P (a Button), row Q (HBox of
  three 40-px Buttons), row R (HBox of three toggle Buttons in one ButtonGroup, first pressed),
  row V (HBox `◀ label ▶`, value `v` 0..2 starting at 2), row T (a toggle Button), row H (a
  hidden Button), row S (HBox of two Buttons whose second sits under Q's third). Wait two
  process frames, then `use([press(P), cells(Q, 1), choice(R, [R]), value(...), press(T),
  press(H), cells(S)], 0, null, true)` and assert, printing `cursor: ok` at the end and
  `push_error("cursor: not so: ...")` on each failure:
  - `selected() == P` and `lit() == [UP, DOWN, PRESS, BACK]`.
  - DOWN → `selected() == Q[1]`; RIGHT, RIGHT → `Q[0]` (wraps); LEFT → `Q[2]`; PRESS → Q[2]'s
    `pressed` fired once.
  - DOWN → selected is R's HBox; `lit()` has RIGHT, not LEFT, not PRESS; LEFT changes nothing;
    RIGHT → `R[1].button_pressed`.
  - DOWN → V: `lit()` has LEFT, not RIGHT; RIGHT keeps `v == 2`; LEFT → `v == 1`.
  - DOWN → T: LEFT flips it on; PRESS flips it off.
  - DOWN → skips H → S on `S[0]` (from T, not a cell row, S keeps its own cell); UP → T
    (skips H again); DOWN, DOWN → P (wraps).
  - Nearest x and the mouse: `use([cells(Q), cells(S)], 0, null, true)`,
    `Q[2].mouse_entered.emit()` → `selected() == Q[2]`; DOWN → `S[1]`.
  - BACK → `back_requested` once; `use(..., back = false)` → BACK emits nothing and `lit()`
    lacks BACK.
  - `sign_shown()` true after `use(..., 0.0)`; false right after `use(..., 1.0)`.
  `quit()` at the end.

- [ ] **Step 2: Run it, see it fail.**
  Run: `"C:/game-dev/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_cursor_check.gd`
  Expected: FAIL — parse error, `menu_cursor.gd` not found.

- [ ] **Step 3: Write `scripts/menu_cursor.gd` and `scripts/menu_sign.gd`** to the interfaces
  and decisions above.

- [ ] **Step 4: Run it, see it pass.** Same command. Expected: `cursor: ok`, no `ERROR`.

---

### Task 2: The main menu, the boards and the chord grid by piano

**Files:**
- Modify: `scripts/plank.gd`, `scripts/note_input.gd`, `scripts/hud.gd`, `scripts/game.gd`,
  `scripts/main_menu.gd`, `scripts/chord_menu.gd`, `scripts/pause_menu.gd`, `scripts/dev_autoplay.gd`

**Interfaces:**
- Consumes: Task 1's `MenuCursor` API.
- Produces:
  - `plank.gd`: `func reach(on: bool) -> void` (the old mouse lean, now the cursor's); its own
    `mouse_entered`/`mouse_exited` hooks go.
  - `note_input.gd`: `signal arrow_pressed(key: Key)` for ↑ ↓ ← → (pressed, not echo).
  - `hud.gd`: `signal back_pressed`; `var cursor: MenuCursor` (made in `_ready`, named
    `Cursor`, added last so it draws on top); `func menu_note(m: int) -> void`;
    `func menu_key(a: MenuCursor.Act) -> void`. `choose()` goes.
  - `main_menu.gd`: `signal page_shown` (end of every `open()`), `func cursor_rows() -> Array`,
    `func cursor_start() -> int`, `func cursor_anchor() -> Control`.
  - `chord_menu.gd`, `pause_menu.gd`: `func cursor_rows() -> Array`.

Rows (top to bottom; `[caption, control]` are the parts, so the frame takes in the caption):
- Main page: `press` Play, Learn, Drill, Exit (Tutorial, Campaign left out). Start: the plank
  of the last board opened (Play at first). Anchor null, no back.
- Song board: `value` Song (`_next_song`, can step while more than one song), `choice` Part
  (Treble, Bass, Chords, ChordsOnly), `choice` Sign (Name, Bass), `press` Practice/Toggle,
  `press` Hint/Toggle, `cells([Back, Start], 1)`. Start: last row. Anchor: `Songs/Board`.
- Drill board: `cells` Kinds (Major … Aug), `press` More, `choice` Round (R8 … R64),
  `value` Every (`_step_beats`, can step within `Drill.BEATS_MIN..MAX`), `press` Hint/Toggle,
  `cells([Back, Start], 1)`. Anchor: `Drill/Board`.
- Chord grid: one `cells` row per kind — group button, kind button where the group has
  several, then its chords — parts `[the row's container]`, cell = the chord on C; then
  `press` Done. Anchor `Center/Board`. The C4–B4 scheme goes: `play()`, `_rows`, `_frames`,
  `_mark`, `_mark_row`, `_add_keys`, `LOW`, `MARK`; Done reads `Done`.
- Pause menu: `press` Continue, `press` Restart, `press` Practice/Toggle (parts `[Practice]`),
  `value` Tempo (`step_tempo`, can step within TEMPO_MIN..MAX), `press` Tick/Toggle, `press`
  Labels/Toggle, `press` Menu. Anchor `Center/Panel`. `_unhandled_key_input` goes.
- End panel (in `hud.gd`): `cells([Again, Menu], 0)`. Anchor the panel.

HUD picks the menu (`_refresh_cursor()`, on `visibility_changed` of the main menu, chord grid,
pause menu and end panel, and on `page_shown`): pause, else chord grid, else end panel, else
main menu by page, else `cursor.clear()`; it calls `use()` only when that choice changed, so
a menu opens on its start every time it is opened. Back is on everywhere but the main page.
`menu_note(m)` → `cursor.act(NOTE_ACTS[m % 12])` when it has one.

`game.gd`:
- `note_on` with a menu up: MIDI source → `hud.menu_note(m)`; return either way.
- Space and Enter: menu up → `hud.menu_key(PRESS)`; otherwise Enter restarts a started song,
  Space nothing. Arrows: menu up → `hud.menu_key(KEY_ACTS[key])`. Esc: menu up →
  `hud.menu_key(BACK)`, else pause if it can.
- `hud.back_pressed` → `_back()`: chord grid → close it; paused → resume; started → `show_menu()`
  (the end panel); else `hud.menu_back()`.

- [ ] **Step 1: Rewrite the bot's `--menu` walk** (`dev_autoplay.gd`) to work by notes. Add
  `_note(pc: int, octave: int)` (note on and off at `12 * (octave + 1) + pc` with
  `note_input.source = "MIDI"`, restored after) and `_lit() -> String` (the letters `"CDEFAB"[a]`
  of `cursor.lit()`). One step per `MENU_STEP_MS`, each checked with `_expect`; octaves vary
  between notes. The walk, for the board of the mode (Play, or Learn/Drill with the flags):
  1. Main page, `selected()` is Play, `_lit() == "CDA"`, sign shown. `Learn.mouse_entered.emit()`
     → Learn selected; C → Play. Esc key and a B note.
  2. Still the main page. D × the plank's index (0 Play, 1 Learn, 2 Drill), check it is
     selected, A → its board.
  3. Song board: board and mode right; `selected()` is Start; `_lit() == "CDEFAB"`; the Sign
     row shows only with a chords part. D → Song row, `_lit() == "CDEFB"`; F → song 1
     (`Pick.selected == 1`, `game.song == 1`); E → song 0. D → Part; D → `Sign` with
     `--chords`, else Practice (Play) or Hint (Learn). B → main page.
     Drill board instead: `selected()` is Start; D → Kinds on Major; F, A (Minor on); E, A
     (Major off); F, A (Minor refused) → `grid.picked() == MINORS`, Minor lit, Major not, the
     summary names them; the existing width check with Dom7; D → More, A → chord grid:
     `selected().text == "C"`, `_lit() == "CDEFAB"`, A → `"C" in picked()`, D →
     `selected().text == "Cm"`, C, A → `picked() == MINORS`; B → drill board on Start; B →
     main page.
  4. Main page with the board's plank selected; A → the board again, on Start.
  5. `_key(KEY_UP)`, `_key(KEY_DOWN)`, `_key(KEY_SPACE)` → started, counters show; prints
     `menu: started from <PAGE>` (and on the drill `menu: kinds ok` as now).
  Update the header comment for `--menu`.

- [ ] **Step 2: Run it, see it fail.** `check.sh "menu: started from PLAY" --menu --bpm=120`.
  Expected: FAIL (no `cursor` on the HUD).

- [ ] **Step 3: Implement** the interfaces, rows and routing above.

- [ ] **Step 4: Run, see it pass**, each: `check.sh "menu: back on PLAY" --menu --bpm=120`;
  `"menu: back on LEARN" --menu --learn --bpm=120`; `"menu: back on PLAY" --menu --chords
  --bpm=120`; `"menu: kinds ok" --menu --drill --bpm=120`; and unchanged runs
  `"autoplay ended: WON falls=2 bananas=5"` (no flags) and `--pause` (its → then Space still
  continue). Expected: PASS ×6.

---

### Task 3: The pause menu and the end panel by piano

**Files:**
- Modify: `scripts/hud.gd`, `scripts/game.gd`, `scripts/dev_autoplay.gd`

**Interfaces:**
- Consumes: Task 2's `hud.cursor`, `hud.menu_note`, `hud.menu_key`.
- Produces: `hud.gd` `const END_WAIT_S := 1.0` — `menu_note` ignores notes while the end panel
  is younger than that, and the end panel's `use()` passes it as `sign_after_s`. `game.gd`
  `var _menu_notes := {}` — every note pressed while a menu is up; `note_off` of one of them
  is dropped (erased, return) before anything else.

- [ ] **Step 1: Write the bot checks.**
  - `--pause`, on each pause once paused for `PAUSE_FOR_MS`: `selected()` is Continue and
    `_lit() == "CDAB"`. Pause 1 by notes: D × (3 in Play, 2 otherwise, Practice showing only in
    Play) to Tempo; `_lit()` has F unless `bpm == 120`; F; `game.bpm == min(before + 5, 120)`;
    B continues. Pause 2 by keys: ↓ × the same, →, Esc. Pause 3: Enter. Print
    `pause: tempo <bpm>` after each step of the tempo. After each resume, check
    `game._menu_notes.is_empty()` and that the falls/misses did not change across the pause.
  - End panel (every run): 300 ms after the end, an A note → state unchanged, panel up,
    `not cursor.sign_shown()`; at 1300 ms the sign shows, `_lit() == "EFAB"`, Play again
    selected; print `end: guard ok`. With `--menu`, at 2000 ms: F → Menu selected, A → the
    board is back (as now, on Start) instead of `Menu.pressed.emit()`.

- [ ] **Step 2: Run, see it fail.** `check.sh "end: guard ok"` and
  `check.sh "pause: tempo 65" --pause`. Expected: FAIL (the A note restarts the run; no
  `pause:` line).

- [ ] **Step 3: Implement** `END_WAIT_S` and `_menu_notes`.

- [ ] **Step 4: Run, see it pass**: `check.sh "end: guard ok"`; `"pause: tempo 70" --pause`;
  `"pause: tempo 120" --pause --bpm=120` (F unlit at 120); `"menu: back on DRILL" --menu
  --drill --bpm=120`; `"menu: back on LEARN" --menu --learn --bpm=120`. Expected: PASS ×5.

---

### Task 4: README and a look at every menu

**Files:**
- Modify: `README.md`

- [ ] **Step 1: README.** Controls table: replace the "MIDI notes on the menus", `Space`,
  `Esc` and `←`/`→` rows with the six keys (any octave), the sign, and ↑ ↓ ← → Enter/Space Esc
  mimicking them; Enter during a song still restarts, Esc pauses. "The pause menu": the piano
  works it, B continues. "The chord grid": the C/D/E/F/A/B walk replaces the C4–B4 scheme.
  The "Menus" difference note: piano control is in. Dev section: `--menu`, `--pause` and the
  end panel's checks as rewritten, and `dev_cursor_check.gd` with its command. File table:
  `menu_cursor.gd`, `menu_sign.gd`, `dev_cursor_check.gd`.

- [ ] **Step 2: Look.** `check.sh "menu: back on DRILL" --menu --drill --shots=<scratchpad>/menus`
  and `check.sh "pause: tempo 70" --pause --shots=<scratchpad>/pause`; open the shots of the
  main page, each board, the chord grid, the pause menu and the end panel. Expected: the sign
  beside the selection (outside the board's frame, never over a row's buttons), wood and gold
  keys readable, one thing selected per screen. Fix what is off and rerun.

- [ ] **Step 3: Full run.** Every command of Tasks 1–3 once more. Expected: all PASS.
