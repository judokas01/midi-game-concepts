# King Gong (Godot): backing, where you play one part and the game plays the other

Design. Project: `godot-implementations/king-gong/`. One of three specs written on
2026-11-19 for later sessions. **It depends on the piano sound spec**
(`2026-11-19-king-gong-piano-sound-design.md`): the piano, its song player and the **Your
notes** toggle come from there, so build that first. The third spec is the song library
(`2026-11-19-king-gong-song-library-design.md`).

## Why

The user wants a mode where you pick a song, play just the melody or just the chords, and
hear the other part played for you. You learn one hand while hearing the whole song.

Here is what exists today (README, "Chords only" and "Learn mode"):

- **Chords only:** the gorilla already plays the tune by itself, on the beat, while you play
  the chords. But the tune is silent: the only sound is the beat tick.
- **Treble clef and Bass clef:** you play the tune, and the song's chords aren't there at
  all.

With the piano sound, the game can play the part you don't.

## Goals

- **A Backing setting**, on or off. It is on by default, since hearing the whole song is
  the point.
  - **Where:** a new row on the Play song / Learn song board, and the same toggle in the
    pause menu.
  - **One setting** for both places, the way Chord sign works: changed in one place, it
    changes in the other.
- **What backing plays depends on the Part:**

  | Part | You play | Backing plays |
  |---|---|---|
  | Treble clef | the tune | the song's chords, below the tune |
  | Bass clef | the tune, in the bass | the song's chords, below the tune |
  | Chords only | the chords | the tune: the gorilla's own notes, now heard |
  | Treble + chords | both | nothing; the row hides |

  A song without chords (Mountain King) has nothing to back in the tune parts, so the row
  hides there too. Rows that don't apply already hide on the board today.
- **When a backing sound plays: when the gorilla takes hold of its branch.**
  - **A chord** sounds when the gorilla grabs the branch it starts on (`Note.chord`).
  - **A tune note** sounds when the gorilla grabs that note's own branch.
  - This one rule works in both modes, and follows the player the way the beat tick does
    (`metronome.gd` counts the beat from each grab):
    - **Play mode, Treble or Bass:** you grab by playing the note, so its chord comes in
      with your note, like a left hand following the right.
    - **Play mode, Chords only:** the gorilla grabs on the beat, so the tune is heard on the
      beat.
    - **Learn mode:** nothing is timed. The chord comes when you play the note, and the tune
      note when the gorilla moves on.
- **How long a sound lasts.**
  - A tune note rings for its branch's beats at the current tempo, then is let go.
  - A chord rings until the next chord comes in. Whether it is struck again at bar lines
    follows the song player's rule (piano sound spec).
- **When the gorilla falls,** the backing sounding at that moment is let go. After the
  magic banana it comes back with the next grab.
- **Pausing** silences the backing, and Continue picks it up at the next grab.
- **Restart and Play again** start the backing from the song's start.
- **Loudness:** the backing is a little quieter than your own notes (piano sound spec, the
  mix).
- **Your notes** (piano sound spec) are separate from this. Backing only plays the part you
  don't.

## Non-goals

- No backing in the chord drill. Its tune is the chord's own notes.
- No arrangements, drum beats or bass lines. Backing is the song's own other part.
- No choice of instrument.
- No backing that keeps a fixed tempo regardless of you, like a band that doesn't wait. The
  game's beat already re-counts from every grab, so a fixed one would drift away from what
  the level shows.

## Approaches

The user asked for "a new mode". How it appears in the menus is my call, and **the user
should confirm it before planning**:

- **Recommended: a Backing on/off row on the song boards and in the pause menu.** The Part
  row already says whether you play the melody, the chords or both, so one switch is all it
  takes. It works in Play and Learn alike.
- **Two more Part choices, "Melody + backing" and "Chords + backing".** Everything is in
  one row, but the row grows to six choices and repeats what Part and Backing say together.
- **A new plank on the main menu, "Play along".** It would open its own board with Melody
  or Chords. This gives the clearest entry for a newcomer, but it duplicates the song board:
  the songs, the sign and the practice options.

## Design notes

- **Tie each backing sound to the moment the game registers a grab,** so nothing can drift
  between the picture and the sound. Today that is `_grab()` in `game.gd`, and the gorilla's
  own grabs when `by_itself`.
- **Builder's call:** how the board fits one more row, and the row's caption.

## Check

The dev bot (`scripts/dev_autoplay.gd`) gets a `--backing` flag that turns Backing on (it is
on by default, so the flag makes it explicit), and checks:

- **`--backing --bpm=120`** (Treble, Play). It counts the chords sounded and checks the
  count against the grabs on chord-starting branches. It prints `backing: <n> chords sounded`.
- **`--chords-only --backing --bpm=120`.** It counts the tune notes sounded against the
  gorilla's grabs and prints `backing: <n> tune notes sounded`.
- **`--learn --backing --bpm=120`.** The same count as the first, in Learn mode.
- **`--pause --backing --chords-only --bpm=120`.** It checks no backing voice sounds while
  paused, and prints `backing: silent while paused`.
- **A run with Treble + chords.** It checks that the Backing row is hidden and nothing is
  backed.
- **README.** Add a section for backing next to "Chords only", and update the controls
  table, the pause menu's list and the bot's flags.
