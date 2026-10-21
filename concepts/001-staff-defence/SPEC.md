# 001 Staff Defence — spike specification (v4)

Scope: the stage-1 spike only. Everything here exists to test the hypothesis in
[README.md](README.md). Anything not listed is out of scope.

## 1. Core idea

A tower defence with no building. The player's territory is a treble-clef staff; the only
place an enemy can be hurt is a single **kill-zone tile** on each staff line, all in one
column. Enemies are bug-like creatures that spawn on the right, weave through corridors no
laser can reach, park beside their kill zone, and step into it on their beat. Each enemy is
one note of a song: its line is the pitch, its beat is the rhythm, its body length is the
duration. Playing the pitch on the keyboard fires a laser into that kill zone; holding it
for the note's length burns the whole bug. Anything that gets past runs to the base and
chips it.

## 2. The board

### 2.1 Grid

- Rectangular tiles. The board is a centred box of at most 980×560 px (aspect capped at
  0.62), shrinking to fit smaller windows, with the legend above and a caption strip below.
- **Rows:** 35 grid rows. Odd grid rows (1, 3, …, 33) are the 17 **pitch rows**; even grid
  rows are **corridors**. Pitch row `R` (0 = A3 at the bottom, 16 = C6 at the top) is grid
  row `2R + 1`. Grid row 0 is at the bottom.
- **Columns:** `4 + LEAD + 2` = 14 columns, indexed from the left.
  - Column 0: the **base**.
  - Columns 1–3: the **run-in**, corridor tiles between the kill zones and the base.
  - Column 4: the **kill-zone column** `K`. The tile `(2R+1, K)` is the kill zone for pitch
    row `R`. Corridor tiles in column `K` are safe.
  - Columns 5–13: **enemy territory**. Spawns land in columns `K+5` to `K+7`.
- Every tile that is not a kill zone is a corridor. Enemies may occupy any of them.

### 2.2 Staff drawing

- Staff lines are drawn through pitch rows 4, 6, 8, 10, 12 (E4 G4 B4 D5 F5), solid.
- Ledger lines through pitch rows 0, 2, 14, 16 (A3 C4 A5 C6), dim and dashed.
- Kill-zone tiles are drawn as outlined boxes so the column reads as a wall of targets.
- Each pitch row carries a hint at the left edge: note name with accidental (e.g. `F#4`)
  and its computer-key fallback.
- Faint grid lines mark tiles in enemy territory so movement reads as steps.

### 2.3 Key signature and disabled notes

- Each song declares a key. The key signature decides which accidental a pitch row
  accepts. Level-one keys: C major, G major (F rows accept F#, reject F). Data supports
  D major and F major.
- A pitch row maps to exactly one MIDI pitch: `12·(octave+1) + semitone(letter) + accidental`.
- Octave matters: C4 and C5 are different rows.
- Any right-hand MIDI note that maps to no row is **disabled**: nothing fires, and a short
  message shows which note was rejected and the song's key.
- Right-hand range is MIDI 48 (C3) and above. Below 48 is left-hand chord input.

## 3. Timing

- 4/4 only. Song time `T` is measured in eighths from `AudioContext.currentTime`, never
  from frame delta.
- Metronome click on every beat, accented on beat 1, scheduled ahead on the audio clock.
- Tempo is per song, 80–96 BPM in the level-one set, multiplied by a live **tempo slider**
  (30–120 %, default 60 %). Changing it re-anchors song time so `T` is continuous and the
  board does not jump; the legend shows the effective BPM.
- `LEAD = 8` eighths: every enemy spawns one bar before its window opens.
- One bar of silence before the first window opens, so the first bug is visible for its
  whole approach.

## 4. Enemies

### 4.1 One note, one bug

- Generated from the song's note list. A note of pitch row `R`, start `t` (eighths) and
  length `L` (eighths) becomes one enemy with `L` body **segments**. Rests generate nothing.
- Colour: the chord of the bar the note starts in. One colour per enemy.
- The **window** for the enemy is the interval `[t, t + L)`: segment `i` is in the kill zone
  during `[t+i, t+i+1)`.

### 4.2 Route

Every enemy has a fixed route, a list of tiles the head visits, one tile per eighth:

1. `route[0]` is the spawn tile, entered at time `t − LEAD`.
2. `route[LEAD − 1]` is the **parking tile**: the corridor tile directly above or below the
   kill zone, `(2R+1 ± 1, K)`.
3. `route[LEAD]` is the kill zone `(2R+1, K)`, entered at time `t`.
4. `route[LEAD+1 … LEAD+K]` runs left along grid row `2R+1` to column 0, the base.

The approach (`route[0 … LEAD−1]`) is `LEAD − 1 = 7` orthogonal moves that end on the
parking tile. It is generated as:

- **Side** `s`: +1 (approach from above) or −1 (from below). Chosen at random **once per
  song load** and used for every enemy, so the swarm always comes from the same side. If
  the resulting rows leave the grid for a particular enemy, flip `s` for that enemy only.
- **Extra vertical distance** `v` ∈ {0, 2}, random. Horizontal distance `h = 7 − v`.
- Spawn tile: `(2R+1 + s·(1+v), K + h)`.
- The 7 moves are `h` steps left and `v` steps toward the pitch row, with the vertical
  steps placed at random positions among the moves, so the approach is a staircase, never
  a diagonal.

The route is never hittable except at `route[LEAD]`.

### 4.3 Body and movement

- The head is at `route[floor(T − (t − LEAD))]`. Segment `i` trails `i` steps behind:
  `route[step − i]`. Segments with a negative index have not spawned yet and are not
  drawn.
- **Movement switch** (live): **Stepped** draws each segment on its tile; **Smooth**
  interpolates each segment between its current and next tile by the fractional part of
  `T`. Hit detection and base damage use the stepped position in both modes, so the switch
  changes only the feel, not the rules.
- Movement is orthogonal only.

### 4.4 Route visibility switch (live)

**Routes shown** paints each active enemy's approach and run-in as a faint polyline in the
enemy's colour, so the landing line is public. **Routes hidden** draws nothing; the player
predicts the landing from the melody and the bug's position alone.

## 5. Firing

### 5.1 Laser

- Note-on in the right-hand range on a valid pitch row turns that row's laser **on**.
  Note-off turns it **off**.
- The laser is drawn from the base edge to the kill zone and lights the kill zone tile in
  the laser colour.
- While a laser is on, a segment currently in that row's kill zone whose enemy colour
  **matches** the laser colour (section 7) is burned. Burned segments vanish.
- The laser plays a triangle-wave tone at the row's pitch while on.

### 5.2 Cooldown

- Global. A new laser cannot start until **0.9 eighths** after the previous one started.
  Nominally half a beat; the slack lets two eighths per beat be played legato.
- A blocked attempt flashes the row red and does nothing. Holding an on laser is never
  blocked. HUD shows `ready` / `cooldown`.

## 6. Base damage

- Base starts at **20 HP**. Each alive segment whose head reaches column 0 is removed and
  costs 1 HP. A fully missed half note therefore costs 4.
- The base object visibly reacts to each hit: a flash and a crack line per HP lost.
- **Lose**: HP reaches 0. Overlay "Base destroyed".
- **Win**: every enemy is resolved (burned or arrived) and HP > 0. Overlay "Song survived".
- Both overlays show HP remaining and `segments burned / total`.

## 7. Chord rules (switchable live)

Left hand: MIDI notes below 48. A **chord** is detected when two held low notes are a
perfect fifth apart (7 semitones, octave-insensitive). The lower one is the root. Only
roots in the current song's chord list count; other chords are ignored.

| Rule | Laser colour |
| --- | --- |
| **Off** | Colour ignored; every laser burns every enemy. Enemies drawn neutral. |
| **Sticky** | Last detected chord stays selected. Song starts with its first chord selected. |
| **Held** | Colour set only while root and fifth are both held. Otherwise the laser is colourless and burns nothing. |

Chord colours: C green, F blue, G red, D orange, Am yellow, Em purple. A legend line shows
the current laser colour and chord, or a prompt to play one. Bar lines are not drawn (there
is no time axis on the board); instead the current bar's chord and the next bar's chord are
shown in the legend.

## 8. Input

### 8.1 Web MIDI

- Request access on load; attach to all inputs and to inputs connected later.
- Note-on with velocity 0 is note-off. Velocity and channel are ignored.
- HUD shows live input source: `MIDI` (green) once any MIDI note arrives, else `keyboard`.

### 8.2 Computer-keyboard fallback

| Keys | Rows |
| --- | --- |
| `Z X C V B N M` | A3 B3 C4 D4 E4 F4 G4 |
| `A S D F G H J` | A4 B4 C5 D5 E5 F5 G5 |
| `Q W E` | A5 B5 C6 |
| `1 2 3 4` | select the song's 1st–4th distinct chord colour directly |
| `Space` or click | start audio (browser gesture requirement) |

Auto-repeat ignored. Fallback keys fire the row's key-signature pitch, so they can never
hit a disabled note.

## 9. Songs (preset buttons)

All 4/4, one chord per bar, notes as `[name, lengthInEighths]`.

| Button | Key | BPM | Chords | Tests |
| --- | --- | --- | --- | --- |
| Tutorial | C | 50 | C, G | scripted: five bugs with rests between, timed captions explaining staff, kill zone, base, hold-to-kill, colours, switches, cooldown. Forces tempo 100 %. |
| Ode to Joy (C) | C | 84 | C, G | dotted rhythm, repeated notes |
| Twinkle (C) | C | 88 | C, F, G | three chords, half notes |
| Twinkle (G) | G | 88 | G, C, D | F# row accepts F#, rejects F |
| Frère Jacques (C) | C | 96 | C, G | eighth-note runs against the cooldown |
| Scale walk (C) | C | 80 | C, G | every row in one octave, for orientation |

Frère Jacques's G3 is below the staff, so it is lifted to G4. Switching songs restarts
immediately.

## 10. HUD

One top bar: song buttons; Movement (Stepped / Smooth); Routes (Shown / Hidden);
Chords (Off / Sticky / Held); Tempo slider; Restart; then input source, HP, kills, cooldown state. Start
overlay explains the two hands and asks for a click. No menus, settings or pause.

## 11. Technical constraints

- One `index.html`, inline CSS and JS, canvas 2D, no build step, no dependencies.
- Served from `http://localhost`; Web MIDI refuses `file://`. Chrome or Edge.
- Fits any window at or above ~900×600; redraws on resize.

## 12. Out of scope for the spike

Multi-colour enemies, chord types beyond root+fifth, enemies changing target line after
spawn, several bugs per note, scoring or combos, velocity, sustain pedal, saving,
difficulty settings, real art or audio assets, more songs, keys beyond the table.
