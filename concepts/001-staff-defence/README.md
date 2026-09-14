# 001 — Staff Defence

**Stage:** Card → **Spike** → Built
**Verdict:** _not played yet_

## The fun hypothesis

A tower defence where the player's territory is a treble-clef staff and the melody is the
enemy wave. Bugs spawn on the right, weave through corridors no laser can reach, and step
into the one kill-zone tile on their pitch line on their beat. Playing that pitch fires a
laser into the zone; holding it for the bug's length burns the whole thing. Defend the base
well and you have sight-played the tune without being told to.

## The MIDI verb

Right hand: single notes A3–C6, held for their length, on the beat. Left hand: root + fifth
below C3 to change the laser colour to match the current bar's chord. Wrong-colour lasers
pass through.

## How it probably flops

- Staff lines with small labels are not enough to find the key fast, and it turns into
  hunting for the right row while the melody disintegrates.
- With routes painted on the board the landing line is public, so the melody itself never
  has to be read. The routes toggle exists to test whether hiding them is playable at all.
- Left-hand chords are a big skill jump over single notes and may just be friction.

Full rules: [SPEC.md](SPEC.md).

## Run it

```powershell
python -m http.server 8000 --directory concepts/001-staff-defence/spike
```

Then open <http://localhost:8000> in Chrome or Edge, allow MIDI access when prompted, and
click the page once to start audio. Web MIDI works in Chrome and Edge only.

## Controls

| Input | Does what |
| --- | --- |
| MIDI notes A3–C6, in the song's key | Laser into that line's kill zone while held. Out-of-key notes are disabled and flash. |
| MIDI root + fifth below C3 | Select laser colour for that chord (only the song's chords count) |
| Keyboard `Z X C V B N M` | A3 B3 C4 D4 E4 F4 G4 |
| Keyboard `A S D F G H J` | A4 B4 C5 D5 E5 F5 G5 |
| Keyboard `Q W E` | A5 B5 C6 |
| Keyboard `1 2 3 4` | Select the song's 1st–4th chord colour |
| On-screen controls | Song, Movement, Routes, Chords, Tempo slider (30–120 % of the song's BPM), Restart |

Every line carries its note name and fallback key. Live input source (MIDI or keyboard) is
shown top-right.

### Switches, to compare feel while playing

| Switch | Options |
| --- | --- |
| Movement | **Stepped** (one tile per eighth on the click) / **Smooth** (interpolated). Rules are identical. |
| Routes | **Shown** (each bug's path painted to its kill zone) / **Hidden** (predict the landing from the melody). |
| Chords | **Off** (colour ignored) / **Sticky** (last chord stays) / **Held** (colour only while root + fifth held). |

Fixed: global cooldown of 0.9 eighths on starting a laser; hold-to-kill, one segment per
eighth; each surviving segment costs the base 1 of 20 HP; 4/4 click; one bar of lead time;
bugs approach from one side, above or below, chosen once per song.

## Verdict log

| Date | Verdict | Why |
| --- | --- | --- |
| | | |

## Notes

- Songs: Ode to Joy, Twinkle Twinkle (C and G major), Frère Jacques, plus a scale walk.
  G major exists to check that the F line accepts F# and rejects F.
- Ideas parked for later: multi-colour enemies (hit green, then red later), fuller chord
  types (sevenths), bugs changing target line after spawn, several bugs per note.
