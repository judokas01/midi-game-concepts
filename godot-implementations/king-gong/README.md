# King Gong — Godot port

A faithful port of the browser spike in [concepts/002-king-gong](../../concepts/002-king-gong/README.md):
same song, rules, timing window, tuning, look and controls, running natively in Godot 4.7 so
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
| MIDI notes (C4–A4 used) | Grab the branch on that note; hold for its length; release to let go |
| Keyboard `A S D F G H J K` | C4 D4 E4 F4 G4 A4 B4 C5, fallback when no MIDI device is connected |
| `Space` / click | Start |
| `Enter` / Restart button | Restart the song |
| Tempo slider | 40–120 BPM (default 60) |
| Labels / Beat tick / Synth | Same toggles as the spike |

Which input is live (MIDI or keyboard) is shown top-right, next to bananas, progress and falls.

## Differences from the spike

- **Input timing.** Godot input events carry no timestamp, so a note is stamped when the
  event is dispatched, once per frame: about 16 ms of resolution at 60 fps against a
  ±350 ms window at 60 BPM. The spike uses Web MIDI's own timestamps.
- **Sound** is synthesised in code, like the spike's Web Audio: notes and effects are
  rendered into samples at start-up, and the beat tick is scheduled on exact sample frames.
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
| `scenes/branch.tscn` | One note: the branch sprite split in two halves, cracks, banana, label |
| `scenes/liana.tscn` | One rest: two posts, the vine (a Line2D) and its leaves |
| `scenes/gorilla.tscn` | Body sprite, scared body, arms (Line2Ds), hands, banana balloon, prompt |
| `scenes/glowing_banana.tscn` | The banana that pops out of the ground or flies to the counter |
| `art/*.svg` | All the art; see `art/CREDITS.md` |
| `ui/` | Theme for the bar and overlay, label styles |
| `scripts/game.gd` | The rules and the gorilla's pose (the same rules as the spike) |
| `scripts/level.gd` | Builds the level from the song: places branches, lianas, trees |
| `scripts/staff.gd` | Where things sit: staff step, line heights, floor |
| `scripts/branch.gd`, `liana.gd`, `gorilla.gd` | What each of those scenes can do |
| `scripts/song.gd` | The tune and its parsing into branches |
| `scripts/synth.gd` | Note synth, effects, beat tick |
| `scripts/note_input.gd` | MIDI and keyboard input |
| `scripts/hud.gd` | Top bar, overlay, messages |
| `scripts/dev_autoplay.gd` | Dev check only, see below |

Branches and lianas only appear when the game runs, because `level.gd` lays them out from
the song. To change how they look, open `scenes/branch.tscn` or `scenes/liana.tscn`, or
the SVGs.

## Dev check

Arguments after `--` turn on a bot and diagnostics; without them none of it loads. The bot
plays the song on its own. It plays one wrong note and hangs on to one branch until it
breaks, on purpose, so falls, cracks and magic bananas get used too.

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path godot-implementations/king-gong -- --autoplay --perf
```

- `--autoplay` plays the song, prints the result and quits. Expect `WON falls=2 bananas=5`.
- `--perf` prints fps and draw calls once a second.
- `--shots=<dir>` saves a screenshot every second.
