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
| MIDI notes | Grab the branch on that note; hold for its length; release to let go. The built-in songs use C4–C5, an octave or two lower in the bass clef. A song with a key signature plays every note on its lines and spaces sharp or flat, but on a branch with a sign: a macaw is a sharp, a bat a flat, a blossom a natural |
| Keyboard `A S D F G H J K`, `W E T Y U` | C4 D4 E4 F4 G4 A4 B4 C5 on the home row, and the black keys between them in the row above, as on a piano: `W E` = C# D#, `T Y U` = F# G# A# (Db Eb, Gb Ab Bb). Moved by octaves to where the song is (lower in the bass clef); fallback when no MIDI device is connected. The floor lists the black keys when the song has any |
| MIDI notes below the next branch's | Treble + chords: the left hand's chord. Any octave and any order, but only its notes. A note lower than the next branch's note is the left hand's until let go, so a wrong note below the tune makes nobody fall, though it spoils a chord. With Chords only and in the chord drill every note is the chord's |
| Keyboard `Z X C V B N M` | With chords: one key per chord, by its root: C D E F G A B, and with `Shift` the black key above (`Shift+N` = Bb). The start screen and the floor list the song's, e.g. `Z` = C, `V` = F, `B` = G. In the chord drill every root plays the kind of chord the next log wants (`X` = Dm when it wants Am) |
| Mode: Play / Learn / Chord drill | On the start screen: play a song, [learn it](#learn-mode) untimed, or [drill chords](#chord-drill) |
| Song `◀` list `▶` | On the start screen: which song to play, the built-in ones and then [your own](#your-own-songs) |
| Part: Treble clef / Bass clef / Treble + chords / Chords only | On the start screen: how to play the song. [Chords only](#chords-only): the gorilla plays the tune, you the chords |
| Chord hint | On the start screen, with chords: the sign on each log shows the chord's name, or its notes in the bass clef. The chord drill always shows the name |
| Chords: Choose | On the start screen, chord drill: opens the [chord menu](#the-chord-menu), which chords it deals and how many a round. The start screen shows the first few |
| MIDI note written on a menu button | Picks that button, on the start screen (C3 and D3 step through the songs, E3 to G3 pick the mode, C4 to B4 the rest) and on the end panel (C4 play again, D4 main menu). In the chord menu, C4 to B4 pick in the marked row and a note below or above moves the mark. Computer keys don't; use the mouse |
| `Space` / click / any other MIDI note | Start, on the start screen. The note only starts the game; it grabs nothing. `Space` also closes the chord menu |
| `Enter` / Restart button | Restart the song, or in the chord drill a new round |
| `Esc` | Back to the start screen, at any time, the chord menu too |
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

Pick **Chord drill**, then **Choose** which chords in the [chord menu](#the-chord-menu): the
major chords on the white keys until you do. Each round is a made-up tune of 8, 16, 32 or 64
chords, a new one every two beats, dealt like cards from the ones picked: each comes up as
often as the others, in a shuffled order, never twice running unless it is the only one. The
gorilla climbs it by itself and waits at every log until you play its chord, anywhere on the
keyboard. The tune is the chord's own notes between C4 and C5. A banana hangs at every
fourth chord. Restart or Play again deals a new round.

### The chord menu

A grid of every chord the drill offers: one row for each kind of chord, under its difficulty
(Major, Minor, Sevenths with 7, maj7 and m7, Dim & aug), and one column for each of the
twelve roots, C to B, spelled as the chord is usually written (Db, but C#m). Baug is left out,
since its fifth is F double sharp; it sounds the same as Gaug and Ebaug anyway. Click a chord
to pick it, or a row's or a difficulty's name to pick all of it, or none if all of it is
already picked. One chord at least stays picked. Under the grid, how many chords a round has,
and **Done**.

On the MIDI keyboard one row is marked with a yellow frame, Major when the menu opens. The
keys C4 to B4 pick in it, each the button under the key written over its column: C#4 is Db
in the Major row, C#m in the Minor one. In the round's row C4 D4 E4 F4 pick 8 16 32 64, and
in Done's row any of them goes back. A note below C4 marks the row above, a note above B4 the
row below, round from one end to the other. `Space` and `Esc` go back too. What you picked
lasts until the game is closed.

### The little keyboard

In Learn mode and the chord drill a little piano keyboard at the bottom, in place of the
legend, lights what to play next:

- **The note**, yellow, on the tune's keys: from its lowest note, an octave at least.
- **The chord**, in its log's colour, in root position on two octaves of its own, left of
  the tune's: C2–B3 with Treble + chords, C3–B4 with Chords only and in the drill. It is
  lit where the bass-clef hint writes it, moved by octaves to fit. Played in any octave and
  any order it counts all the same; a note held outside those two octaves shows on the lit
  key of its name.

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
  notes folded down an octave. Sharps and flats outside the key stay, as `Eb4` or `F#4`,
  and their branches carry [signs](#differences-from-the-spike): a macaw or a bat.
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
  where songbooks write G7 under four Fs that a G triad lacks. Last come four with
  [key signatures](#differences-from-the-spike): two of them in other keys, Mary's Lamb in
  D (F#, chords D and A) and Ode to Joy in F (Bb, up to C5, chords F and C), then two
  with signs on their branches, between C4 and C5:
  - **Mountain King in C minor**, Grieg's theme from In the Hall of the Mountain King,
	its first four bars twice, all eighths: macaws on F#, a bat on Db. No chords.
  - **Für Elise in F minor**, Beethoven's opening, in 3/4 with eighths for the score's
	sixteenths, moved down from A minor to fit the keyboard: blossoms on B and E natural.
	The low Ab3 that starts each broken chord is left out. Chords Fm and C.

  A song is a list in `SONGS` in `song.gd`; scores need no code, see
  [Your own songs](#your-own-songs).
- **Key signatures.** The spike has no sharps or flats. A song in another key than C
  (`key = "D"` in `song.gd`) shows its key signature after the clef, as sheet music
  does: a sharp or flat on the line or space of each note it raises or lowers, and every
  note there or an octave away is played so. Wrong-note messages and the computer keys'
  list spell black keys as flats in a key with flats (Bb in F), else as sharps.
- **Signs on branches.** A note the key signature doesn't give carries a sign at its
  branch's left end, drawn as part of the jungle instead of as notation: a **macaw**
  sitting there in the twig's place for a sharp, a **bat** hanging under it for a flat, a
  white **blossom** for a natural. Unlike sheet music, a sign holds for its own branch
  only, not for the rest of the bar: a branch without one is always as the key signature
  says. The note label moves up over the macaw and the blossom. The macaw and the bat fly
  off as the gorilla takes hold; the blossom goes down with the first piece of bark, and
  all three are back for the retry after a magic banana.
- **Bass clef.** The spike is treble only. Here the start screen also offers the bass
  clef, which plays the song an octave down (C3–A3) so it sits inside the bass staff,
  Ode to Joy in F two (F2–C3), and Mountain King and Für Elise two as well (C2–C3, down to
  the second ledger line below).
  The level behind the start screen redraws as you choose; the choice holds until you
  quit.
- **Treble + chords.** Also not in the spike. Each song carries its chords (`song.gd`,
  third column), and wherever the chord changes a log stands across the gap before that
  branch, coloured by its chord, with a sign on top. Play the chord in the left hand,
  lower than the branch's note (any note below the next branch's counts as the left
  hand's), together with that note, in the same ±0.35-beat window as the grab, and the
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
  both carries a MIDI note that picks it; the chord drill's chord menu is picked from by
  playing roots. So you never have to leave the piano. The end panel ignores notes for
  0.8 s, so a note still being played can't pick by accident.
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
- **Branch ends stand out.** The spike's leaves reach on past a branch's tip in the same
  green as the staff-line bushes, so two notes in a row on a line read as one long branch.
  Here the leaves are a lighter green, outlined, and stand up from the tip, and the bark's
  round ends stay inside the branch's length, which keeps the gap to the next branch open.
- **Hot-plugging.** A MIDI device plugged in after a device was already found is not
  picked up until restart.
- **No GPU.** If Windows falls back to its software renderer (no working graphics driver),
  vsync stutters at about 40 fps, so the game turns vsync off and caps itself at 60 fps.

## How it is put together

The art is SVG files in `art/`, the pieces are scenes in `scenes/`, and the code only moves
them around:

| Path | What |
| --- | --- |
| `main.tscn` | Sky, parallax layers (canopy, staff-line bushes, clef and key signature, floor), the world, camera, HUD with the little keyboard |
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
| `scripts/song.gd` | The songs and their chords and keys, their parsing into branches with the signs they carry, and the two clefs |
| `scripts/key_signature.gd` | Puts the song's sharps or flats after the clef |
| `scripts/drill.gd` | Makes up the chord drill's tune and deals its chords; which the chord menu offers, and how they are spelled |
| `scripts/chord_menu.gd` | The chord drill's chord menu: builds its grid and works it from the MIDI keyboard |
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
  to 9 hang three bananas, not four, so expect one banana fewer than for song 0, in every
  mode below. Songs 6 to 9 have a key signature, and 8 and 9 signs on their branches.
- `--bass` plays the bass clef instead.
- `--chords` plays Treble + chords instead. With `--autoplay` the bot also plays each
  chord, right under the branch's note (C4 E4 under a G4), once leaves one out and runs
  into the log: expect `WON falls=3 bananas=4`.
- `--chords-only` plays Chords only: the gorilla plays the tune, the bot the chords on the
  beat, leaving one out: expect `WON falls=1 bananas=6`.
- `--learn` plays learn mode. The bot plays each note a moment after the last grab, once a
  wrong one: expect `WON falls=0 bananas=4 misses=1`, with `--chords` or `--chords-only` too
  (there, the wrong one is a chord).
- `--drill` plays the chord drill, with every chord the chord menu offers picked, 16 a
  round, once striking a wrong chord: expect `WON falls=0 bananas=4 misses=1`.
- `--perf` prints fps and draw calls once a second.
- `--shots=<dir>` saves a screenshot every second.
