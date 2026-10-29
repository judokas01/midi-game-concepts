# King Gong — Godot port

A faithful port of the browser spike in [concepts/002-king-gong](../../concepts/002-king-gong/README.md):
same song (and five more), rules, timing window, tuning and controls, running natively in
Godot 4.7 so the two can be compared. The rules and the fun hypothesis live in the concept
card; nothing here changes them.

## Run it

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path godot-implementations/king-gong
```

Or open the folder in the Godot editor and press F5. Plug the MIDI keyboard in before
launching if you can; if none is found at start-up the game looks again every 2 seconds.

## Controls

| Input | Does what |
| --- | --- |
| MIDI notes | Grab the branch on that note; hold for its length; release to let go. The built-in songs use C4–A4, C3–A3 in the bass clef |
| Keyboard `A S D F G H J K` | C4 D4 E4 F4 G4 A4 B4 C5, moved by octaves to where the song is (an octave lower in the bass clef); fallback when no MIDI device is connected. White keys only: a score's sharps and flats need MIDI |
| MIDI notes below middle C | Treble + chords: the left hand's chord. Any octave and any order, but only its notes. Below the melody's lowest note, if a score goes under middle C. With Chords only and in the chord drill every note is the chord's |
| Keyboard `Z X C V B N M` | With chords: one key per chord, by its root (C D E F G A B). The start screen and the floor list the song's, e.g. `Z` = C, `V` = F, `B` = G. In the chord drill every root plays the kind of chord the next log wants (`X` = Dm when it wants Am) |
| Mode: Play / Learn / Chord drill | On the start screen: play a song, [learn it](#learn-mode) untimed, or [drill chords](#chord-drill) |
| Song `◀` list `▶` | On the start screen: which song to play, the built-in ones and then [your own](#your-own-songs) |
| Part: Treble clef / Bass clef / Treble + chords / Chords only | On the start screen: how to play the song. [Chords only](#chords-only): the gorilla plays the tune, you the chords |
| Chord hint | On the start screen, with chords: the sign on each log shows the chord's name, or its notes in the bass clef. The chord drill always shows the name |
| Chords: Major / Minor / Sevenths / Dim & aug | On the start screen, chord drill: which chords it draws from. Any mix, one at least |
| MIDI note written on a menu button | Picks that button, on the start screen (C3 and D3 step through the songs, E3 to G3 pick the mode, C4 to B4 the rest) and on the end panel (C4 play again, D4 main menu). Computer keys don't; use the mouse |
| `Space` / click / any other MIDI note | Start, on the start screen. The note only starts the game; it grabs nothing |
| `Enter` / Restart button | Restart the song, or in the chord drill a new round |
| `Esc` | Back to the start screen, at any time |
| Practice mode | On the start screen, Play: the magic bananas never run out |
| Keyboard hint | On the start screen, Learn and chord drill: the [little keyboard](#the-little-keyboard) at the bottom. On by default |
| Tempo slider | 40–120 BPM (default 60) |
| Labels / Beat tick | Same toggles as the spike |

Which input is live (MIDI or keyboard) is shown top-right, next to bananas, progress and falls.

## Learning

Two ways to get ready for a level, and a drill for the chords.

### Learn mode

Pick **Learn** on the start screen, then a song and a part. Nothing is timed and the gorilla
can't fall: it hangs on its branch until you play the next branch's note, however long that
takes, then swings over. Rests are jumped. With Treble + chords it also waits at each log
until the left hand plays the chord; the note and the chord can come in either order. A
wrong note or chord only counts: the banner names the right one, the counter top-right says
`wrong`, and the end panel how many there were. Let go of the last note to finish. Bananas
are still there to collect, but there are no magic ones, as there is nothing to fall from.

### Chords only

Pick **Chords only** as the part. The gorilla plays the tune by itself, on the beat, and you
play only the chords, anywhere on the keyboard. In Play mode each chord must come on time,
in the same ±0.35-beat window as a grab, or the gorilla bounces off its log, and magic
bananas work as usual; in Learn mode the gorilla waits at the end of the branch before each
log until you play its chord, and the beat restarts from there.

### Chord drill

Pick **Chord drill**, then which chords: Major, Minor, Sevenths (7, maj7 and m7) and Dim &
aug, in any mix. Each round is a made-up tune of 16 chords drawn at random, on the roots C to
B and never the same twice running, a new one every two beats. The gorilla climbs it by
itself and waits at every log until you play its chord, anywhere on the keyboard. The tune is
the chord's own notes between C4 and C5. A banana hangs at every fourth chord. Restart or
Play again brings 16 new chords.

### The little keyboard

In Learn mode and the chord drill a little piano keyboard at the bottom, in place of the
legend, lights what to play next:

- **The note**, yellow, on the tune's keys: from its lowest note, an octave at least.
- **The chord**, in its log's colour, in root position on two octaves of its own, left of
  the tune's: below the tune with Treble + chords (C2–B3 for the built-in songs), C3–B4
  with Chords only and in the drill. It is lit where the bass-clef hint writes it, moved by
  octaves to fit. Played in any octave and any order it counts all the same; a note held
  outside those two octaves shows on the lit key of its name.

Keys held down show pressed in; a wrong note, or the odd note out of a wrong chord, goes
grey with a red cross. Every C is marked, and with the computer keyboard live its letters
are on the keys. With Chords only and in the drill the next chord lights up as soon as the
last one is played, however far ahead its log is. Turn **Keyboard hint** off on the start
screen to practise reading the notes alone.

## Your own songs

Put MusicXML scores in `songs/`, next to `project.godot`, and restart the game: they join
the song list after the built-in songs, by file name. On musescore.com open the score and
choose Download → MusicXML; in MuseScore Studio, File → Export → MusicXML. Both `.mxl` and
uncompressed `.musicxml` work. `songs/` is ignored by git, so the scores you are licensed
to use stay on your machine.

`scripts/score_import.gd` makes a level of each one:

- **Melody:** the first part's top staff, voice 1, and its top note where it has several.
  In a piano/vocal score that is the vocal line; in a piano arrangement, the right hand.
- **Chords:** the chord symbols, from whichever part has the most. Each becomes a triad:
  sevenths and other extensions are left out, sus and power chords are played as major,
  diminished and augmented stay. A score without chord symbols has no logs.
- **Key and range:** the song moves to C (or A minor) by its first key signature, then by
  octaves to sit on the staff, between the ledger line below it and its top line, or up to
  two steps lower if it must. A melody wider than that (an octave and a sixth) has its top
  notes folded down an octave. Sharps and flats outside the key stay, as `Eb4` or `F#4`.
- **Form:** repeats and first and second endings are played out. D.C., D.S., Fine and
  codas are not; the song runs straight through. An intro before the melody's first note
  is left out. Bar lines follow the score's measures, pickups and 3/4 included.
- **Rhythm:** rounded to sixteenths, triplets too. A rest shorter than an eighth is added
  to the note before it, and grace notes are left out.
- **Bananas:** after every 24 notes, the next note of a beat or more carries one.

A file the importer can't read is left out of the list, with a warning in the console.

## Differences from the spike

- **Branch length is the note length.** The spike shows a 2-beat note as a thick branch.
  Here every branch is equally thick and 2.2 staff steps long per beat, and the level is
  laid out in time: each beat of a note or a rest takes 3 steps across. Durations in
  `song.gd` are in beats and can be any length (`4` whole note, `0.5` eighth note).
  For values the spike's song never uses:
  - The timing window is ±0.35 of a beat, or of the note or its rest when that is shorter,
	so an eighth can't be held like a quarter.
  - A rest is one bounce along the liana per beat, so a long rest can be counted.
  - The beat tick also marks a let-go into a rest that doesn't fall on a whole beat.
- **More songs.** The spike has Twinkle Twinkle. The start screen here also offers, from
  easiest to hardest, Mary's Lamb, Ducklings (Alle meine Entchen), Lightly Row (Hänschen
  klein), Ode to Joy and the chorus of Jingle Bells. All are public domain, written in C,
  one note at a time between C4 and A4, in 4/4 from the first beat. Ode to Joy is its
  first eight bars: the middle part drops to G3, below the range. Ode to Joy and Jingle
  Bells bring dotted notes and eighths. Each song carries the chords songbooks give it,
  as triads: C, F and G, plus D in Jingle Bells (the songbooks' D7) and Dm in Ducklings,
  where songbooks write G7 under four Fs that a G triad lacks. A song is a list in
  `SONGS` in `song.gd`; scores need no code, see [Your own songs](#your-own-songs).
- **Bass clef.** The spike is treble only. Here the start screen also offers the bass
  clef, which plays the song an octave down (C3–A3) so it sits inside the bass staff.
  The level behind the start screen redraws as you choose; the choice holds until you
  quit.
- **Treble + chords.** Also not in the spike. Each song carries its chords (`song.gd`,
  third column), and wherever the chord changes a log stands across the gap before that
  branch, coloured by its chord, with a sign on top. Play the chord in the left hand
  together with the branch's note, in the same ±0.35-beat window as the grab, and the
  gorilla kicks the log down. Too early, too late or the wrong chord and
  the log stays up: the gorilla runs into it, the log shakes, and it counts as a missed
  branch. After a magic banana the log is still there; break it and grab, untimed, like
  any retry. Only the change is played; the chord need not be held. The colours follow
  Boomwhackers by root (C red, D orange, E yellow, F green, G blue, A purple, B pink), a
  minor chord darker. The bass-clef hint writes root position with the root between F2
  and E3, which keeps every chord inside the staff.
- **The branch breaks as you hold it.** In the spike only the swing tells you how long to
  hold, and it is hard to read. Here the branch you hang on breaks away in small pieces from
  its left end, and its last piece, at the right end, falls at the moment to let go. The
  piece under the gorilla's hand holds until you let go. The timing window is unchanged,
  ±0.35 of a beat around the end: hang on past it and that last bit sags, cracks and snaps.
  The swing stays as it was. A reward banana hangs near the right end, from the last piece
  to fall. (A sunbeam and a banana sliding along the branch were tried as cues too; the
  breaking branch read best.)
- **Learning.** Not in the spike: [learn mode](#learn-mode), [chords only](#chords-only),
  the [chord drill](#chord-drill) with sevenths, diminished and augmented chords, and the
  [little keyboard](#the-little-keyboard) that shows what to play.
- **Menus.** The spike has a start overlay and an end message. Here the start screen also
  has practice mode, the end panel offers Play again and Main menu, and every button on
  both carries a MIDI note that picks it, so you never have to leave the piano. The end
  panel ignores notes for 0.8 s, so a note still being played can't pick by accident.
- **Input timing.** Godot input events carry no timestamp, so a note is stamped when the
  event is dispatched, once per frame: about 16 ms of resolution at 60 fps against a
  ±350 ms window at 60 BPM. The spike uses Web MIDI's own timestamps.
- **The only sound is the beat tick.** You hear your own instrument, so there is no note
  synth and none of the spike's effects (grab, creak, crack, fall, boing, banana, win).
  On the computer keyboard that means you hear nothing but the tick. The tick is generated
  in code like the spike's and scheduled on exact sample frames.
- **Fixed layout.** The spike sizes everything from the window height. Here a staff step is
  a fixed 36 px on a 1280×720 canvas and the window scales the whole picture.
- **Small visual liberties.** The floor is drawn in front of the world, so tree trunks and
  liana posts sink into it. A strained branch bends as two halves meeting at the grip,
  not along a curve. The legend fits on the floor strip.
- **Hot-plugging.** A MIDI device plugged in after a device was already found is not
  picked up until restart.
- **No GPU.** If Windows falls back to its software renderer (no working graphics driver),
  vsync stutters at about 40 fps, so the game turns vsync off and caps itself at 60 fps.

## How it is put together

The art is SVG files in `art/`, the pieces are scenes in `scenes/`, and the code only moves
them around:

| Path | What |
| --- | --- |
| `main.tscn` | Sky, parallax layers (canopy, staff-line bushes, clef, floor), the world, camera, HUD with the little keyboard |
| `scenes/branch.tscn` | One note: two halves of bark (Line2Ds) meeting at the grip, end twig and leaves, cracks, banana, label. When the gorilla grabs it, `branch.gd` cuts the bark into the pieces that fall |
| `scenes/liana.tscn` | One rest: two posts, the vine (a Line2D) and its leaves |
| `scenes/chord_log.tscn` | One chord change: the log in two pieces (stump and top), its sign with the name and a small bass staff, splinters and chips |
| `scenes/gorilla.tscn` | Body sprite, scared body, arms (Line2Ds), hands, banana balloon, prompt |
| `scenes/glowing_banana.tscn` | The banana that pops out of the ground or flies to the counter |
| `art/*.svg` | All the art; see `art/CREDITS.md` |
| `ui/` | Theme for the bar and overlay, label styles |
| `scripts/game.gd` | The rules and the gorilla's pose (the same rules as the spike), and learn mode's |
| `scripts/level.gd` | Builds the level from the song: places branches, lianas, trees |
| `scripts/staff.gd` | Where things sit: staff step, line heights, floor |
| `scripts/branch.gd`, `liana.gd`, `chord_log.gd`, `gorilla.gd` | What each of those scenes can do |
| `scripts/song.gd` | The songs and their chords, their parsing into branches, and the two clefs |
| `scripts/drill.gd` | Makes up the chord drill's tune and chords |
| `scripts/piano.gd` | Draws the little keyboard |
| `scripts/score_import.gd` | Reads the MusicXML scores in `songs/` into songs |
| `scripts/metronome.gd` | The beat tick |
| `scripts/note_input.gd` | MIDI and keyboard input |
| `scripts/hud.gd` | Top bar, the two menus and their MIDI notes, messages, what the little keyboard lights |
| `scripts/dev_autoplay.gd` | Dev check only, see below |

Branches, lianas and logs only appear when the game runs, because `level.gd` lays them out
from the song. To change how they look, open `scenes/branch.tscn`, `scenes/liana.tscn` or
`scenes/chord_log.tscn`, or the SVGs.

## Dev check

Arguments after `--` turn on a bot and diagnostics; without them none of it loads. The bot
plays the song on its own. It plays one wrong note and hangs on to one branch until it
breaks, on purpose, so falls, cracks and magic bananas get used too.

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path godot-implementations/king-gong -- --autoplay --perf
```

- `--autoplay` plays the song, prints the result and quits. Expect `WON falls=2 bananas=5`.
- `--song=<n>` plays another song, counting from 0 in the start screen's order. Songs 1
  to 5 hang three bananas, not four, so expect one banana fewer than for song 0.
- `--chords` plays Treble + chords instead. With `--autoplay` the bot also plays each
  chord, once leaves one out and runs into the log: expect `WON falls=3 bananas=4`.
- `--chords-only` plays Chords only: the gorilla plays the tune, the bot the chords on the
  beat, leaving one out: expect `WON falls=1 bananas=6`.
- `--learn` plays learn mode. The bot plays each note a moment after the last grab, once a
  wrong one: expect `WON falls=0 bananas=4 misses=1`, with `--chords` or `--chords-only` too
  (there, the wrong one is a chord).
- `--drill` plays the chord drill, with every kind of chord on, once striking a wrong
  chord: expect `WON falls=0 bananas=4 misses=1`.
- `--perf` prints fps and draw calls once a second.
- `--shots=<dir>` saves a screenshot every second.
