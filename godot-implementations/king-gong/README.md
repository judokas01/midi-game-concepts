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
- **Drawing.** The spike redraws every shape each frame. Here the scenery that only scrolls
  and the branches at rest are built once into meshes, and moving shapes are batched, so a
  frame is a few dozen draw calls. It looks the same.
- **Hot-plugging.** A MIDI device plugged in after a device was already found is not
  picked up until restart.

## Files

| Path | What |
| --- | --- |
| `main.tscn` | The scene: game root, view, synth, input, HUD and start overlay |
| `scripts/game.gd` | Rules, layout and the gorilla's pose |
| `scripts/song.gd` | The tune and its parsing into branches |
| `scripts/view.gd` | All drawing |
| `scripts/shapes.gd`, `scripts/backdrop.gd` | Batched triangle lists and the baked scenery layers |
| `scripts/synth.gd` | Note synth, effects, beat tick |
| `scripts/note_input.gd` | MIDI and keyboard input |
| `scripts/hud.gd`, `ui/theme.tres` | Top bar and overlay |
| `scripts/dev_autoplay.gd` | Dev check only, see below |

## Dev check

Arguments after `--` turn on a bot and diagnostics. The bot plays the song on its own and
fumbles one branch on purpose, so a fall and a magic banana get used too. Without these
arguments none of it loads.

```powershell
& "C:/game-dev/godot/Godot_v4.7.2-stable_win64.exe" --path godot-implementations/king-gong -- --autoplay --perf
```

- `--autoplay` plays the song, prints the result and quits.
- `--perf` prints fps and draw time once a second.
- `--shots=<dir>` saves a screenshot every 2 s.
