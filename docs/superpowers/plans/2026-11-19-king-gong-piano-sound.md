# King Gong: a real piano sound, and Listen — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Your notes sound on a sampled acoustic piano (on by default on the computer keyboard,
off with a MIDI device, a pause-menu toggle), and a Listen button on the song boards plays
the chosen song, tune and chords, while the gorilla climbs it on the beat.

**Architecture:** `piano_sound.gd` is one piano: 30 Salamander samples (one every minor third,
A0 to C8, pitched ±1 semitone for the notes between) played on a pool of 32
`AudioStreamPlayer` voices, so the AudioServer mixes them natively and ramps each voice's
volume smoothly for the 0.25 s release. `song_player.gd` turns a song's notes into sounds
(the tune, and each chord voiced below the note it starts on) and starts each one so that it
is heard on its beat, counted from the last grab the way the beat tick is. `game.gd` plays
your notes on one piano, and runs Listen: the level as the part shows it, the gorilla by
itself, logs breaking as it reaches them, nothing counted.

**Tech Stack:** Godot 4.7.2, typed GDScript, Ogg Vorbis samples, `main.tscn`.

**Spec:** [docs/superpowers/specs/2026-11-19-king-gong-piano-sound-design.md](../specs/2026-11-19-king-gong-piano-sound-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`; paths below are relative to it.
- Godot: `C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe` (console build `…_console.exe` for
  headless checks). Never kill Godot processes you didn't start.
- Range C2 to C6 at least; at least 16 notes at once; a let-go fades in about 0.2 to 0.3 s.
- Your notes: computer keyboard on by default, MIDI off; the player's choice holds until the
  game is closed. MIDI velocity sets loudness; a computer key is a fixed medium-loud level.
- Starts aimed by the audio clock (`AudioServer.get_time_to_next_mix()`,
  `get_output_latency()`), never accumulated `delta`. Listen: worst ≤ 20 ms off the beat.
- No sound effects, no synth, no other instruments, no sustain pedal, no Listen from the
  pause menu or mid-song.
- Samples: human-made, licence read, a credit line per downloaded file in `art/CREDITS.md`.
- No commits. The user commits their own work.
- Code style: typed GDScript, tabs, `##` doc comments in the project's plain-English voice.
- Bot runs: the menu-selection plan's `check.sh`, with `sound:` and `listen:` added to its grep.

## Decided here (the spec's builder's calls)

- **Samples:** the Tone.js export of the Salamander Grand Piano (Alexander Holm, CC-BY 3.0),
  `https://raw.githubusercontent.com/Tonejs/audio/master/salamander/<name>.ogg`, all 30
  (A0, C1, Ds1, Fs1, A1 … A7, C8), stereo 44.1 kHz, 6.7 MB, one velocity layer. Already
  downloaded to `sounds/piano/` and imported while planning. The whole keyboard, because
  in the bass clef a chord voiced below the tune reaches F1 (Ode to Joy in F), and a MIDI
  piano with Your notes on can play any key.
- **Voices:** a pool of `AudioStreamPlayer`s, not `AudioStreamPolyphonic`: in 4.7 the
  polyphonic mixer sets `prev_volume_db` before reading it, so a voice's volume changes in
  steps once a frame (a stepped, clicking release); the AudioServer lerps an
  `AudioStreamPlayer`'s volume across each mix buffer. Same native mixing, same timing.
- **Levels:** loudness `linear_to_db(velocity / 127)`; your notes' piano −6 dB, the song
  player's −10 dB; tune notes velocity 96, chord notes 60. The tick (peaks −21/−16 dBFS, a
  pure tone) is unchanged; the samples peak about −8 to −12 dBFS.
- **Chords** ring until the next chord (or the song's end), struck once; voiced from
  `Chord.midi` moved down by octaves until no note is above the tune note they start on.
- **Listen:** the gorilla sits on the stump 0.8 s, then grabs the first branch; at the nest it
  waits 1 s, then the board. Logs (with a chords part) break as the gorilla reaches them.
  A banner says "Listening · any key stops". The selection comes back on Start.
- **The foot of the song boards:** Back · Listen · Start, Listen a plank in the middle.
- **Your notes row:** in the pause menu right after Beat tick.

## Review Focus

1. **A key let go while paused, or on a menu**: its voice still fades out; no note sticks.
   (`game.note_off` returns early while paused, so the release must come before that.)
2. **Stopping Listen with a click over the board's Start**, or with the MIDI note A or B: the
   board comes back and nothing on it is pressed by the same click or note.
3. **Listen from the Learn song board, in the bass clef, with rests and eighths** (Für Elise
   at 120 BPM): the gorilla never stops at a log, the chords sound under the tune, the
   timing holds.
4. **More than 32 voices** (a chord key held, a tune, releases still fading): the oldest
   voice is taken over, no error, nothing stuck.
5. **A MIDI device used after the computer keyboard, Your notes untouched**: the MIDI notes
   are silent from the first one, the computer keys sound again when used again.

Tests: 1 → Task 1 step 1 (`note_off` while paused releases); 2 → Task 3 step 1 (a key and a
note stop Listen without pressing Start); 3 → Task 3 suite rows; 4 → Task 1 step 1 (40
strikes on 32 voices); 5 → Task 1 step 1 (`your_notes_on()` follows `note_input.source`).

---

### Task 1: The piano, and your notes on it

**Files:**
- Create: `scripts/piano_sound.gd`, `scripts/dev_sound_check.gd`
- Modify: `scripts/note_input.gd` (velocity), `scripts/game.gd` (your notes), `scripts/pause_menu.gd`,
  `scripts/hud.gd`, `main.tscn` (node `YourNotes`, pause row `YourNotes`), `scripts/dev_autoplay.gd`,
  `art/CREDITS.md`, `README.md`
- Already in place: `sounds/piano/*.ogg` and their `.import` files

**Interfaces — Produces:**
- `piano_sound.gd` (`extends Node`): `@export var volume_db := 0.0`; `var started := 0`
  (voices started, for the checks); `const VOICES := 32`, `const RELEASE_S := 0.25`;
  `static func sample_count() -> int`; `static func sample_for(midi: int) -> int` (the
  nearest sampled note, clamped to 21–108); `static func heard_ms() -> float`
  (`Time.get_ticks_usec() / 1000.0 + (get_time_to_next_mix() + get_output_latency()) * 1000.0`);
  `func strike(midi: int, velocity: int) -> int` (voice id, starts now; takes over the voice
  struck longest ago when all are busy); `func release(id: int) -> void` (fades `RELEASE_S`,
  then stops; a voice taken over since is left alone); `func silence() -> void` (all, at
  once); `func sounding() -> int`.
- `note_input.gd`: `signal note_on(midi: int, t_ms: float, velocity: int)`,
  `const KEY_VELOCITY := 96`.
- `game.gd`: `func note_on(m: int, ts: float, velocity := NoteInput.KEY_VELOCITY) -> void`;
  `func your_notes_on() -> bool`; `func set_your_notes(on: bool) -> void`;
  `@onready var own_notes: PianoSound = $YourNotes`.
- `pause_menu.gd`: `signal your_notes_toggled(on: bool)`; `open()` gains `your_notes: bool`
  after `tick`. `hud.gd` passes both through (`your_notes_toggled`, `open_pause`).

- [ ] **Step 1: Write the failing checks**
  - `dev_sound_check.gd` (headless, `extends SceneTree`, like `dev_cursor_check.gd`; prints
    `sound check: ok` or `sound check: failed`, `push_error("sound: not so: …")` per rule):
    `PianoSound.sample_count() == 30`; for every midi 21–108, `absi(midi - sample_for(midi)) <= 1`;
    a `PianoSound` in the tree: 20 strikes → `sounding() == 20`; 40 strikes → `sounding() == 32`
    and no error; `release(id)` then 0.35 s → that voice no longer counts; `silence()` → 0.
    A game check: instance `main.tscn`, set `note_input.source = "keyboard"`:
    `your_notes_on()`; `"MIDI"`: not; `set_your_notes(true)` then `"MIDI"`: on;
    with it on, `note_on(60, t)` raises `own_notes.started` by 1, and `get_tree().paused = true`
    then `note_off(60, t)` → after 0.35 s `own_notes.sounding() == 0`.
  - `dev_autoplay.gd`: in `_ready`, `print("sound: piano ready (%d samples)" % PianoSound.sample_count())`;
    `--your-notes=off` calls `game.set_your_notes(false)` (deferred); every `game.note_on` the bot
    makes for the song (`_press`, `_strike`, the held-over note) goes through one helper that
    counts `_played`; at the end (beside `_check_counters`): off → expect `own_notes.started == 0`
    and print `sound: your notes silent`; else expect `started == _played` and print
    `sound: your notes heard`. The first pause expects the `YourNotes` toggle to show
    `your_notes_on()`; its chords walk goes 4 rows down (Tick, Your notes, Labels, Chord sign).
  - `game.gd`'s `dev_flags` accepts `--your-notes=…`.

- [ ] **Step 2: Run them to see them fail**
  Run: `"…_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_sound_check.gd`
  Expected: errors (no `piano_sound.gd`), not `sound check: ok`.

- [ ] **Step 3: Implement**
  - `piano_sound.gd` as in Interfaces: samples loaded once into a static dictionary from
    `res://sounds/piano/<C|Ds|Fs|A><octave>.ogg`; `pitch_scale = pow(2, (midi - sample) / 12.0)`;
    `volume_db = self.volume_db + linear_to_db(velocity / 127.0)`; the release a tween on the
    player's `volume_db` down 40 dB, then `stop()`.
  - `note_input.gd` emits the MIDI velocity, `KEY_VELOCITY` for a computer key or chord key.
  - `game.gd`: your note sounds first thing in `note_on` (if `your_notes_on()`; a note struck
    again lets its last voice go), and is let go first thing in `note_off`, before any return.
    `_your_notes := -1` (follows `note_input.source == "keyboard"`), 1 on, 0 off.
  - `main.tscn`: `YourNotes` (Node, `piano_sound.gd`, `process_mode = 3`, `volume_db = -6.0`);
    the pause row `YourNotes` (Caption "Your notes", Toggle) after `Tick`, in `cursor_rows()`
    after the tick row. `pause()` passes `your_notes_on()`; the toggle calls `set_your_notes`.
  - `art/CREDITS.md`: a "Sounds" section — the intro no longer says "No third-party assets" —
    one table row per file: `sounds/piano/<file>`, its raw URL above, "Alexander Holm (Salamander
    Grand Piano V3), Ogg export by the Tone.js project", CC-BY 3.0
    (`https://creativecommons.org/licenses/by/3.0/`).
  - README: the "only sound is the beat tick" note becomes the piano and Your notes; the
    controls table and the pause menu's list get Your notes; the file map gets
    `piano_sound.gd` and `sounds/piano/`; the dev check gets `dev_sound_check.gd`,
    `--your-notes=off` and the two `sound:` lines.

- [ ] **Step 4: Run the checks and the suite**
  Expected: `sound check: ok`; `--bpm=120` prints `sound: piano ready (30 samples)` and
  `sound: your notes heard`; `--bpm=120 --your-notes=off` prints `sound: your notes silent`;
  the menu-selection suite's seven rows and the cursor check still pass.

### Task 2: The song player

**Files:**
- Create: `scripts/song_player.gd`
- Modify: `main.tscn` (node `SongPlayer` with child `Piano`, `piano_sound.gd`, `volume_db = -10.0`),
  `scripts/dev_sound_check.gd`, `README.md` (file map)

**Interfaces:**
- Consumes: Task 1's `PianoSound` (`strike`, `release`, `silence`, `sounding`, `heard_ms`).
- Produces (`song_player.gd`, `extends Node`):
  - `class Sound`: `branch: int`, `beat: float`, `beats: float` (how long it rings),
    `midi: Array[int]`, `chord: bool`.
  - `var sounds: Array[Sound]`; `var played: Array[Dictionary]` — `{branch, chord, heard_ms}`
    per sound started, for the checks.
  - `func load_song(notes: Array[Song.Note]) -> void` — per branch, its chord (if
    `note.chord`) then its tune note; a chord rings to the next chord's beat or the song's end.
  - `static func voiced(chord: Song.Chord, under: int) -> Array[int]` — `chord.midi` moved down
    by octaves until its top note is not above `under`.
  - `func follow(branch: int, grab_ms: float, beat_ms: float) -> void` — inside a level:
    `branch` is grabbed at `grab_ms`; its sounds not yet started and the next branch's are
    due at `grab_ms + (beat - branch's beat) * beat_ms`; earlier unstarted ones are dropped;
    nothing further is scheduled until the next `follow`, as the tick schedules to the next
    grab.
  - `func play(beat_ms: float, at_ms: float) -> void` — outside a level: the whole song from
    its start, branch 0 due at `at_ms`.
  - `func stop() -> void` — nothing more starts; every voice stops at once.
  - `func sounding() -> int`.
  - Each frame a due sound starts when `due <= PianoSound.heard_ms() + frame_ms / 2`; a tune
    note is released `beats * beat_ms` after its due time, a chord when the next chord starts
    or after its `beats`.

- [ ] **Step 1: Write the failing checks** in `dev_sound_check.gd`:
  `voiced(parse_chord("F"), 41) == [29, 33, 36]`; `voiced(parse_chord("C"), 60) == [48, 52, 55]`;
  `voiced(parse_chord("C"), 55) == [48, 52, 55]` (a note level with the tune is not above it);
  `voiced(parse_chord("C"), 50) == [36, 40, 43]`; Twinkle (`Song.parse(0, TREBLE, true)`)
  loads `notes.size()` tune sounds and one chord sound per chord note, the first chord's
  `beats` = the second chord's beat; Mountain King (`Song.parse(8, …, true)`) loads no chords;
  in the tree, `follow(0, now - 5000, 500)` then two frames → `played` holds branches 0 and 1
  only; `stop()` → `sounding() == 0` and a further frame starts nothing.

- [ ] **Step 2: Run to see it fail** — Expected: errors (no `song_player.gd`).

- [ ] **Step 3: Implement** `song_player.gd` per Interfaces; add the `SongPlayer` node.

- [ ] **Step 4: Run** — Expected: `sound check: ok`; the suite still passes.

### Task 3: Listen

**Files:**
- Modify: `main.tscn` (Songs board `Foot/Listen`, a `Plank` with `plank.gd`, 140×44, font 18,
  "Listen", between `Gap` and a second gap before `Start`), `scripts/main_menu.gd`,
  `scripts/hud.gd`, `scripts/game.gd`, `scripts/dev_autoplay.gd`, `README.md`

**Interfaces:**
- Consumes: Task 2's `load_song`, `follow`, `stop`, `played`, `sounding`.
- Produces: `main_menu.gd` `signal listen_pressed`; the song boards' foot row is
  `cells([Back, Listen, Start], 2)`, the drill board's stays `[Back, Start], 1`. `hud.gd`
  `signal listen_pressed`. `game.gd`: `var listening := false`, `func listen() -> void`,
  `@onready var song_player: SongPlayer = $SongPlayer`, `const LISTEN_LEAD_MS := 800.0`,
  `const NEST_MS := 1000.0`.

- [ ] **Step 1: Write the failing check** — `dev_autoplay.gd --listen` (and in `dev_flags`):
  opens the board for its page (Play, or Learn with `--learn`), `E` → expect Listen selected
  and lit, `A`. While `game.listening`: record `game.grab_t` per branch the first frame it
  hangs on it; expect no queued tick (`game.metronome._ticks.is_empty()`), falls and misses 0,
  bananas as at the start, no end panel. When the board is back: expect it is the same page,
  on Start; from `game.song_player.played` count tune sounds `n` and chords `m`, expect them
  equal to `Song.parse(game.song, game.clef, true)`'s notes and chord notes, and every
  `heard_ms - grab[branch]` within 20 ms; print
  `listen: <n> notes, <m> chords, worst <x> ms off the beat`. Then Listen again (E, A), 1.5 s
  later `_key(KEY_Q)`: expect the board back on Start, not started, `song_player.sounding() == 0`;
  print `listen: a key stops it`. Listen a third time, 1 s later the MIDI note A: the board is
  back and the song is not started; print `listen: a note stops it`; quit.
  The `--menu` foot walk becomes one step per foot button: Start lit → E → (Listen lit → E →)
  Back lit → F to Start; `menu: looks ok` after the last.

- [ ] **Step 2: Run to see it fail**
  Run: `check.sh "listen: a note stops it" --listen --bpm=120`. Expected: FAIL (no Listen).

- [ ] **Step 3: Implement**
  - `listen()`: `started` and `listening` true, menu hidden, `restart()` (by itself while
    listening), `song_player.load_song(Song.parse(song, clef, true))`,
    `follow(0, now + LISTEN_LEAD_MS, beat_ms())`, the banner.
  - In `_play_tune`, while listening: on the stump wait for the lead, then grab at exactly
    that time; a standing log before a branch breaks (`_break_log`) as the gorilla grabs it;
    never wait at the end of a branch (also in Learn mode). `_grab` calls `song_player.follow`
    and schedules no tick while listening. `_complete` takes no banana while listening.
    `_win` while listening: the hop to the nest, no end panel; `NEST_MS` later the board.
  - Stopping (`_stop_listening() -> bool`): `song_player.stop()`, `listening = false`,
    `show_menu()`. Called first in `note_on` (that note then counts as a menu note, so its
    let-go is ignored), in the Space, Enter, Esc and arrow handlers, and in `game._input` for
    any other key or a mouse press, which it marks handled so the board under the pointer
    gets no press.
  - README: controls table (Listen), a "Listen" section by "Learning", the board foot, the
    `--listen` flag, the file map (`song_player.gd`).

- [ ] **Step 4: Run the suite**
  Rows added: `--listen --bpm=120` (Twinkle), `--listen --learn --bass --song=9 --bpm=120`
  (Für Elise, bass clef, Learn board), `--listen --song=8 --bpm=120` (Mountain King, no
  chords: `0 chords`). Each prints its `listen:` line and both stop lines, no errors.
  Expected: every row and the earlier ones pass.
