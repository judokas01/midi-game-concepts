# 003 — Chord Pong

**Stage:** Card → **Spike** → Built
**Verdict:** _not played yet_

## The fun hypothesis

A creature keeps hurling an elemental ball at you, and the only way to send it back is to
find that element's chord under your hand before the ball lands. Smashing a fireball back
with a C major you found just in time should feel like a reflex being built, and the
speed-up after every return should make you want one more rally.

## The MIDI verb

Three-note chords, major and minor, one hand. Any octave, any inversion, struck together or
rolled. The last full chord you played is your shield; an extra wrong note spoils it. No
melody and no rhythm: just finding the right chord shape fast.

## How it probably flops

- Four chords are learned in a minute, and then it is a four-button reaction game with
  nothing left to discover.
- The element is a second lookup (ice → Em → E G B), and players read the hint strip
  instead of learning the chord. The Hints switch exists to test playing without it.
- "Any time before it lands" has no musical timing in it at all: it may feel like a quiz
  with a countdown rather than a ball game.
- On the computer-keyboard fallback a chord is a single key, so it says nothing about
  chords. The real test needs a MIDI keyboard.

## Rules (spike)

- **Chords:** all from C major. Warm elements are major, cold ones minor:
  fire = C (C E G), ice = Em (E G B), earth = G (G B D), water = Am (A C E).
- **Serve:** the creature at the top catches the ball, gives it a new element (never the same
  one twice in a row) and throws it down. Your shield clears the moment the element changes.
- **Shield:** the whole bottom edge is yours. There is no paddle to move. Whatever chord you
  last played when the ball arrives decides whether it bounces. A triad with no element
  (say F major) or a cluster that is not a chord leaves you with no shield.
- **Return:** the ball flies back up and hits the creature (−1 of its 12 health). The ball
  then comes down 8% faster, down to 1.1 s per trip.
- **Miss:** the ball breaks through and you lose a heart (3 in all). The ball slows down by
  20% (up to 3.6 s), and a banner tells you the chord you needed and its notes.
- **Win:** knock the creature's health to zero. **Lose:** run out of hearts. Either way you
  see your returns, misses and how fast you found the chords (from the element changing to
  your chord).

## Run it

```powershell
python -m http.server 8000 --directory concepts/003-chord-pong/spike
```

Then open <http://localhost:8000> in Chrome or Edge, allow MIDI access when prompted, and
click the page once to start audio. Web MIDI works in Chrome and Edge only.

## Controls

| Input | Does what |
| --- | --- |
| MIDI chords (any octave) | C, Em, G or Am raises the fire, ice, earth or water shield |
| Keyboard `W E R T` | C, Em, G, Am, a fallback when no MIDI device is connected |
| `Space` / click | Start |
| `Enter` / Restart button | Restart the round |
| Hints | Strip along the bottom: each element's chord, its notes, its key and a mini piano |
| Synth | Plays the notes you press (turn off if your keyboard makes its own sound) |

Which input is live (MIDI or keyboard) is shown top-right, next to hearts, returns and the
ball's current travel time.

## Verdict log

Written by a human after actually playing it. **Keep** (build it), **Fold** (dead end),
**Fork** (wrong game, but something in here is worth a new concept).

| Date | Verdict | Why |
| --- | --- | --- |
| | | |

## Notes

- Origin: chords for [King Gong](../002-king-gong/README.md). Each bar sits in fog, the next
  bar is half-fogged, and playing that bar's chord clears it. This spike tests the chord
  verb on its own first.
- Parked: a "swing" variant where the chord must land in a window as the ball arrives, not
  any time before; all six diatonic triads (add Dm and F) and more elements; other keys;
  the creature switching the element mid-flight.
