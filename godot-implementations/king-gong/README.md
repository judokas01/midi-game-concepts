# King Gong — Godot port

A faithful port of the browser spike in [concepts/002-king-gong](../../concepts/002-king-gong/README.md):
same song, rules, timing window, tuning and controls, running natively in Godot 4.7 so
the two can be compared. The rules and the fun hypothesis live in the concept card; nothing
here changes them.

## Run it

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path godot-implementations/king-gong
```

Or open the folder in the Godot editor and press F5. Plug the MIDI keyboard in before
launching if you can; if none is found at start-up the game looks again every 2 seconds.

## Controls

| Input | Does what |
| --- | --- |
| MIDI notes (C4–A4 used, C3–A3 in the bass clef) | Grab the branch on that note; hold for its length; release to let go |
| Keyboard `A S D F G H J K` | C4 D4 E4 F4 G4 A4 B4 C5 (an octave lower in the bass clef), fallback when no MIDI device is connected |
| MIDI notes below middle C | Treble + chords only: the left hand's chord. Any octave and any order, but only its three notes |
| Keyboard `Z X C V B N M` | Treble + chords only: one key per chord, by its root (C D E F G A B). This song uses `Z` = C, `V` = F, `B` = G |
| Treble clef / Bass clef / Treble + chords | On the start screen: how to play the song |
| Chord hint | On the start screen, with chords: the sign on each log shows the chord's name, or its notes in the bass clef |
| MIDI note written on a menu button | Picks that button, on the start screen (C4 to A4) and on the end panel (C4 play again, D4 main menu). Computer keys don't; use the mouse |
| `Space` / click / any other MIDI note | Start, on the start screen. The note only starts the game; it grabs nothing |
| `Enter` / Restart button | Restart the song |
| `Esc` | Back to the start screen, at any time |
| Practice mode | On the start screen: the magic bananas never run out |
| Tempo slider | 40–120 BPM (default 60) |
| Labels / Beat tick | Same toggles as the spike |

Which input is live (MIDI or keyboard) is shown top-right, next to bananas, progress and falls.

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
- **Bass clef.** The spike is treble only. Here the start screen also offers the bass
  clef, which plays the song an octave down (C3–A3) so it sits inside the bass staff.
  The level behind the start screen redraws as you choose; the choice holds until you
  quit.
- **Treble + chords.** Also not in the spike. The song carries the usual Twinkle chords
  (C, F, G; `song.gd`, third column), and wherever the chord changes a log stands across
  the gap before that branch, coloured by its chord, with a sign on top. Play the chord in
  the left hand together with the branch's note, in the same ±0.35-beat window as the
  grab, and the gorilla kicks the log down. Too early, too late or the wrong chord and
  the log stays up: the gorilla runs into it, the log shakes, and it counts as a missed
  branch. After a magic banana the log is still there; break it and grab, untimed, like
  any retry. Only the change is played; the chord need not be held. The colours follow
  Boomwhackers by root (C red, D orange, E yellow, F green, G blue, A purple, B pink), a
  minor chord darker. The bass-clef hint writes root position with the root between F2
  and E3, which keeps every chord inside the staff.
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
| `main.tscn` | Sky, parallax layers (canopy, staff-line bushes, clef, floor), the world, camera, HUD |
| `scenes/branch.tscn` | One note: two halves of bark (Line2Ds) meeting at the grip, end twig and leaves, cracks, banana, label |
| `scenes/liana.tscn` | One rest: two posts, the vine (a Line2D) and its leaves |
| `scenes/chord_log.tscn` | One chord change: the log in two pieces (stump and top), its sign with the name and a small bass staff, splinters and chips |
| `scenes/gorilla.tscn` | Body sprite, scared body, arms (Line2Ds), hands, banana balloon, prompt |
| `scenes/glowing_banana.tscn` | The banana that pops out of the ground or flies to the counter |
| `art/*.svg` | All the art; see `art/CREDITS.md` |
| `ui/` | Theme for the bar and overlay, label styles |
| `scripts/game.gd` | The rules and the gorilla's pose (the same rules as the spike) |
| `scripts/level.gd` | Builds the level from the song: places branches, lianas, trees |
| `scripts/staff.gd` | Where things sit: staff step, line heights, floor |
| `scripts/branch.gd`, `liana.gd`, `chord_log.gd`, `gorilla.gd` | What each of those scenes can do |
| `scripts/song.gd` | The tune and its chords, their parsing into branches, and the two clefs |
| `scripts/metronome.gd` | The beat tick |
| `scripts/note_input.gd` | MIDI and keyboard input |
| `scripts/hud.gd` | Top bar, the two menus and their MIDI notes, messages |
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
- `--chords` plays Treble + chords instead. With `--autoplay` the bot also plays each
  chord, once leaves one out and runs into the log: expect `WON falls=3 bananas=4`.
- `--perf` prints fps and draw calls once a second.
- `--shots=<dir>` saves a screenshot every second.
