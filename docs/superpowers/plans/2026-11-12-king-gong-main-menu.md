# King Gong main menu as jungle signs — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the start screen with a main menu of hanging wooden planks and three boards
(Play song, Learn song, Chord drill), add "chord every n beats" to the drill, and give the
pause menu and the end panel the same wood.

**Architecture:** The wood is two new SVGs (`art/plank.svg`, `art/board.svg`) used as
9-slice `StyleBoxTexture`s in theme type variations in `ui/theme.tres` (`Plank`, `Board`,
`Sign`, `Tag`, `StartButton`, `BoardCaption`). Two tiny scripts do the motion: `plank.gd`
(tilt, straighten and grow under the mouse) and `ropes.gd` (the two lianas a plank or board
hangs by). A new `main_menu.gd` owns the main page and the boards, laid out in `main.tscn`;
`hud.gd` wires it to the game and to the existing chord grid (`chord_menu.gd`), which stays
the one record of which chords the drill deals.

**Tech Stack:** Godot 4.7.2, GDScript, `.tscn`/`.tres` edited as text, SVG art.

**Spec:** [docs/superpowers/specs/2026-11-12-king-gong-main-menu-design.md](../specs/2026-11-12-king-gong-main-menu-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`. Paths below are relative to it.
- Godot: `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe`. After adding an SVG run
  `--headless --path . --import` once, so it has its `.import` file before anything loads it.
- Dev check: `bash .superpowers/sdd/2026-11-12-king-gong-main-menu/check.sh "<expected>" [flags]`
  (from the repo root) passes only on the expected line and no `SCRIPT ERROR`/`ERROR`. Godot
  sometimes segfaults at quit; that is old and is judged by the printed lines, not the exit code.
- Menu order, top to bottom: Tutorial (coming soon), Campaign (coming soon), Play song, Learn
  song, Chord drill, Exit game. Title sign: `King Gong`.
- No MIDI notes on any menu button except the chord grid (More options), which keeps its
  row-and-key control. A note on any other menu does nothing.
- The menu button on the pause menu and the end panel reads `Menu` and opens the board you
  started from.
- Drill: "Chord every" 1 to 8 beats, default 4. "In a round" 8 · 16 · 32 · 64, default 16.
- Colours: text on wood `#f7e7a6` with a dark outline; board captions `#f0dcb0` bold; Start
  and Continue `#f2c230` with `#1f2a1c` text; lianas `#8a6a3a` edged, `#c9a46a` core. Menu
  dimming `Color(0.047, 0.071, 0.047, 0.45)`; pause dimming 0.5.
- No descriptions in the menus: no paragraphs, no "No MIDI? Keys" line, no "press to start".
- No commits. The user commits their own work.
- Code style: typed GDScript, `##` doc comments in the project's plain-English voice, tabs.

## Review Focus

1. **Esc and Space on the main page, before any song:** nothing happens. Pinned by the
   `--menu` bot run (Task 3).
2. **Menu from the end panel or the pause menu:** the game is unpaused and the board you came
   from shows, with its song and part. End panel pinned by `--menu` (Task 3); pause by hand.
3. **The Chord sign row follows the part**, also when a board opens with a chords part
   already chosen. Pinned by `--menu --chords` (Task 3).
4. **Counters and the little keyboard** hide while a menu or the chord grid is up and come
   back on Start. Pinned by `--menu` (Task 3).
5. **The last chord kind can't be turned off**, and picks made in More options show on the
   kind buttons on return. First pinned by `--menu --drill` (Task 4); second by hand.

---

### Task 1: Chord every n beats

**Files:**
- Modify: `scripts/drill.gd`, `scripts/game.gd`, `scripts/dev_autoplay.gd`, `README.md`

**Interfaces:**
- Produces, `drill.gd`: `const BEATS := 4`, `const BEATS_MIN := 1`, `const BEATS_MAX := 8`;
  `static func entries(chords: Array, count: int, beats: int = BEATS) -> Array`.
- Produces, `game.gd`: `var drill_beats := Drill.BEATS`;
  `func set_drill(chords: Array, count: int, beats: int = Drill.BEATS) -> void`.

- [ ] **Step 1: Write the failing check** in `dev_autoplay.gd`: parse `--beats=<n>` into
  `_beats` (default `Drill.BEATS`); move the `--drill` setup after the argument loop so it
  calls `game.set_drill.call_deferred(Drill.all_chords(), Drill.COUNT, _beats)`. Add, and call
  once on the first `_play` frame where `game.started and game.mode == Hud.Mode.DRILL`:

```gdscript
## The drill's chords sit game.drill_beats apart.
func _check_drill_spacing() -> void:
	var at: Array = game.notes.filter(func(n: Song.Note) -> bool: return n.chord != null).map(func(n: Song.Note) -> float: return n.beat)
	for k in range(1, at.size()):
		if not is_equal_approx(at[k] - at[k - 1], game.drill_beats):
			push_error("drill chords %.2f beats apart, not %d" % [at[k] - at[k - 1], game.drill_beats])
			return
	print("drill: %d chords, %d beats apart" % [at.size(), game.drill_beats])
```

- [ ] **Step 2: Run it, see it fail**
  Run: `check.sh "drill: 16 chords, 4 beats apart" --drill`
  Expected: FAIL (`Drill.BEATS` / `drill_beats` don't exist).

- [ ] **Step 3: Implement.** `drill.gd`: a chord's tune fills `beats` beats — 2-beat cells
  from `RHYTHMS` while two or more are left, then `[1.0]` or `[0.5, 0.5]` for an odd last
  beat; update the class comment ("every two beats"). `game.gd`: `drill_beats`, the new
  `set_drill` parameter, and `restart()` passes `drill_beats` to `Drill.entries`.

- [ ] **Step 4: Run it, see it pass**
  Run: `check.sh "drill: 16 chords, 4 beats apart" --drill`, then
  `check.sh "drill: 16 chords, 1 beats apart" --drill --beats=1`, then
  `check.sh "autoplay ended: WON falls=0 bananas=4 misses=1" --drill --beats=7`
  Expected: PASS ×3.

- [ ] **Step 5: README:** the chord drill section says a new chord every 4 beats by default;
  Dev check lists `--beats=<n>`.

### Task 2: The wood, on the pause menu and the end panel

**Files:**
- Create: `art/plank.svg`, `art/board.svg`, `scripts/plank.gd`, `scripts/ropes.gd`
- Modify: `ui/theme.tres`, `main.tscn` (PauseMenu, EndPanel), `scripts/hud.gd`,
  `scripts/game.gd`, `scripts/dev_autoplay.gd`, `art/CREDITS.md`, `README.md`

**Interfaces:**
- Produces, theme type variations in `ui/theme.tres`: `Plank` (Button: plank.svg 9-slice,
  hover brighter, pressed darker, disabled grey; bold 21, cream with dark outline),
  `Board` (PanelContainer: board.svg 9-slice), `Sign` (Label on plank.svg, bold 28),
  `Tag` (Label: small cream paper, dark text 11), `StartButton` (Button: flat yellow, bold 19),
  `BoardCaption` (Label: `#f0dcb0` bold 16).
- Produces, `scripts/plank.gd` (`extends Button`): `@export var tilt := 0.0` (degrees). Hangs
  at `tilt`; under the mouse it straightens to 0° and scales to 1.04 over 0.12 s, and back.
  Disabled planks don't move. Pivot is the centre, kept on resize.
- Produces, `scripts/ropes.gd` (`extends Control`, full rect of its parent, mouse ignored):
  `@export var inset := 36.0`, `@export var length := 30.0` (`<= 0`: up to the top of the
  screen). Draws two lianas up from the parent's top edge, `inset` from each side; redraws
  when the parent moves or resizes.

- [ ] **Step 1: Write the failing check** in `dev_autoplay.gd`: one second after the song
  ends, play C4 on the end panel; at quit, it must not have picked anything.

```gdscript
		elif now - _ended_at > 1000.0 and not _poked_end:
			_poked_end = true
			game.note_on(60, now)   # C4 picked "Play again" while menus took notes
			game.note_off(60, now)
```
  …and before `get_tree().quit()`: `if game.state != _end_state: push_error("a note on the end panel picked a button")`, with `_end_state` saved when the end is first seen.

- [ ] **Step 2: Run it, see it fail**
  Run: `check.sh "autoplay ended: WON falls=2 bananas=5"`
  Expected: FAIL, `a note on the end panel picked a button`.

- [ ] **Step 3: Implement the menus' note handling.** `hud.gd`: drop `END_KEYS`,
  `END_DEAF_MS`, `_end_listens_at` and the note names on the end panel's buttons; `choose()`
  picks only on the start screen and the chord grid (the start screen goes in Task 3).

- [ ] **Step 4: Run it, see it pass.** Same command. Expected: PASS.

- [ ] **Step 5: Draw the wood.** `art/plank.svg` about 120×40: rounded warm-brown plank,
  grain, a light top edge, a dark bottom edge, a few px of soft shadow under it.
  `art/board.svg` about 120×120: a wood frame ~14 px wide around a dark inner panel
  (`rgba(22,16,10,.88)`). Import. Add the theme variations, `plank.gd`, `ropes.gd`, and a
  CREDITS line.

- [ ] **Step 6: Restyle.** PauseMenu: dimming 0.5; `Panel` uses `Board` with `Ropes`
  (`length = 0`); `Title` "Paused" uses `Sign`; `Continue` `StartButton`; `Restart` and
  `Menu` are `plank.gd` planks, `Menu` reading `Menu`; captions `BoardCaption`. Node names
  stay, so `pause_menu.gd` is unchanged. EndPanel: `Board` with `Ropes` to the top, title in
  cream, `Again` `StartButton`, `Menu` a plank reading `Menu`.

- [ ] **Step 7: Look at it.**
  Run: `check.sh "autoplay ended: WON falls=2 bananas=5" --pause --shots=<scratch>/t2`,
  open the shot taken while paused and the last one (end panel).
  Expected: both boards hang on lianas, wood readable, nothing clipped.

- [ ] **Step 8: Suite.** `suite.sh` → `SUITE PASS`.

### Task 3: The main menu and its boards

**Files:**
- Create: `scripts/main_menu.gd`
- Modify: `main.tscn` (Overlay replaced by `Hud/MainMenu`; ChordMenu loses its body text),
  `scripts/hud.gd`, `scripts/game.gd`, `scripts/chord_menu.gd`, `scripts/dev_autoplay.gd`,
  `README.md`

**Interfaces:**
- Consumes: Task 2's variations, `plank.gd`, `ropes.gd`; Task 1's `set_drill(chords, count, beats)`.
- Produces, `scripts/main_menu.gd` (`extends Control`):
  - `enum Page { MAIN, PLAY, LEARN, DRILL }`, `var page := Page.MAIN`
  - signals `page_opened(page: Page)` (boards only), `start_pressed`, `song_chosen(song: int)`,
    `style_chosen(clef: Song.Clef, chords: bool, by_itself: bool)`,
    `hint_chosen(hint: ChordLog.Hint)`, `practice_toggled(on: bool)`,
    `piano_toggled(on: bool)`, `drill_changed(count: int, beats: int)`, `chords_requested`
  - `func open(p: Page) -> void`: shows the menu on `p`; a board emits `page_opened`
  - `func back() -> bool`: board → MAIN; false on MAIN
  - `func on_board() -> bool`
  - `func show_style(chords: bool) -> void`: the Chord sign row
  - `func set_practice(on: bool) -> void` (no signal)
  - `func show_picked(chords: Array) -> void`: the line under Chords, at most 40 letters of
    names then `and N more` (moved from `hud._show_picked`)
  - `var count: int`, `var beats: int` (the drill board's values)
  - Scene: `MainMenu/Dim`, `MainMenu/Main/Column/{Title,Tutorial,Campaign,Play,Learn,Drill,Exit}`,
    `MainMenu/Songs/Board/Rows/{Title,Grid,Foot}` with Grid rows `Song, Part, Sign, Practice,
    Hint` (each a `<Name>Caption` label and a `<Name>` box), `MainMenu/Drill/Board/Rows/...`
    with Grid rows `Chords, Round, Every, Hint`; `Foot/{Back,Start}` on both boards.
    Play song and Learn song share `Songs`: its title, and Practice (PLAY) or Hint (LEARN).
- Produces, `chord_menu.gd`: no count row and no `count`; `signal closed(chords: Array)`.
- Produces, `hud.gd`: `drill_chosen(chords: Array, count: int, beats: int)`;
  `func on_board() -> bool`; `func menu_back() -> void`; `show_options(mode, chords, by_itself)`
  passes `chords` to `show_style`; `choose(m)` works the chord grid only. Counters (Progress,
  Pill) and the little keyboard are hidden while the main menu or the chord grid is up.
- Produces, `game.gd`: Space starts only from a board; Esc: chord grid → close, paused →
  continue, running → pause, end panel → `show_menu()`, else `hud.menu_back()`. A note while
  a menu is up only works the chord grid. `show_key_notes` and its text go.

- [ ] **Step 1: Write the failing check**: `--menu` in `dev_autoplay.gd` (and `game.gd`'s
  dev flags). With it the bot does not call `game.start()`; it works the menu, one step every
  600 ms, `push_error` on anything unexpected, then plays on as usual:
  1. menu up on MAIN, Pill hidden, not started; send Esc and Space.
  2. still MAIN, not started; press the plank for the mode flags (`Play`, `Learn` with
     `--learn`, `Drill` with `--drill`).
  3. page is that board, `game.mode` matches; with `--chords`/`--chords-only` the Sign row
     shows, else not; send Esc.
  4. MAIN again; press the plank again.
  5. send Space.
  6. started, menu hidden, Pill shown; print `menu: started from <PAGE>`.
  At the end, instead of quitting at 2 s, press `EndPanel/Lines/Buttons/Menu`, then expect
  the menu up on the same board and not started; print `menu: back on <PAGE>`; quit.

- [ ] **Step 2: Run it, see it fail**
  Run: `check.sh "menu: back on PLAY" --menu`
  Expected: FAIL (no `MainMenu`).

- [ ] **Step 3: Implement** `main_menu.gd`, the scene (planks tilted about ±1.2° in turn,
  lianas between them, the title sign hanging from the top of the screen, coming-soon planks
  disabled with a `Tag` "coming soon", Exit smaller and quitting), the chord grid changes,
  and the hud and game wiring above. More options opens the chord grid; its close returns to
  the drill board and updates the line. Practice mode stays in step with the pause menu's,
  and Keyboard hint between the two boards. Remove the old Overlay and everything that served
  it (texts, `START_KEYS`, `show_key_notes`, the click-to-start handler).

- [ ] **Step 4: Run it, see it pass**
  Run: `check.sh "menu: back on PLAY" --menu`, `check.sh "menu: back on LEARN" --menu --learn`,
  `check.sh "menu: back on DRILL" --menu --drill`, `check.sh "menu: back on PLAY" --menu --chords`.
  Expected: PASS ×4.

- [ ] **Step 5: Look at it.** `--menu --shots=<scratch>/t3` (and with `--drill`): check the
  shots of the main page and the board. Expected: as design D; text readable; nothing
  clipped or overlapping at 1280×720.

- [ ] **Step 6: README:** controls table (planks, boards, Space/Esc, no MIDI on menus but the
  chord grid), Learning sections that say "on the start screen", the `Menus` difference
  note, the file table (`main_menu.gd`, `plank.gd`, `ropes.gd`, art), Dev check `--menu`.

- [ ] **Step 7: Suite** (now with the `--menu` runs) → `SUITE PASS`.

### Task 4: Chord kinds on the drill board

**Files:**
- Modify: `main.tscn` (`Drill/.../Chords/Kinds`), `scripts/main_menu.gd`,
  `scripts/chord_menu.gd`, `scripts/hud.gd`, `scripts/dev_autoplay.gd`, `README.md`

**Interfaces:**
- Produces, `chord_menu.gd`: `func set_kind(quality: String, on: bool) -> void` (on: picks
  the kind on the white-key roots, skipping a root the kind lacks; off: unpicks every chord
  of it, unless that would leave none); `func kinds() -> Array` (qualities with any pick).
- Produces, `main_menu.gd`: `signal kind_toggled(quality: String, on: bool)`;
  `show_picked(chords: Array, kinds: Array)` also lights the kind buttons, without signals.
  Kind buttons `Major, Minor, Dom7, Maj7, Min7, Dim, Aug` for qualities
  `"", "m", "7", "maj7", "m7", "dim", "aug"`.

- [ ] **Step 1: Write the failing check**: with `--menu --drill`, at step 3 before Esc, press
  `Minor` (on), `Major` (off), then `Minor` (off, refused). Expect
  `chord_menu.picked() == ["Cm", "Dm", "Em", "Fm", "Gm", "Am", "Bm"]`, the line reading
  `Cm Dm Em Fm Gm Am Bm`, `Minor` lit and `Major` not. After Start, every chord in
  `game.notes` is one of them. Print `menu: kinds ok`.

- [ ] **Step 2: Run it, see it fail.** `check.sh "menu: kinds ok" --menu --drill` → FAIL.

- [ ] **Step 3: Implement** the kind row and the hud wiring (`kind_toggled` →
  `set_kind` → `show_picked(picked(), kinds())` → `drill_chosen`).

- [ ] **Step 4: Run it, see it pass.** Same command → PASS; then `suite.sh` → `SUITE PASS`.

- [ ] **Step 5: README:** the chord drill section's kind buttons and More options.
