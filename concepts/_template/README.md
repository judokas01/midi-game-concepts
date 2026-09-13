# NNN — Concept Name

> Copy this folder to `concepts/NNN-your-slug/`, fill it in, delete these quoted lines, and
> add a row to the concept log in the root [README.MD](../../README.MD).
> The card gets written before the code.

**Stage:** Card → Spike → Built  ← mark where it is
**Verdict:** _not played yet_

## The fun hypothesis

One or two sentences. What is the moment that might feel good, and why would a player want
it again? If this cannot be written plainly, the concept is not ready to build.

## The MIDI verb

What does the player physically do with the device? Single notes, chords, held notes, fast
runs, pitch bend, velocity, sustain pedal? The verb is what makes it a MIDI game rather than
a game that happens to read MIDI.

## How it probably flops

The likeliest failure. Name it up front so the spike actually tests it — too hard to sight
read, latency ruins the timing, fun for 20 seconds and then boring, only works if you can
already play.

## Run it

```powershell
python -m http.server 8000 --directory concepts/NNN-your-slug/spike
```

Then open <http://localhost:8000> in Chrome or Edge and allow MIDI access when prompted.

## Controls

| Input | Does what |
| --- | --- |
| MIDI notes C4–C5 | … |
| Keyboard `A S D F` | fallback when no MIDI device is connected |

## Verdict log

Written by a human after actually playing it. **Keep** (build it), **Fold** (dead end),
**Fork** (wrong game, but something in here is worth a new concept).

| Date | Verdict | Why |
| --- | --- | --- |
| | | |

## Notes

Anything learned that outlives the concept — a timing trick, a device quirk, a mechanic to
try elsewhere. This is the part worth keeping after a Fold.
