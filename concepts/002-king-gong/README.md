# 002 — King Gong

**Stage:** Card → **Spike** → Built
**Verdict:** _not played yet_

## The fun hypothesis

A gorilla swings through the treetops branch by branch. Every branch is a note on a staff
disguised as jungle, so getting the note and its length right *feels* like movement rather
than reading: thick branch, hang on longer; rest, let go and bounce. Swinging cleanly
through a whole tune should feel good enough to want the next song.

## The MIDI verb

Single notes, one at a time, **held for their length**. Pitch picks the branch; duration is
how long you hang on it; a rest means letting go on time. Nothing imposes a tempo: the clock
restarts at every grab, so the player sets the pace but has to keep note lengths in
proportion.

## How it probably flops

- The staff dressed as bushes is too disguised to read, and the note labels become a
  crutch. The Labels switch exists to test reading without them.
- Without a backing beat, "hold for 2 beats" against a self-set pace is vague. Either the
  tolerance is so wide that length stops mattering, or so tight that falls feel arbitrary.
- A wrong note means a fall. That may be too punishing, or the bananas may make it
  meaningless.

## Rules (spike)

- **Song:** Twinkle Twinkle in C, C4–A4. Lines 2 and 4 end with a quarter note and a quarter
  rest instead of a half note, so both long branches and rests get tested. Four branches
  carry a banana.
- **Staff:** the five staff lines are long distant bushes, the spaces are sky, a vine clef
  sits on the left, bar lines are distant tree trunks and C4 gets a small ledger bush.
  Branch thickness = note length (thin = 1 beat, thick = 2 beats).
- **Grab:** play the branch's note. The first grab starts the song; there is no countdown.
- **Hang:** the gorilla swings one pendulum per note and reaches the front of the swing
  exactly when the note's length is up. Then play the next note (legato overlap is fine).
- **Timing window:** ±0.35 beat around the end of the note, at the tempo slider's BPM,
  measured from *your* grab, not from a global clock.
- **Falls:** wrong note; letting go before the window; pressing the next note before the
  window; holding past the window (the branch cracks, then breaks); missing the next branch
  after letting go.
- **Rest:** a liana hangs low across the gap. Let go inside the window, the gorilla drops
  into the liana and bounces up, and you grab the next branch when the rest is over.
- **Jump:** when the next branch is more than a third away in pitch, the gorilla jumps
  instead of swinging. This is only an animation; the rules are the same.
- **Magic bananas:** start with 3. After a fall, a magic banana bounces the gorilla back
  up, and it floats there until you play the branch you failed on. Failing the hold
  (letting go early, a broken branch, pressing early) retries that branch; failing the
  reach (wrong note, too late) retries the next one. Leave a branch that carries a banana
  cleanly to earn +1. Falling with no bananas left ends the song.
- **Win:** let go of the last branch on time and the gorilla lands in its nest.

## Run it

```powershell
python -m http.server 8000 --directory concepts/002-king-gong/spike
```

Then open <http://localhost:8000> in Chrome or Edge, allow MIDI access when prompted, and
click the page once to start audio. Web MIDI works in Chrome and Edge only.

## Controls

| Input | Does what |
| --- | --- |
| MIDI notes (C4–A4 used) | Grab the branch on that note; hold for its length; release to let go |
| Keyboard `A S D F G H J K` | C4 D4 E4 F4 G4 A4 B4 C5, fallback when no MIDI device is connected |
| `Space` / click | Start |
| `Enter` / Restart button | Restart the song |
| Tempo slider | 40–120 BPM (default 60). Sets how long a beat is; there is no backing track |
| Labels | Note names on branches (and the fallback key when playing on the keyboard) |
| Beat tick | Soft click on each beat of the branch you're hanging on; the higher click is the moment to move |
| Synth | Plays the notes you press (turn off if your keyboard makes its own sound) |

Which input is live (MIDI or keyboard) is shown top-right, next to bananas, progress and
falls.

## Verdict log

Written by a human after actually playing it. **Keep** (build it), **Fold** (dead end),
**Fork** (wrong game, but something in here is worth a new concept).

| Date | Verdict | Why |
| --- | --- | --- |
| | | |

## Notes

- Octave matters: C5 is not C4. A wrong-note fall names the note you actually played, so
  a controller set to the wrong octave is easy to spot.
- Parked for later: chords as double branches, a strict-metronome mode with a backing
  track, sharps and flats as different branch species, bananas as a score multiplier.
