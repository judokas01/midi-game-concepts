# King Gong (Godot): a real piano sound, and Listen

Design. Project: `godot-implementations/king-gong/`. One of three specs written on
2026-11-19 for later sessions. The other two are the song library
(`2026-11-19-king-gong-song-library-design.md`), whose preview uses the song player
described here, and backing (`2026-11-19-king-gong-backing-design.md`), which is built on it.

## Why

Commit `0b732e3` ("removed synth", 2026-10-28) took out `scripts/synth.gd`. That code made
the note sounds and effects in code, and was dropped because a player at a digital piano
hears their own instrument. Since then the only sound has been the beat tick
(`scripts/metronome.gd`). Two things are missing:

- **On the computer keyboard you hear nothing** but the tick.
- **Nobody can hear how a song should go** before playing it.

The user wants the notes back as a **real piano sound, not a synth**, and a way to **listen
to how a song should be played**. The same sound and the same way of playing a song also
serve the library's 10-second preview and the backing mode.

## Goals

- **A sampled acoustic piano.** Recordings of a real piano, not synthesis.
  - **Range:** it covers every note the game can ask for, C2 (the lowest chord voicing)
    to C6.
  - **Chords:** at least 16 notes can sound at once.
  - **Held notes:** a held note rings and decays as a piano's does. When it's let go, it
    fades in about 0.2 to 0.3 s, like a piano without the pedal.
- **Your own notes.**
  - Your notes sound on the piano.
  - **On the computer keyboard** this is on by default; today you hear nothing there.
  - **With a MIDI device** it is off by default, because a digital piano makes its own
    sound. That was the reason the synth went.
  - **The setting:** a pause-menu toggle, **Your notes**. Its default follows the live
    input (keyboard on, MIDI off). Once the player changes it, their choice holds until the
    game is closed.
  - **Loudness:** a MIDI note's velocity sets it. A computer key plays at a fixed,
    medium-loud level.
- **A song player.** It plays a song's notes on the piano: the tune, the chords, or both.
  - It can stop at once.
  - **Inside a level** it keeps time the way the beat tick does: **counted from the last
    grab**. `metronome.gd` schedules the ticks from each grab (`schedule_ticks`), so the
    game's beat follows the player, and the player follows it the same way.
  - **Outside a level** (the library preview) it plays from the song's start at the tempo.
  - It is used by Listen (below), the library preview and backing.
- **Listen**, on the song boards.
  - **Where:** the foot of the Play song / Learn song board becomes Back · Listen · Start.
  - **What happens:** Listen starts the chosen song with the chosen part, but the gorilla
    climbs by itself on the beat, as in Chords only in Play mode, and never waits at a log.
    The piano plays the tune and its chords. A song without chords plays its tune.
  - **Tempo:** the current tempo.
  - **Octave:** the chosen part's. In the bass clef the tune sounds where the bass clef puts
    it.
  - **Nothing counts:** no falls, no wrong notes, no bananas collected, no end panel.
  - **How it ends:** at the nest, or as soon as the player presses any key, B, Esc or
    clicks. Either way it goes back to the board.
  - **The beat tick** is silent while listening, because the music carries the beat.
- **Chords sound below the tune.** They are voiced from `Chord.midi` (root position) and
  moved down by octaves so that no chord note is above the tune's note at that moment.
  Builder's call: whether a chord rings until the next chord or is struck again at each bar
  line (`Song.bar_lines()`) while it holds.
- **The mix.**
  - The beat tick stays clearly audible over the piano.
  - What the game plays (Listen, preview, backing) is a little quieter than your own notes.
  - Builder's call: the exact levels.

## Non-goals

- No sound effects. The spike's grab, creak, crack, fall, boing, banana and win stay out,
  as in `0b732e3`.
- No synth. The old `synth.gd` is not restored.
- No other instruments, no instrument choice, no sustain pedal.
- No Listen from the pause menu or mid-song.
- No recording or exporting.

## Approaches (for the sound)

The user asked for a real piano and left the how open, so this is my call.

- **Recommended: recorded samples played through Godot's polyphonic player**
  (`AudioStreamPolyphonic`).
  - One recording every few semitones, pitched up or down for the notes between.
  - Godot mixes them natively, so many voices cost little.
  - A note can start up to one mix block late (about 10 ms), so starts are aimed using the
    audio clock (`AudioServer.get_time_to_next_mix()` and `get_output_latency()`). Accumulated
    `delta` is not used (CLAUDE.md, Godot rhythm timing).
- **Samples mixed by hand into an `AudioStreamGenerator`**, as `metronome.gd` does for the
  tick. This is exact to the sample frame. But mixing and pitching many voices in GDScript at
  44.1 kHz may cost too much CPU. Fall back to this only if the recommended way misses the
  timing check below.
- **A SoundFont player through a GDExtension** (an `.sf2` General MIDI piano). This gives
  good sound and exact timing, but adds a native plugin to build and ship. Not worth it for
  one instrument.

## Samples

- **Rule:** human-made recordings, searched for first, with a free licence (CLAUDE.md,
  Assets). Prefer CC0. CC-BY is fine with a credit line. Read the licence before
  downloading.
- **Candidates to check:**
  - **Salamander Grand Piano** by Alexander Holm, believed to be CC-BY 3.0, so it would
    need a credit line.
  - **The University of Iowa Electronic Music Studios piano recordings** (check the terms
    of use).
  - **CC0 piano packs on Freesound.**
- **Size:** one velocity layer is enough, plus a second only if the loud notes sound
  wrong. Ogg Vorbis, under about 10 MB in all. Builder's call: how many sample points and
  whether they are stereo or mono.
- **Credit:** a line per downloaded file in the project's `art/CREDITS.md` (file, source
  URL, author, licence), written at download time.

## Check

The dev bot (`scripts/dev_autoplay.gd`) gets:

- **In every run:** once the piano is loaded, `sound: piano ready (<n> samples)`.
- **`--listen`.** This starts Listen from the board and lets it play to the nest, then
  prints `listen: <n> notes, <m> chords, worst <x> ms off the beat`. `<n>` and `<m>` are
  the song's own counts. Each sound's offset is when it started (by the audio clock)
  against when its beat falls. The run fails if any count is wrong or `<x>` is over 20 ms.
  How to measure it is the builder's call.
- **Your notes.** A computer-keyboard run checks that the bot's played notes started piano
  voices and prints `sound: your notes heard`. The same run with the toggle off checks that
  they started none.
- **README.** Update the "only sound is the beat tick" note, the controls table (Listen,
  Your notes), the bot's flag list, the file map and the credits.
