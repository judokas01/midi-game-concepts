# King Gong: backing — the game plays the part you don't — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The piano never sounds what the player plays (their electronic piano does). With
**Backing** on it plays the part they don't: the chords under a tune they play, the tune
under chords they play, and in the chord drill an arpeggio of the next chord before its log.
Listen stays as built.

**Architecture:** `piano_sound.gd` gains `strike_due()` (start a note to be heard at a time,
catching up a late start inside the recording's silence). `song_player.gd` is driven by grabs:
`grab()` sounds a branch's part as the gorilla takes hold, `expect()` schedules the next
branch ahead when its grab is certain (the gorilla climbs by itself and no log stands).
A new `arpeggio.gd` schedules the drill's lead-ins on its own piano. `game.gd` decides what
backing plays from the part and calls these at grabs, falls, pauses and the end.

**Tech Stack:** Godot 4.7.2, typed GDScript, `main.tscn`.

**Specs:** [backing](../specs/2026-11-19-king-gong-backing-design.md),
[drill arpeggio](../specs/2026-11-19-king-gong-drill-arpeggio-design.md); the piano from the
piano-sound plan ([2026-11-19-king-gong-piano-sound.md](2026-11-19-king-gong-piano-sound.md)).

## The user's answers (2026-11-20), binding over the specs

- Remove **Your notes** completely: the game never sounds what the player plays.
- Backing in **Play song and Learn song**: Treble/Bass clef → the song's chords; Chords only
  → the tune; Treble + chords → nothing.
- One **Backing** on/off setting, on by default: a row on the Play song, Learn song and Chord
  drill boards, and in the pause menu (where Your notes was).
- The chord drill plays the **arpeggio lead-in** of the drill-arpeggio spec, on the piano
  (not a tone made in code), under the Backing setting (the spec's "no on/off" is overruled).

## Global Constraints

- Project root: `godot-implementations/king-gong/`; paths below are relative to it.
- Godot `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe` (`…_console.exe` headless).
- Backing sounds are tied to the moment the game registers a grab (`_grab()`); a chord rings
  until the next chord comes in; a tune note rings its branch's beats at the tempo.
- A fall lets the backing go (0.25 s fade); a pause silences it at once; Continue picks it
  up at the next grab; Restart and Play again start from the song's start.
- No backing in the drill but the lead-in; no arrangements; no backing at a fixed tempo.
- No commits. Typed GDScript, tabs, `##` comments in the project's plain voice.
- Bot runs: the piano-sound plan's `check.sh` with `backing:` added to its grep.

## Decided here

- **Rows:** song boards: `Backing` after `Sign` (shown when the part has something to back:
  not Treble + chords, and not Treble/Bass on a song without chords); drill board: `Backing`
  after `Every` (always shown); pause menu: `Backing` where `YourNotes` was (shown as on the
  board, and always in the drill). Caption "Backing", an on/off toggle.
- **Lead-in notes ring** until the moment the chord is due (four steps after the first).
- **Chords in a fall:** let go; the next grab of a chord-starting branch sounds its chord.
- **At the end** (the nest): the backing is let go.

## Review Focus

1. **Learn mode, Chords only, a chord played late** (the gorilla waited at the branch's end):
   the next tune note comes when the gorilla moves on, not at the old beat.
2. **A fall in Play mode, Treble clef**: the chord sounding is let go; the retried branch's
   chord sounds again when grabbed.
3. **Backing switched off in the pause menu, then Continue**: nothing more sounds; on again,
   it comes back at the next grab.
4. **The drill paused while a lead-in rings**: silent at once; after Continue at a log, the
   lead-in repeats every 4 beats.
5. **Switching the part on the board** (Treble + chords ↔ Treble): the Backing row hides and
   shows, and the pause menu agrees.

Tests: 1 → Task 2 row `--learn --chords-only`; 2 → Task 2 row `--bpm=120` (falls twice, counts
chords per grab); 3 → Task 2 step 1 headless check; 4 → Task 3 row `--drill --pause`;
5 → Task 2 step 1 headless check.

---

### Task 1: No more Your notes; the song player driven by grabs

**Files:** Modify `scripts/piano_sound.gd`, `scripts/song_player.gd`, `scripts/game.gd`,
`scripts/note_input.gd` (velocity out again), `scripts/pause_menu.gd`, `scripts/hud.gd`,
`main.tscn` (no `YourNotes` node; the pause row is renamed in Task 2),
`scripts/dev_autoplay.gd`, `scripts/dev_sound_check.gd`, `README.md`.

**Interfaces — Produces:**
- `PianoSound.strike_due(midi: int, velocity: int, due_ms: float) -> int` and
  `const CATCH_UP_MS := 10.0` (moved from SongPlayer).
- `SongPlayer.load_song(notes: Array[Song.Note], tune := true, chords := true) -> void`;
  `grab(branch: int, grab_ms: float, beat_ms: float) -> void` (that branch's sounds from
  `grab_ms`, unless already started for a grab at that same time; pending sounds of other
  branches dropped); `expect(branch: int, at_ms: float) -> void` (schedules that branch's
  sounds); `let_go() -> void` (ringing voices fade, nothing pending); `stop()`; `play()`;
  `sounding()`; `played` (`{branch, chord, heard_ms}`). `follow()` is gone.

- [ ] **Step 1: Failing checks** in `dev_sound_check.gd`: drop the Your notes part; add
  `load_song(twinkle, false, true)` → only chord sounds; `load_song(twinkle, true, false)` →
  only tune sounds; `grab(0, now - 5000, 500)` then two frames → `played` holds branch 0 only;
  `expect(1, now - 4000)` → branch 1 joins; `grab(1, now - 4000, 500)` → branch 1 not played
  twice; `grab(0, now - 100, 500)` again → branch 0 played a second time (a regrab);
  `let_go()` → after 0.35 s `sounding() == 0`. The game has no `own_notes`.
- [ ] **Step 2: Run** — Expected: `sound check: failed` (no `grab`).
- [ ] **Step 3: Implement**; Listen uses `expect(0, lead)` and, at each grab, `grab()` then
  `expect(next)` (while listening, always). Bot: no `--your-notes`, no `_check_own_notes`.
- [ ] **Step 4: Run** — `sound check: ok`; suite rows (no `--your-notes=off`) pass, Listen
  rows within 20 ms.

### Task 2: Backing in the songs

**Files:** `scripts/game.gd`, `scripts/main_menu.gd`, `scripts/pause_menu.gd`, `scripts/hud.gd`,
`main.tscn` (rows), `scripts/dev_autoplay.gd`, `scripts/dev_sound_check.gd`, `README.md`.

**Interfaces — Produces:** `game.backing: bool` (default true), `game.set_backing(on: bool)`,
`game.backing_part() -> String` (`"chords"`, `"tune"`, `"lead-in"` in the drill, or `""`);
`main_menu` `signal backing_toggled(on: bool)`, `show_backing(shown: bool)`,
`set_backing(on: bool)`; `hud` the same pass-throughs; `pause_menu.open()` takes
`backing_shown: bool, backing: bool` in place of `your_notes`.

- [ ] **Step 1: Failing checks.**
  - Headless (`dev_sound_check.gd`, on the instanced game): Treble part on Twinkle →
    `backing_part() == "chords"` and the song board's Backing row visible; Treble + chords →
    `""` and hidden; Chords only → `"tune"`; Treble on song 8 (no chords) → `""`; the drill
    → `"lead-in"`. `set_backing(false)` while a song runs, `_grab(0, now, false)` → nothing
    played; `set_backing(true)`, `_grab(…)` → played.
  - Bot: `--backing` (explicitly on); every `--autoplay` run counts the gorilla's grabs (a
    new grab: HANG entered, or a new `cur`) and at the end, by `backing_part()`: `"chords"` →
    chord sounds == grabs of chord-starting branches, print `backing: <n> chords sounded`;
    `"tune"` → tune sounds == grabs, `backing: <n> tune notes sounded`; `""` → nothing played
    and the song board's Backing row hidden, `backing: none for this part`. With `--pause`,
    halfway through the first pause: `song_player.sounding() == 0`, print
    `backing: silent while paused`. The pause walk to Chord sign goes one row more when the
    Backing row shows. The `--menu` board step expects the row below Part to be `Backing`
    when it shows.
- [ ] **Step 2: Run** — Expected: errors (no `backing_part`).
- [ ] **Step 3: Implement.** `restart()` loads the song player with the part's sounds
  (`Song.parse(song, clef, true)`; tune for `"tune"`, chords for `"chords"`), stops it, and
  tells the boards whether the row shows. `_grab()`: with backing on and a `"tune"` or
  `"chords"` part (or listening), `song_player.grab(j, ts, beat_ms())`, then for `"tune"`
  (or listening) `_expect_next()`: the next branch's sounds at `windows(cur, grab_t).next`
  if no log stands before it (listening: always). `_break_log()` calls `_expect_next()` after
  `_catch_up()`. `_fall()` and `_win()`: `let_go()`; `pause()`: `stop()`.
- [ ] **Step 4: Run the suite** — rows added: `--backing --bpm=120` (`backing: … chords
  sounded`), `--chords-only --backing --bpm=120` (`… tune notes sounded`), `--learn --backing
  --bpm=120`, `--learn --chords-only --bpm=120`, `--pause --backing --chords-only --bpm=120`
  (`backing: silent while paused`), `--chords --bpm=120` (`backing: none for this part`).

### Task 3: The drill's lead-in

**Files:** Create `scripts/arpeggio.gd`; modify `scripts/game.gd`, `main.tscn` (node
`Arpeggio`), `scripts/dev_autoplay.gd`, `README.md`.

**Interfaces — Produces:** `arpeggio.gd` (`extends Node`, its own `PianoSound`, −10 dB):
`lead_in(log: int, midis: Array[int], start_ms: float, step_ms: float) -> void` (four notes,
`midis[k]` heard at `start_ms + k * step_ms`, ringing to `start_ms + 4 * step_ms`; replaces a
not-yet-begun lead-in for `log`, leaves a begun one alone, adds a new one after a finished
one); `drop_unstarted() -> void`; `silence() -> void`; `played: Array[Dictionary]`
(`{log, midi, heard_ms}`). `static func notes_of(chord: Song.Chord) -> Array[int]`: root
position moved by octaves into C3–B4; a triad + its root an octave up, a seventh's four notes.

- [ ] **Step 1: Failing check.** Bot, with `--drill`: when the gorilla first hangs on branch
  `j - 1` before a log `j`, note `due_j = windows(j - 1, grab_t).next`; at the end, for every
  log after the first, a lead-in of `notes_of(its chord)` whose last note is heard within
  20 ms of `due_j - 0.5 beat` (`--beats=2`: 0.25 beat), and the first log has one; print
  `drill: lead-in before every log`. With `--beats=1`: only the first log has one, print
  `drill: no lead-in at 1 beat`. With `--pause`: while paused, `arpeggio` sounding 0.
- [ ] **Step 2: Run** — Expected: fail (no `arpeggio.gd`).
- [ ] **Step 3: Implement** in `game.gd` (drill, backing on): at each grab, the lead-in for
  the next standing log `L`: due `grab_t + (notes[L].beat - notes[cur].beat) * beat_ms()`;
  Chord every 1 none, 2–3 the last beat as four sixteenths, 4–8 the last 2 beats as four
  eighths. Each frame while the gorilla waits for log `L`, a repeat: four eighths ending
  `due + 4k` beats (k = 1, 2, …). Waiting from the start of a round, or after Continue, the
  first lead-in starts at once (due = then + 2 beats). `_break_log` → `drop_unstarted()`;
  pause, restart, win, menu → `silence()`.
- [ ] **Step 4: Run the suite** — rows added: `--drill --bpm=120` (`drill: lead-in before
  every log`), `--drill --beats=2 --bpm=120`, `--drill --beats=1 --bpm=120` (`drill: no
  lead-in at 1 beat`), `--drill --pause --bpm=120`.

---

## After the user played it (2026-11-20)

The user: "The backing sound should always play something that is shown. Redo the chord
drill, that the branches shown between chords are also the arpeggio of the following chord."
So Task 3's lead-in is gone (`arpeggio.gd` deleted). `drill.gd` now makes the tune from the
chords: each log on its chord's root, the branches up to the next log that chord's notes
between C4 and C5, low to high (`Drill.arpeggio()`). In the drill Backing is `"tune"`, as
for Chords only: the piano plays each branch as the gorilla grabs it.
