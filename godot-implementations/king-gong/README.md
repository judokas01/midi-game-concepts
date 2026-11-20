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
| Keyboard `A S D F G H J K`, `W E T Y U` | C4 D4 E4 F4 G4 A4 B4 C5 on the home row, and the black keys between them in the row above, as on a piano: `W E` = C# D#, `T Y U` = F# G# A# (Db Eb, Gb Ab Bb). Moved by octaves to where the song is (lower in the bass clef); fallback when no MIDI device is connected. Each branch's label shows its key |
| MIDI notes below the next branch's | Treble + chords: the left hand's chord. Any octave and any order, but only its notes. A note lower than the next branch's note is the left hand's until let go, so a wrong note below the tune makes nobody fall, though it spoils a chord. With Chords only and in the chord drill every note is the chord's |
| Keyboard `Z X C V B N M` | With chords: one key per chord, by its root: C D E F G A B, and with `Shift` the black key above (`Shift+N` = Bb). The sign on each log shows its key, e.g. `Z` = C, `V` = F, `B` = G. In the chord drill every root plays the kind of chord the next log wants (`X` = Dm when it wants Am) |
| Main menu | Wooden planks: **Play song**, **Learn song** ([learn mode](#learn-mode)), **Chord drill** ([drill chords](#chord-drill)), **Exit game**; Tutorial and Campaign are coming. Each of the first three opens a board with its options and **Start** |
| Song `◀` name `▶` Browse… | On the Play song and Learn song boards: which song, with its difficulty in stars. `◀` `▶` (E, F) step through the songs of the [library](#the-song-library)'s filter it was picked with (every song, easiest first, until you pick with another). **Browse…** (A or `Enter` on the row, or a click on it or the name) opens the library |
| Listen | At the foot of the Play song and Learn song boards, between Back and Start: [hear the song](#listen) played on the piano while the gorilla climbs it. Any key, note or click stops it (not the volume keys or the wheel) |
| Part: Treble clef / Bass clef / Treble + chords / Chords only | On the song boards: how to play the song. [Chords only](#chords-only): the gorilla plays the tune, you the chords |
| Chord sign | On the song boards (with chords), the Chord drill board and the pause menu (with chords): the sign on each log shows the chord's name, or its notes in the bass clef. One setting: changed in one place, it changes in all |
| Chords, In a round, Chord every | On the Chord drill board: which chords it deals (More options opens the [chord grid](#the-chord-grid)), how many a round has (8, 16, 32, 64) and how many beats apart they come (1 to 8) |
| MIDI notes on the menus | Six white keys, in any octave: **C** ▲ up, **D** ▼ down, **E** ◀ and **F** ▶ change the selected row (the song, part or value before or after, along a row of buttons, or an on/off flipped), **A** ✓ presses, **B** ✕ goes back. Gold marks what is selected, and nothing else on the menus: a gold frame round a row, a gold edge on a plank (which also straightens and grows a touch), or the yellow button (**Start**, **Continue**, **Play again**) lit gold and a touch bigger; at rest the yellow button is a dull ochre. A wooden sign beside the selection shows one octave with the keys that do something there lit. The other keys do nothing, and the end panel waits a second before it listens, in case your hands are still playing |
| `↑` `↓` `←` `→`, `Enter` or `Space`, `Esc` | On the menus: the same as C D E F, A and B, at once on the end panel too. The mouse selects what it points at and clicks as ever |
| `Enter` / Restart button | During a song: restart it, or in the chord drill deal a new round |
| `Esc` | During a song: the [pause menu](#the-pause-menu). On a menu it goes back, as B: from the pause menu into the song, from the end panel to the board the song was started from, from a board to the main menu, from the chord grid to the drill board |
| Practice mode | On the Play song board, and in the pause menu: the magic bananas never run out |
| Backing | On the song and Chord drill boards, and in the pause menu: the game plays the part you don't on its [piano](#backing). On by default; one setting, changed in one place, it changes in all |
| Keyboard hint | On the Learn song and Chord drill boards: the [little keyboard](#the-little-keyboard) at the bottom. On by default |
| Tempo, Labels, Beat tick | In the pause menu. Tempo 40–120 BPM (default 60); Labels and Beat tick are the spike's toggles |

There are no bars on screen. A yellow line along the top edge follows the gorilla across the
level, from the stump (0%) to the nest (100%), with the percentage under its end. The level
is laid out in time, so a whole note fills four times as much of it as a quarter. The line
never goes back, on a fall or a swing back. A small pill top-right shows
the magic bananas (`∞` in practice mode), the falls (`wrong` in Learn mode and the drill) and
`Esc ‖`, the pause. Why you fell, or what was wrong, shows for a moment in a dark pill
under the progress line, above the chord signs. The counters and the little keyboard hide
while the main menu is up.

## The pause menu

`Esc` during a song freezes it under the pause menu: **Continue**, **Restart song**,
**Practice mode** (in Play mode), **Tempo** (`◀ 60 BPM ▶`, 40 to 120 in steps of 5; E and F
on its row), **Beat tick**, **Backing** (when the part has something to back), **Labels**, **Chord sign** (with chords: each log's name or its
notes in the bass clef, changed on the logs at once) and **Menu**, back to the board the
song was started from. It opens on Continue, so A, `Enter` or `Space` continues at once; B or `Esc` does too.

You let go of the key to reach for `Esc`, so a branch can't be held through a pause. On
Continue the gorilla floats up at the branch it hung on, or the next one if it was in the
air or in a rest, and waits for the note, untimed, as after a magic banana but for free. The
beat restarts at the grab, so a new tempo starts cleanly. A fall carries on where it was and
still costs its banana. Notes played or let go while paused are ignored.

## Learning

Three ways to get ready for a level, and a drill for the chords.

### Listen

Pick a song and a part on the Play song or Learn song board, then **Listen** (Back · Listen ·
Start at the foot). The level is laid out as for playing it, and the gorilla climbs it by
itself on the beat, as in Chords only, while the [piano](#the-piano) plays the tune and its
chords: the chords below the tune, each ringing until the next. A song without chords plays
its tune. It plays at the tempo set in the pause menu, and in the part's octave: in the
bass clef, where the bass clef puts the tune. The beat tick is silent, as the music carries
the beat, and nothing counts: no falls, no wrong notes, no bananas taken, no end panel. At
the nest, or as soon as you press any key, play any note, or click, it stops and the board
comes back, on Start. The volume keys, Shift, Ctrl or Alt on their own and the mouse wheel
leave it playing.

### Learn mode

Pick **Learn song** on the main menu, then a song and a part. Nothing is timed and the gorilla
can't fall: it hangs on its branch until you play the next branch's note, however long that
takes, then swings over. Rests are jumped. With Treble + chords it also waits at each log
until the left hand plays the chord; the note and the chord can come in either order. A
wrong note or chord only counts: the message at the top names the right one, the counter
top-right says `wrong`, and the end panel how many there were. Let go of the last note to
finish. Bananas are still there to collect, but there are no magic ones, as there is nothing
to fall from.

### Chords only

Pick **Chords only** as the part. The gorilla plays the tune by itself, on the beat, and you
play only the chords, anywhere on the keyboard. In Play mode each chord must come on time,
in the same ±0.35-beat window as a grab, or the gorilla bounces off its log, and magic
bananas work as usual; in Learn mode the gorilla waits at the end of the branch before each
log until you play its chord, and the beat restarts from there.

### Backing

With **Backing** on (the default), the game plays on its [piano](#the-piano) the part of the
song you don't, each sound as the gorilla takes hold of a branch, so it follows you the way
the beat tick does:

| Part | You play | Backing plays |
| --- | --- | --- |
| Treble clef, Bass clef | the tune | the song's chords, below the tune: each chord as your note grabs the branch it starts on, ringing until the next chord comes in |
| Chords only | the chords | the tune, the gorilla's own notes: each as it grabs that note's branch, for the note's length |
| Treble + chords | both | nothing (the Backing row hides) |

A song without chords (Mountain King) has nothing to back in the tune parts, so the row hides
there too. In Play mode with Treble or Bass, a chord comes in with your note, like a left hand
following the right; with Chords only the tune is on the beat. In Learn mode nothing is timed:
a chord comes when you play its note, a tune note when the gorilla moves on. When the gorilla
falls, what is sounding is let go, and the next grab brings the backing back: the chord the
branch is under too, though it started earlier. The pause menu silences it, and Continue
picks it up the same way at the next grab. In the chord drill Backing plays its tune, as for
Chords only: the arpeggios on its branches (see [Chord drill](#chord-drill)).

### Chord drill

Pick **Chord drill** on the main menu. On its board, **Chords** has a button for each kind of
chord: Major, Minor, 7, maj7, m7, dim and aug. Turning one on adds that kind on the white
keys (Minor: Cm Dm Em Fm Gm Am Bm; aug has no B); turning it off drops every chord of that
kind, and the last one can't be turned off. Under them the board names what is picked, the
major chords on the white keys until you choose. **More options** opens the
[chord grid](#the-chord-grid), for any chord on any root, black keys too. Each round is a
made-up tune of 8, 16, 32 or 64 chords (**In a round**), a new one every 4 beats (1 to 8,
**Chord every**), dealt like cards from the ones picked: each comes up as often as the
others, in a shuffled order, never twice running unless it is the only one. The
gorilla climbs it by itself and waits at every log until you play its chord, anywhere on the
keyboard. The tune leads into each chord: every log stands on its chord's root, and the
branches up to the next log are the next chord's notes between C4 and C5, low to high, an
arpeggio of the chord you play there. Its notes are all as long: half notes, quarters or
eighths, the longest that leaves the log's own branch at least as long (G after C, a chord
every 4 beats: C on one beat, then D4 G4 B4 in quarters). Where even eighths don't fit (a
chord every 2 beats, a chord with four notes in that range) its lowest notes drop out; a
chord every beat leaves no room, so there are only logs. The first log has nothing before
it, and the last holds the round's last beats. The branches carry no note names, Labels on
or off: the drill is about the chords. A banana hangs at every
fourth chord. Restart or Play again deals a new round. **Chord sign** puts each chord's
name on its log, or its notes in the bass clef. A seventh's four notes reach a ledger line
off the staff, E2 below (E7, Eb7, Em7…) or C4 above (D7, Db7…), so its sign is a taller
board than a triad's.

With **Backing** on (the default; a row on the drill board and in the pause menu), the
[piano](#the-piano) plays the tune as the gorilla climbs it, each branch's note as it takes
hold, on the gorilla's beat: you hear the next chord's arpeggio, then answer it at the log,
where the piano adds the root as the gorilla grabs it. It plays nothing that isn't on a
branch, and nothing while the gorilla waits.

### The song library

**Browse…** on the Song row (or A or `Enter` on the row) opens the library over the board.
Two filters sit at its top: **Category** (All songs, or one with songs in it: Children's
songs, Folk songs, From other countries, Czech children's songs, Christmas, Classical,
Czech classics, From films, and Your scores once you add some) and
**Difficulty** (Any, or exactly ★ to ★★★★★). Under them, the songs that match both, easiest
first, then by name, each with its stars; your own scores have none and come last. Ten show
at once, the list scrolling so the selection is never on its edge; ▲ and ▼ say there is
more. Where nothing matches, it says so. It opens on the song you have, with the filters it
was picked with.

| Key | On the library |
| --- | --- |
| C ▲ / D ▼ (the arrows) | Up and down: Category, Difficulty, the list, Back. In the list they move along it, and past its first or last song out of it |
| E ◀ / F ▶ | On Category or Difficulty, the one before or after, round from the end; on the list, the category. The list then shows the song you have if it matches, else its first |
| A ✓ (`Enter`, `Space`, a click) | On the list, picks the song: the board shows it and the level is laid out for it |
| B ✕ (`Esc`, Back) | Closes it, the song as it was |

The mouse selects what it points at and the wheel scrolls. When the selection rests on a
song for 0.6 s, its first 10 seconds play on the [piano](#the-piano), tune and chords, at 80
BPM, the last second fading out. Moving on, another filter, picking or closing stops it at
once.

Every song has a category and a difficulty from 1 to 5, for its tune alone: 1 a few
neighbouring notes in an even rhythm, 2 mostly steps within five or six notes, 3 about an
octave with some leaps and quick notes, 4 fast runs, wide leaps or many black keys, 5 fast
and chromatic, or far wider than an octave. A song without both is an error at start-up.

### The chord grid

A grid of every chord the drill offers: one row for each kind of chord, under its difficulty
(Major, Minor, Sevenths with 7, maj7 and m7, Dim & aug), and one column for each of the
twelve roots, C to B, spelled as the chord is usually written (Db, but C#m). Baug is left out,
since its fifth is F double sharp; it sounds the same as Gaug and Ebaug anyway. Click a chord
to pick it, or a row's or a difficulty's name to pick all of it, or none if all of it is
already picked. One chord at least stays picked. **Done** goes back to the drill board.

From the piano it works as every menu does. It opens on C in the Major row. C and D move
between rows and keep the column, or take the nearest chord where the row has none there; E
and F walk along the row, round from one end to the other, over its difficulty's and its
kind's names too; A picks what is under the cursor. B, `Esc` or **Done** goes back. What
you picked lasts until the game is closed.

### The little keyboard

In Learn mode and the chord drill a little piano keyboard at the bottom lights what to play
next:

- **The note**, yellow, on the tune's keys: from its lowest note, an octave at least.
- **The chord**, in its log's colour, in root position on two octaves of its own, left of
  the tune's: C2–B3 with Treble + chords, C3–B4 with Chords only and in the drill. It is
  lit where the bass-clef hint writes it, moved by octaves to fit. Played in any octave and
  any order it counts all the same; a note held outside those two octaves shows on the lit
  key of its name.

Keys held down show pressed in; a wrong note, or the odd note out of a wrong chord, goes
grey with a red cross. Every C is marked, and with the computer keyboard live its letters
are on the keys. With Chords only and in the drill the next chord lights up as soon as the
last one is played, however far ahead its log is. Turn **Keyboard hint** off on the board to
practise reading the notes alone.

## Your own songs

Put MusicXML scores in `songs/`, next to `project.godot`, and restart the game: they join
the songs after the built-in ones, by file name, in the library's Your scores category (and
at the end of every list they are in, with no stars). On musescore.com open the score and
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
- **More songs.** The spike has Twinkle Twinkle. The song boards here also offer, from
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
- **The song book.** After those ten come 55 public-domain tunes from `song-ideas.md`,
  in `scripts/songbook/`, a file for each category: children's songs (Hot Cross Buns,
  London Bridge, Frère Jacques, Happy Birthday…), folk songs (Amazing Grace, Greensleeves,
  Auld Lang Syne…), from other countries (Sakura, Korobeiniki, La Cucaracha), Christmas
  (Silent Night, Joy to the World, Deck the Halls, Carol of the Bells…), classical themes (Beethoven's Fifth,
  Eine kleine Nachtmusik, Minuet in G, Rondo alla Turca…), Czech classics (Vltava, the
  Largo from the New World Symphony) and tunes films borrowed (the Can-can, The
  Entertainer, Morning Mood…). Each is a verse or a famous theme, written in a key that
  keeps it on the staff (mostly C4 to C5), with songbook triads and bananas. A song in
  another time says so: `meter = 3` (3/4, or 6/8 in three beats), `meter = 2`, and
  `pickup = <beats>` for one that starts before its first bar line. They were written
  out from memory, except the two Czech children's songs and Carol of the Bells (the top
  line of Leontovych's Shchedryk, in D minor), whose notes come from Wikipedia's scores;
  a tune remembered only in part was left out, so 223 of the list
  wait for a written source. Listen to them in the library and say which sound wrong.
- **Key signatures.** The spike has no sharps or flats. A song in another key than C
  (`key = "D"` in `song.gd`) shows its key signature after the clef, as sheet music
  does: a sharp or flat on the line or space of each note it raises or lowers, and every
  note there or an octave away is played so. Wrong-note messages and the computer keys'
  list spell black keys as flats in a key with flats (Bb in F), else as sharps. The clef
  and the key signature are drawn small, at 40% of full notation size, so even 7 sharps or
  flats end well clear of the gorilla, who hangs 30% of the way in. Each clef sits on the
  line it names: the treble clef's curl on G, the bass clef's dots either side of F.
- **Signs on branches.** A note the key signature doesn't give carries a sign at its
  branch's left end, drawn as part of the jungle instead of as notation: a **macaw**
  sitting there in the twig's place for a sharp, a **bat** hanging under it for a flat, a
  white **blossom** for a natural. Unlike sheet music, a sign holds for its own branch
  only, not for the rest of the bar: a branch without one is always as the key signature
  says. The note label moves up over the macaw and the blossom. The macaw and the bat fly
  off as the gorilla takes hold; the blossom goes down with the first piece of bark, and
  all three are back for the retry after a magic banana.
- **Bass clef.** The spike is treble only. Here the song boards also offer the bass
  clef, which plays the song an octave down (C3–A3) so it sits inside the bass staff,
  Ode to Joy in F two (F2–C3), and Mountain King and Für Elise two as well (C2–C3, down to
  the second ledger line below).
  The level behind the menu redraws as you choose; the choice holds until you quit.
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
- **Menus.** The spike has a start overlay of instructions and an end message. Here there are
  no instructions (a tutorial will teach the rules): a main menu of wooden planks hanging on
  lianas opens a board for each way to play, `Esc` opens a [pause menu](#the-pause-menu)
  holding the settings the spike keeps in its top bar, and the end panel offers Play again
  and Menu, all on the same wood. Every menu is worked from the piano's white keys (or the
  arrows, `Enter` and `Esc`), with a sign showing which keys do what. Pausing a song still
  takes `Esc`.
- **Input timing.** Godot input events carry no timestamp, so a note is stamped when the
  event is dispatched, once per frame: about 16 ms of resolution at 60 fps against a
  ±350 ms window at 60 BPM. The spike uses Web MIDI's own timestamps.
- **A recorded piano, no effects.** The spike's synth and its effects (grab, creak, crack,
  fall, boing, banana, win) are gone. The tick is generated in code like the spike's and
  scheduled on exact sample frames. See [The piano](#the-piano).
- **Fixed layout.** The spike sizes everything from the window height. Here a staff step is
  a fixed 36 px on a 1280×720 canvas and the window scales the whole picture.
- **Small visual liberties.** The floor is drawn in front of the world, so tree trunks and
  liana posts sink into it. A strained branch bends as two halves meeting at the grip,
  not along a curve. There is no legend, and the settings bar is the pause menu.
- **Branch ends stand out.** The spike's leaves reach on past a branch's tip in the same
  green as the staff-line bushes, so two notes in a row on a line read as one long branch.
  Here the leaves are a lighter green, outlined, and stand up from the tip, and the bark's
  round ends stay inside the branch's length, which keeps the gap to the next branch open.
- **Hot-plugging.** A MIDI device plugged in after a device was already found is not
  picked up until restart.
- **No GPU.** If Windows falls back to its software renderer (no working graphics driver),
  vsync stutters at about 40 fps, so the game turns vsync off and caps itself at 60 fps.

## The piano

The game plays a recorded acoustic piano, the Salamander Grand Piano (see
`art/CREDITS.md`): one recording every three semitones from A0 to C8, pitched a semitone up
or down for the notes between. A held note rings and dies away as a piano's does; let go,
it fades in a quarter of a second, as without the pedal. Up to 32 notes sound at once.

It never plays what you play: your own instrument does that. It plays a song for
[Listen](#listen), and the part you don't play with [Backing](#backing), in the chord drill
its tune, and the first 10 seconds of a song in the [library](#the-song-library). The beat tick stays
louder than the piano. A note due on a beat starts in whichever frame has it heard nearest to
the beat, by the audio clock: within about 15 ms.

## How it is put together

The art is SVG files in `art/`, the pieces are scenes in `scenes/`, and the code only moves
them around:

| Path | What |
| --- | --- |
| `main.tscn` | Sky, parallax layers (canopy, staff-line bushes, clef and key signature, floor), the world, camera, HUD: the counters, the menus, the little keyboard |
| `scenes/branch.tscn` | One note: two halves of bark (Line2Ds) meeting at the grip, end twig and leaves, cracks, banana, label. When the gorilla grabs it, `branch.gd` cuts the bark into the pieces that fall |
| `scenes/liana.tscn` | One rest: two posts, the vine (a Line2D) and its leaves |
| `scenes/chord_log.tscn` | One chord change: the log in two pieces (stump and top), its sign with the name and a small bass staff, splinters and chips |
| `scenes/gorilla.tscn` | Body sprite, scared body, arms (Line2Ds), hands, banana balloon, prompt |
| `scenes/glowing_banana.tscn` | The banana that pops out of the ground or flies to the counter |
| `art/*.svg` | All the art; see `art/CREDITS.md` |
| `ui/` | The theme, with the menus' wood (Plank, Sign, Board, Tag, StartButton, BoardCaption), and label styles |
| `scripts/game.gd` | The rules and the gorilla's pose (the same rules as the spike), and learn mode's |
| `scripts/level.gd` | Builds the level from the song: places branches, lianas, trees |
| `scripts/staff.gd` | Where things sit: staff step, line heights, floor |
| `scripts/branch.gd`, `liana.gd`, `chord_log.gd`, `gorilla.gd` | What each of those scenes can do |
| `scripts/song.gd` | The songs and their chords, keys, categories and difficulties, the library's order and filters, their parsing into branches with the signs they carry, and the two clefs |
| `scripts/clef.gd` | The clef and key signature pinned at the left: their size (40%), and each clef placed on its line |
| `scripts/key_signature.gd` | Puts the song's sharps or flats after the clef |
| `scripts/drill.gd` | Deals the chord drill's chords and makes up its tune, each chord's arpeggio before its log; which chords the chord grid offers, and how they are spelled |
| `scripts/main_menu.gd` | The main menu: its planks, and the song and drill boards they open (with Listen on the song boards) |
| `scripts/plank.gd`, `ropes.gd` | A wooden plank that hangs askew and straightens and grows while selected (the yellow button grows the same way); the two lianas a plank or board hangs by |
| `scripts/menu_cursor.gd` | The selection on every menu: moves it, does what the six keys do on each kind of row, draws the frames, places the sign |
| `scripts/menu_sign.gd` | Draws the sign beside the selection: one octave, the keys that do something lit |
| `scripts/chord_menu.gd` | The chord drill's chord grid: builds it, and hands the menu cursor its rows |
| `scripts/library.gd` | The song library: its two filters, the list and its scrolling, and the preview on its own piano |
| `scripts/pause_menu.gd` | The pause menu: its buttons and toggles, the tempo's steps |
| `scripts/progress_line.gd` | Draws the progress line along the top, gliding after the gorilla |
| `scripts/piano.gd` | Draws the little keyboard |
| `scripts/score_import.gd` | Reads the MusicXML scores in `songs/` into songs |
| `scripts/metronome.gd` | The beat tick |
| `scripts/piano_sound.gd` | The piano: the recordings in `sounds/piano/`, its voices, a note's fade when let go, a note started to be heard on time |
| `scripts/song_player.gd` | Plays a song on the piano, its tune, its chords or both: in a level as the gorilla grabs each branch (and right on the beat when the next grab is certain), outside one from the song's start |
| `sounds/piano/*.ogg` | The piano's recordings; see `art/CREDITS.md` |
| `scripts/note_input.gd` | MIDI and keyboard input |
| `scripts/hud.gd` | The counters, the menus' wiring, messages, what the little keyboard lights |
| `scripts/songbook/*.gd` | The song book: the tunes of `song-ideas.md`, a file for each category, in the format `song.gd` describes |
| `scripts/dev_autoplay.gd`, `dev_cursor_check.gd`, `dev_sign_check.gd`, `dev_sound_check.gd`, `dev_library_check.gd`, `dev_songbook_check.gd` | Dev checks only, see below |

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
- `--song=<n>` plays another song, counting from 0 in the song list's order. Songs 1
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
- `--drill` plays the chord drill, with every chord the chord grid offers picked, 16 a
  round, once striking a wrong chord: expect `WON falls=0 bananas=4 misses=1`. It first
  checks that the chords sit the chosen number of beats apart and that no branch carries a
  note name, and that each log stands on its chord's root with that chord's notes before it,
  low to high, and says so: `drill: 16 chords, 4 beats apart`, `drill: each log's chord on
  the branches before it, low to high`, then `drill: no note names`. Backing is checked as
  for Chords only: `backing: <n> tune notes sounded`.
- `--beats=<n>`, with `--drill`, a chord every n beats instead of 4; the result is the same.
  With 1 there are only logs: `drill: logs only, a chord every beat`.
- `--pause` pauses with `Esc` three times, once each: mid-fall, hanging on branch 10 and in
  the first rest. It lets go of its note while paused, and a second later works the pause
  menu: the first time by notes (D down to Tempo, F a step up, B to continue), the second
  by keys (`↓` to Tempo, `→`, `Esc`), the third with `Enter`. Each `paused state=... cur=...`
  line is followed by `resumed`: the fall as `FALL` on the same branch, the hang as `WAIT`
  on its branch, the rest as `WAIT` on the next. The first two print `pause: tempo 65`, then
  `70` (at 120 BPM, F and `→` do nothing: `pause: tempo 120`). With `--chords` the first
  time it also walks down to Chord sign, picks Bass clef with F and checks every log shows
  it at once and the boards say the same: `pause: bass clef ok`. A pause costs nothing, so
  expect the same result as without it: `WON falls=2 bananas=5`, with `--learn` one pause
  and `WON falls=0 bananas=4 misses=1`, with `--chords` `WON falls=3 bananas=4`. If a pause
  menu doesn't continue, the run ends with `autoplay: the pause menu did not continue`.
- `--menu` works the menus by MIDI notes in mixed octaves before playing, instead of
  starting at once, checking the selection and the sign's lit keys at each step: on the main
  page the mouse, `Esc` and B (nothing happens); D down to the board for the mode (Play
  song, or Learn song or Chord drill with `--learn` or `--drill`) and A; there it steps the
  song on with F and back with E, and walks down past the Chord sign row (with `--chords`),
  or on the drill board turns Minor on and Major off, tries to turn Minor off, opens More
  options, picks and unpicks C in the chord grid, goes back with B and picks Bass clef on
  Chord sign; B to the main page,
  A on the same plank, and `↑`, `↓`, `Space` to start. At the end it picks Menu on the end
  panel with F and A. Along the way it checks that one thing alone looks selected (gold) and
  has grown: on the main page, along the board's foot (Back · Listen · Start, or Back |
  Start on the drill board) and back, on the end panel both ways, and with `--pause` on the pause menu's Continue and Restart song, and prints
  `menu: looks ok`. It prints `menu: started from PLAY` and `menu: back on PLAY` (or
  `LEARN`, `DRILL`); on the drill, `menu: kinds ok` once the round deals only the minor
  chords picked, and `menu: bass clef ok` once every log shows the bass clef. If the walk
  never starts the song, the run ends with `autoplay: the menus never started the song`.
- Every `--autoplay` run also plays an A on the end panel in its first second, which does
  nothing, and once the panel's sign shows prints `end: guard ok`.
- Every run also checks that the message (why you fell, what was wrong), whenever it shows,
  covers no chord sign or key under one, stays above where a seventh's tall sign reaches and
  clears the percentage and the counters, and prints `banner: clear of the signs` (in every
  mode above, as each has a fall or a wrong note).
- Every run prints `sound: piano ready (30 samples)`, and checks once the level is built
  that the key signature ends left of the gorilla's place on screen, as would 7 sharps or 7
  flats in either clef: `key: 4 flats, clear of the gorilla` (song 9), or `key: none`.
- `--backing` turns Backing on (it is on by default, so this makes it plain). Every
  `--autoplay` run counts the gorilla's grabs and at the end checks the backing against them:
  with Treble or Bass clef a chord per grab of a branch a chord starts on, and one at the
  first grab after a fall or a pause (`backing: 23 chords sounded` for song 0 in Play
  mode: its 21, and one after each of its 2 falls); with Chords only, and in the drill, a tune note per grab (`backing: 42 tune notes sounded`); with Treble + chords nothing, and the Backing row
  hidden (`backing: none for this part`). With `--pause`, halfway through the first pause it
  checks no backing voice sounds: `backing: silent while paused`.
- `--listen` doesn't play: it opens the board (Play song, or Learn song with `--learn`),
  moves to Listen with E and presses A, and lets it play to the nest. Meanwhile it checks
  that nothing counts and no tick is queued; then that the piano played the song's notes and
  chords, each heard (by the audio clock) within 20 ms of the gorilla's grab of its branch:
  `listen: 42 notes, 21 chords, worst 4.0 ms off the beat` for song 0. It checks the board
  is back on Start, then listens twice more, stopped after a moment by the `Q` key
  (`listen: a key stops it`, the piano silent at once) and by the note A, which must not
  also press Start (`listen: a note stops it`). With `--bass`, `--chords-only` or `--song=<n>`
  it listens to that part or song.
- `--library` picks the song from the library before playing it: from the main page to the
  Play song board, D to the Song row and A to open the library, on the list; F there to the
  next category, C up past the list to Difficulty and F to one star, D into the list and D
  again. Resting there it checks the song's preview plays (`library: preview Mary's Lamb`)
  and that C stops it at once (`library: preview stopped`); then D back and A picks it:
  `library: picked Mary's Lamb from Children's songs, ★☆☆☆☆`, the board on its Song row
  with that filter and the level laid out for it. Then it starts it from Start and plays it
  as usual.
- `--bpm=<n>` plays at n BPM instead of 60, for a quicker check. Every result above is the
  same at 120.
- `--perf` prints fps and draw calls once a second.
- `--shots=<dir>` saves a screenshot every second. With `--menu` it also saves
  `look_<menu>_<selected>.png` for each check of the looks above (`--menu --pause` adds the
  pause menu), to judge by eye whether what is selected is plain to see.

The menu cursor's rules (rows wrapping, values stopping at their ends, hidden rows skipped,
the nearest cell below, a value row A presses, a list that keeps its own selection and is
left at its ends, what the sign lights, the selected plank's and yellow button's look,
and the yellow button's text contrast at rest) have a check of their own, on throwaway
buttons:

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_cursor_check.gd
```

It prints `cursor: ok`.

The signs on the logs have one too: every chord the drill offers, sevenths included, in the
bass clef, each note on the staff or one ledger line off it and inside its board, with its
sharp or flat, and the name and every triad on the board they always had:

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_sign_check.gd
```

It prints `sign: ok`.

The songs and the library have one: every song's category and difficulty, the errors for a
missing or wrong one, the order and the filters, then the library page worked by the six
keys' acts on the real menus (opening from the Song row and from Browse…, the rows and the
list's ends, both filters, a filter with no songs, picking, closing, the board's arrows
within the filter, a long list's scrolling and marks, the wheel and the mouse) and the
preview (not before 0.6 s, then tune and chords at 80 BPM on its own bus, stopped by a move,
fading in its last second without a click, once per rest, stopped by closing or picking):

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_library_check.gd
```

It prints `library: ok`. It checks the ten built-in songs alone, whatever the song book
and `songs/` hold.

The song book has its own: every song with a name no other has, its file's category, a
difficulty of 1 to 5, a key the game knows, notes it can read of lengths it lays out,
every note between A3 and F5 so the staff moves none, triad chords from the first bar,
whole bars after its pickup, and two bananas at least. It warns, without failing, where
few downbeats are notes of their chord, a key needs many signs, or a song is very short or
long:

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_songbook_check.gd
```

It prints `songbook: 55 songs, 0 warnings` and `songbook: ok` (add `-- --file=children` to
check one file).

The piano and the song player have a headless check too: every key of the keyboard within
a semitone of a recording, 20 notes at once, more than 32 taking over the oldest, a let-go
fading out, no piano for the player's own notes, the keys that stop Listen, chords voiced
below the tune, and a song's sounds as grabs and expected grabs start them:

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path godot-implementations/king-gong --script res://scripts/dev_sound_check.gd
```
