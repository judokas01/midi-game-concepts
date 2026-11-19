# King Gong (Godot): the chord drill plays the next chord before you do

Short design. Project: `godot-implementations/king-gong/`.

## Why

The user asked for this: "we can play a melody in chord drill to motivate to play the
correct chord. My first idea is to just play an arpeggio of the upcoming chord."

Today the drill is silent except for the beat tick. The README says this is on purpose:
"The only sound is the beat tick. You hear your own instrument." The gorilla climbs a
made-up tune of each chord's notes, but you never hear it. An arpeggio just before each log
gives the player something to answer: the game plays the chord's notes one by one, and the
player's chord comes in on the beat. It also links the chord's name and keys to its sound.

The user didn't settle whether the sound should be a hint (you hear the chord before you
play it) or a reward (the right chord makes the music complete). This design builds their
first idea and keeps the rest out. Approaches lists the next thing to try if it falls flat.

## Goals

- **A lead-in before each log.** As the gorilla nears a log that is still standing, the game
  plays that log's chord as a four-note arpeggio. It ends just before the chord is due, and
  the player's chord answers on the beat.
- **Again while it waits.** While the gorilla waits at a log, the lead-in comes again every
  4 beats until the chord is played.
- **The notes:** the keys the little keyboard lights for that chord (root position, moved
  by octaves to sit between C3 and B4), from low to high:
  - a triad: root, third, fifth, then the root an octave up;
  - a seventh chord: its four notes.

  These are the same notes whether Keyboard hint is on or off.
- **Only in the chord drill.**

## Non-goals

- No sound for the player's own notes, on the computer keyboard either.
- The gorilla's tune stays silent.
- Not in Chords only, or in Learn mode with chords. If the drill shows it works, it can
  come to those modes next.
- No on/off setting this round. The Beat tick toggle doesn't affect it.
- No recorded samples this round. If the made-in-code tone is what spoils it, a CC0
  marimba or piano sample set is the next step. Under the project's assets rule, look for a
  human-made set first.

## Approaches

- **A lead-in arpeggio of the next chord.** This is the user's first idea, and the one
  built here. It is a call and an answer, and a quick player hears it every time.
- **The gorilla sings its tune.** Each branch's note sounds as the gorilla grabs it, which
  makes a melody of the chord you just played. This is a reward rather than a preview: the
  right chord lets the song go on. It is the next thing to try if the lead-in doesn't
  motivate, or it can be added alongside the lead-in.
- **An arpeggio only while waiting.** This would be a pure hint. A quick player never stops
  at a log, so they would never hear it, and the drill wouldn't sound any more like music.
  Left out.

## Behaviour

**When the lead-in plays** depends on how far apart the chords are (Chord every):

| Chord every | Lead-in |
| --- | --- |
| 1 beat | None while climbing, because it would start on top of the chord just played. It is heard only while waiting |
| 2 or 3 beats | The last beat before the log, as four sixteenths |
| 4 to 8 beats (4 by default) | The last 2 beats before the log, as four eighths |

- **The beat:** the lead-in keeps the gorilla's beat, the same beat the tick counts. That
  beat restarts after a wait at a log or after a pause, so the lead-in is timed from the
  gorilla's own grabs, the way the tick is, and not from the start of the round. It follows
  the pause menu's Tempo.
- **While waiting:** the lead-in repeats as if the log were due again 4 beats later, so it
  ends 4, 8, 12… beats after the moment the chord was first due. A repeat is always four
  eighths over the last 2 of those 4 beats, whatever Chord every is.
- **The first chord:** at the start of a round the gorilla waits at the first log from the
  start. The first lead-in, four eighths, starts at once, then repeats every 4 beats.
- **When the chord is played:** if a lead-in is already sounding, it plays to its end. Its
  notes are the chord just played, so they agree with it. A lead-in that hasn't started yet
  is dropped.
- **A wrong chord** changes nothing: the lead-ins carry on.
- **Pause, restart, a new round, winning, or going back to the menu** silence it at once.
  When the game continues after a pause, the same rules apply again: if the gorilla waits at
  a log, the lead-in repeats; if it climbs, the next lead-in comes on time.

## Sound

- The tone is made in code, as the tick is: a soft wooden mallet, like a marimba. It has a
  sine fundamental, a quieter partial about four times higher, a quick attack, and a decay
  of about 0.8 s. A jungle game suits a wooden sound, and this needs no asset.
- Notes overlap as they ring, so the voice has to mix them.
- Loudness: clearly heard over the beat tick, but quieter than a keyboard at normal volume.
  The builder tunes it; the user judges it.

## Design

- **A new node, `scripts/arpeggio.gd`**, next to the Metronome. It has its own
  `AudioStreamGenerator`, mixes overlapping notes, and places each note on an exact sample
  frame using the same clock mapping as `metronome.gd` (`_frame_at`). It must not share the
  metronome's player: `cancel_ticks()` restarts that player at every grab, which would cut
  the notes off.
- **`game.gd`:** in the drill, at each grab it schedules the lead-in for the next standing
  log, from that grab's time and the beats left before the log. When a log breaks, it drops
  any lead-in that hasn't started. While the gorilla waits, it keeps the repeats scheduled.
  On pause, restart, a win or going back to the menu, it silences the voice.
- **README:** update "The only sound is the beat tick" under Differences from the spike,
  update the Chord drill section, and add `arpeggio.gd` to the table in How it is put
  together.
- **Builder's calls:** the exact tone and level; whether the shared frame-clock code is
  copied or moved into a small shared helper (it is all one project, so either is fine).

## Check

- `--autoplay --drill` still prints `WON falls=0 bananas=4 misses=1`. It also prints
  `drill: lead-in before every log` once each log after the first has had a lead-in made of
  its chord's lit keys, ending half a beat before the log was due. With `--beats=2` it ends
  a quarter beat before. With `--beats=1` only the first chord's lead-in plays, and the
  check prints `drill: no lead-in at 1 beat`. (The bot plays each drill chord 400 ms after
  the gorilla reaches the log, so the gorilla always waits, but never long enough for a
  repeat at 60 or 120 BPM.)
- Every other `--autoplay` mode plays no arpeggio and gives the same results as now.
- Whether it motivates is the user's call, by playing a round.
