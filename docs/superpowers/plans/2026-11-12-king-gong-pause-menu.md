# King Gong pause menu and counters — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a pause menu (Esc) to the Godot King Gong build, then remove the top bar and the
bottom strip, leaving design C's counters: a progress line along the top and a pill top-right.

**Architecture:** Pause uses Godot's tree pause (`get_tree().paused`). `NoteInput`, the new
`PauseMenu` and the dev bot run with `PROCESS_MODE_ALWAYS`; everything else freezes. On
Continue, `game.gd` shifts its stored wall-clock timers by the time spent paused and turns
hanging, air and rest into a free, untimed wait at a branch. The counters are a small
`_draw()`-based progress line and a pill of labels in `main.tscn`, fed by `hud.gd`.

**Tech Stack:** Godot 4.7.2, GDScript, `.tscn` scenes edited as text.

**Spec:** [docs/superpowers/specs/2026-11-12-king-gong-pause-menu-design.md](../specs/2026-11-12-king-gong-pause-menu-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`. All paths below are relative to it.
- Godot: `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe`. If `.godot/imported` is missing
  assets, run `--headless --path . --import` once first.
- Run the dev check from the project root:
  `& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path . -- --autoplay [flags] 2>&1 | Select-Object -Last 12`
  (PowerShell; piping makes it wait for the GUI exe).
- No MIDI notes on the pause menu's buttons.
- Tempo: 40 to 120 BPM in steps of 5, default 60. Shown as `◀ 60 BPM ▶`.
- Pause menu order: Continue, Restart song, Practice mode (Play mode only), Tempo, Beat tick,
  Labels, Main menu. Title: `Paused`.
- Counters (design C): progress line `#f2c230` on a `rgba(10,16,10,0.45)` track, 6 px tall
  along the top edge, faint ticks at 25/50/75 %, a 12 px knob at the fill's end with
  `done/total` under it; pill top-right, `rgba(16,22,16,0.72)`, radius 20, holding
  `🍌 N · falls N · Esc ‖` (`∞` in practice mode, `wrong N` in Learn and the drill).
- No commits. The user commits their own work.
- Code style: match the existing scripts — typed GDScript, `##` doc comments in the project's
  plain-English voice, tabs.

## Review Focus

1. **Esc pressed while a MIDI key is held:** the release lands during the pause and must not
   count as an early let-go. Covered by the bot releasing after the pause opens (Task 1).
2. **Tempo changed in the pause menu, then Continue:** the next grab uses the new tempo.
   Covered by the bot stepping tempo with `→` on each pause and finishing with the usual
   result (Task 1).
3. **Pause during a fall:** Continue lets the fall finish and the banana is still spent.
   Covered by the bot's pause in mid-fall and an unchanged `bananas=` count (Task 1).
4. **Restart song or Main menu from the pause menu:** the tree must come out of pause, or the
   game stays frozen. `restart()` unpauses. Checked by hand in Task 1 Step 6.
5. **Esc outside a running song:** the start screen does nothing, the chord menu closes, and
   the end panel goes to the main menu, as today. Checked by hand in Task 1 Step 6.

---

### Task 1: Pause menu

**Files:**
- Create: `scripts/pause_menu.gd`
- Modify: `main.tscn` (new `Hud/PauseMenu` subtree; `NoteInput` gets `process_mode = 3`)
- Modify: `scripts/hud.gd`, `scripts/game.gd`, `scripts/dev_autoplay.gd`, `README.md`

**Interfaces:**
- Produces, `scripts/pause_menu.gd` (`extends ColorRect`, `process_mode` ALWAYS):
  - signals `continue_pressed`, `restart_pressed`, `menu_pressed`,
    `practice_toggled(on: bool)`, `tempo_changed(bpm: float)`, `tick_toggled(on: bool)`,
    `labels_toggled(on: bool)`
  - `const TEMPO_MIN := 40`, `TEMPO_MAX := 120`, `TEMPO_STEP := 5`
  - `func open(play_mode: bool, practice: bool, bpm: float, tick: bool, labels: bool) -> void`:
    shows the current values without emitting (`set_pressed_no_signal`), shows the Practice
    row only when `play_mode`, then `show()`
  - `func close() -> void`
  - `func step_tempo(by: int) -> void`: moves by `by * TEMPO_STEP`, clamped, updates the
    label, emits `tempo_changed` only if the value changed
  - `_unhandled_key_input`: while visible, `KEY_LEFT` / `KEY_RIGHT` (echo allowed) call
    `step_tempo(-1)` / `step_tempo(1)` and mark the event handled
- Produces, `scripts/hud.gd`: `signal continue_pressed`;
  `func open_pause(play_mode: bool, practice: bool, bpm: float, tick: bool, labels: bool) -> void`;
  `func close_pause() -> void`. `menu_up()` also returns true while the pause menu is
  visible. The pause menu's signals are forwarded to Hud's existing `restart_pressed`,
  `menu_pressed`, `practice_toggled`, `tempo_changed`, `tick_toggled` and `labels_toggled`. A
  practice toggle from the pause menu also sets the start screen's `Practice` button with
  `set_pressed_no_signal`.
- Produces, `scripts/game.gd`: `func can_pause() -> bool`, `func pause() -> void`,
  `func resume() -> void`.

- [ ] **Step 1: Write the failing check: `--pause` in `scripts/dev_autoplay.gd`**

  Add `--pause` to the header comment and to `dev_flags` in `game.gd` `_ready`. Set the bot's
  `process_mode = Node.PROCESS_MODE_ALWAYS` in its `_ready`, so it can work the menu while the
  tree is paused (screenshots keep coming too). With `--pause`, the bot pauses three times, each
  once, by sending real key events through `Input.parse_input_event` (an `InputEventKey`
  with `keycode` and `pressed = true`):
  - while `state == HANG` and `cur == PAUSE_AT` (`const PAUSE_AT := 10`)
  - the first time `state == REST`
  - the first time `state == FALL` and `land_t == 0.0` (mid-air)

  Each pause is a small sequence. While it runs, the bot skips `_play`:
  1. Send `KEY_ESCAPE` and print `paused state=<State> cur=<cur>`.
  2. Once `get_tree().paused` is true, release any held note with `_release(now)`.
  3. `PAUSE_FOR_MS := 1000.0` after the pause began, send `KEY_RIGHT`, then `KEY_SPACE`.
  4. Once the tree is unpaused, print `resumed state=<State> cur=<cur> bpm=<int bpm>` and go
     back to playing.

  If the tree isn't paused 500 ms after Escape, print `autoplay: Esc did not pause` and
  `get_tree().quit()`.

- [ ] **Step 2: Run it and confirm it fails**

  Run: `... -- --autoplay --pause`
  Expected: `paused state=FALL cur=5` (the bot's wrong note comes first), then
  `autoplay: Esc did not pause`, because Esc goes to the start screen today.

- [ ] **Step 3: Build the pause menu scene and `scripts/pause_menu.gd`**

  In `main.tscn`, add `Hud/PauseMenu` after `Hud/EndPanel`:
  - a full-rect `ColorRect`, `color = Color(0.047, 0.07, 0.047, 0.6)`, `visible = false`,
    `process_mode = 3`, with the `pause_menu.gd` script
  - inside: `Center` (`CenterContainer`, full rect, `mouse_filter = 2`), then `Panel`
    (`PanelContainer`, `StyleBoxFlat_panel`, min width 340), then `Rows` (`VBoxContainer`,
    separation 8)
  - `Rows` holds: `Title` (Label `Paused`, `SystemFont_bold`, size 26, centred);
    `Continue`, `Restart` (`Restart song`), `Menu` (`Main menu`) Buttons; and the rows
    `Practice`, `Tempo`, `Tick`, `Labels`, each an `HBoxContainer` with a `Caption` Label
  - `Practice`, `Tick` and `Labels` each have a `Toggle` Button (`toggle_mode`, text
    `on`/`off`, min width 48)
  - `Tempo` has `Down` (`◀`), `Value` (`60 BPM`, min width 72, centred) and `Up` (`▶`)
  - every Button has `focus_mode = 0` and font size 15, like the end panel's
  - the order follows Global Constraints

  Add `process_mode = 3` to the `NoteInput` node.

- [ ] **Step 4: Wire Hud and implement pause and continue in `scripts/game.gd`**

  - **`can_pause()`:** true when `started` and `state` is not `WON` or `OVER` and no other
    menu is up (`not hud.menu_up()`).
  - **`pause()`:**
    - record `_paused_at := now_ms()` and `metronome.cancel_ticks()`
    - forget the hands: clear `_left`, `_right`, `_wrong`, `_stale` and `_blocked`, and set
      `_missed_chord = false`
    - `get_tree().paused = true`
    - `hud.open_pause(mode == Hud.Mode.PLAY, practice, bpm, tick_on, labels)`
  - **`resume()`:** `away := now_ms() - _paused_at`, unpause, `hud.close_pause()`,
    `now = now_ms()`, then by state:
    - `HANG`: float back to `cur`. First `world.branch(cur).restore()`, then `_hung = -1`.
    - `AIR`, `REST`: float back to `cur + 1`.
    - `FALL`: `land_t += away` if `land_t > 0.0`.
    - `BOUNCE`: `bounce_t0 += away`.
    - otherwise: nothing.
    - In every state, `_blend.t0 += away` if a blend is running.
  - **Float back to branch `j`:** `state = WAIT`, `cur = j`, `perch_stump = false`, and
    `_blend = {from = render.pos, rot = render.rot, t0 = now, dur = 400.0, hop = 0.0}`.
    Neither `falls` nor `bananas` changes.
  - **`restart()`:** starts with `get_tree().paused = false` and `hud.close_pause()`.
  - **`note_off`:** returns at once while `get_tree().paused`. `note_on` already returns,
    through `hud.menu_up()`.
  - **Keys:**
    - Esc (`_on_menu_key`): chord menu open → close it; paused → `resume()`;
      `can_pause()` → `pause()`; `started` → `show_menu()` (the end panel)
    - Space (`_on_start_key`): paused → `resume()`, else as now
  - **Signals:** connect `hud.continue_pressed` to `resume`. Restart and Main menu already
    reach `restart` and `show_menu` through Hud's signals.

- [ ] **Step 5: Run the checks and confirm they pass**

  Run: `... -- --autoplay --pause`
  Expected, in this order of states (cur values follow the song):
  - `paused state=FALL cur=5` then `resumed state=FALL cur=5 bpm=65`
  - `paused state=HANG cur=10` then `resumed state=WAIT cur=10 bpm=70`
  - `paused state=REST cur=<n>` then `resumed state=WAIT cur=<n+1> bpm=75`
  - last line `autoplay ended: WON falls=2 bananas=5`

  Run: `... -- --autoplay --learn --pause`. Expected: one pause at `HANG cur=10`, resumed as
  `WAIT cur=10`, then `autoplay ended: WON falls=0 bananas=4 misses=1`.

  Run: `... -- --autoplay`. Expected: `autoplay ended: WON falls=2 bananas=5` (no regression).

  Run: `... -- --autoplay --pause --shots=<scratch dir>`, and open a screenshot taken while
  paused. Expected: the dimmed world, with the `Paused` panel showing all seven rows,
  Practice included.

- [ ] **Step 6: Check by hand (Review Focus 4 and 5)**

  Launch without flags and use the computer keyboard:
  - Esc mid-song opens the menu, and Esc or Space continues.
  - Restart song and Main menu both leave the game running, not frozen.
  - On the start screen Esc does nothing. With the chord menu open, Esc closes it. On the end
    panel, Esc goes to the main menu.
  - Toggling Labels while paused updates the branch labels behind the menu.

- [ ] **Step 7: README**

  In `README.md`'s controls table:
  - add `Esc` (pause during a song: Continue, Restart song, Practice mode, Tempo, Beat tick,
    Labels, Main menu; Esc or Space continues)
  - change the `Esc` row to "Back to the start screen, from the end panel or the chord menu"
  - add a "Continue" sentence: the gorilla floats up at its branch and waits, no banana spent

  In "Dev check", add `--pause` with its expected output from Step 5.

### Task 2: Bars off, counters on

**Files:**
- Create: `scripts/progress_line.gd`
- Modify: `main.tscn` (delete `Hud/Bar`, `Hud/Legend`, `Hud/Keys`, and the now-unused
  `StyleBoxFlat_bar` / `StyleBoxFlat_source` sub-resources; add `Hud/Progress`, `Hud/Pill`)
- Modify: `scripts/hud.gd`, `scripts/game.gd`, `README.md`

**Interfaces:**
- Consumes: Task 1's pause menu, now the only place for tempo, labels and beat tick.
- Produces, `scripts/progress_line.gd` (`extends Control`): `func show_progress(done: int, total: int) -> void`
  stores the values and calls `queue_redraw()`. `_draw()` paints the Global Constraints'
  line: full width, knob x clamped inside the edges, label `"%d/%d"` (font size 13, colour
  `#f7e7a6`) centred under the knob and clamped inside the edges. `total == 0` draws only the
  track.
- Changes, `scripts/hud.gd`: `show_stats(bananas: int, done: int, total: int, missed: String) -> void`.
  `bananas < 0` shows `∞`. `missed` is shown as given (`"falls 2"`, `"wrong 1"`).

- [ ] **Step 1: Scene**

  - Delete `Hud/Bar` and its children, `Hud/Legend` and `Hud/Keys`.
  - Add `Hud/Progress`: a `Control` anchored across the top (`anchor_right = 1`), height 30,
    `mouse_filter = 2`, with `progress_line.gd`.
  - Add `Hud/Pill`: a `PanelContainer` anchored top-right, 14 px from the top and 12 px from
    the right, with `grow_horizontal = 0` so it grows leftwards and `mouse_filter = 2`. Give
    it a new `StyleBoxFlat_pill`: bg `Color(0.063, 0.086, 0.063, 0.72)`, all corners 20,
    content margins 14/5/10/5.
  - Inside the pill, `Row` (`HBoxContainer`, separation 16) holds:
    - `Bananas` (an `HBoxContainer` of `Icon` TextureRect 20×20 `banana.svg` and `Count`
      Label)
    - `Falls` Label
    - `Esc` Label (`Esc ‖`, font size 12, colour `#a9b5a5`, a 1 px `#a9b5a580` border with
      radius 5)
  - Both new nodes go before `Hud/Overlay`, so the start screen covers them.

- [ ] **Step 2: `scripts/progress_line.gd` and Hud**

  - Write `progress_line.gd` as in Interfaces.
  - In `hud.gd`, remove `_bar`, `_tempo`, `_tempo_value`, `_source`, `_legend`, `_keys`,
    `show_source`, `show_tempo`, `_show_floor`, `_on_tempo`, `_toggle`, the Bar wiring in
    `_ready`, and the `_show_floor()` call in `set_piano`.
  - `show_key_notes` keeps only the start screen's `_overlay_keys` text.
  - `show_stats` feeds `$Pill` and `$Progress`.
  - `fly_banana` aims at the centre of `$Pill/Row/Bananas/Icon`'s global rect.
  - Update the class comment (no top bar; the pause menu and the counters are new).

- [ ] **Step 3: `scripts/game.gd`**

  - `_update_hud` passes `done_up_to, notes.size()`. In the drill it passes logs broken and
    logs in total, as `chord %d/%d` counts them now.
  - The last argument is `"falls %d"` or `"wrong %d"`.
  - Drop `hud.show_source(source)` from `_on_source_changed`.

- [ ] **Step 4: Run every mode and confirm the results are unchanged**

  Run each, expected last line in brackets:
  - `--autoplay` [`WON falls=2 bananas=5`]
  - `--autoplay --chords` [`WON falls=3 bananas=4`]
  - `--autoplay --chords-only` [`WON falls=1 bananas=6`]
  - `--autoplay --learn` [`WON falls=0 bananas=4 misses=1`]
  - `--autoplay --drill` [`WON falls=0 bananas=4 misses=1`]
  - `--autoplay --pause` [`WON falls=2 bananas=5`]

  None may print a `SCRIPT ERROR`.

- [ ] **Step 5: Look at it**

  Run `--autoplay --shots=<scratch dir>` and `--autoplay --learn --shots=<other dir>`, and
  open a mid-song screenshot from each. Expected:
  - no top bar and no legend text on the floor
  - the yellow line along the top, with its `n/42` label under the knob
  - the pill top-right showing `🍌 n · falls n · Esc ‖`, or `wrong n` in Learn mode
  - the little keyboard still at the bottom in Learn mode

  Compare against design C on the mockup page.

- [ ] **Step 6: README**

  - Replace "Which input is live (MIDI or keyboard) is shown top-right, next to bananas,
    progress and falls." with a line about the progress line and the pill.
  - Drop the tempo slider and the Labels / Beat tick rows; they now point to the pause menu.
  - In "Differences from the spike":
    - remove "The legend fits on the floor strip"
    - add that there is no top bar or legend, and the settings are in the pause menu
  - Update the `main.tscn` row under "How it is put together" (no bar; counters and pause
    menu), and add `scripts/pause_menu.gd` and `scripts/progress_line.gd`.
