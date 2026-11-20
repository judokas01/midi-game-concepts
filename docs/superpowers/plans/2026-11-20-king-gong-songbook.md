# King Gong: the song book — every song of song-ideas.md in the game

**Goal:** the 278 songs of `godot-implementations/king-gong/song-ideas.md` not yet in the game
(every `- [ ]` line in its sections, not "Not public domain"), written out as King Gong songs:
melody, songbook chords, category, difficulty. They appear in the library at once.

**The user's answers (2026-11-20):** all at once; a long piece is its famous theme (about 8–16
bars); every song with songbook chords.

**Architecture:** `scripts/songbook/<file>.gd`, one per category (Classical in two), each
`const CATEGORY` and `const SONGS := [...]`; `Song.SONG_BOOK` preloads them and `library()`
puts them after the 10 built-in songs (so those keep their numbers). `Song.bars_of()` reads
`meter` and `pickup`. `scripts/dev_songbook_check.gd` checks every song as the game reads it.

| File | Category | song-ideas.md section |
| --- | --- | --- |
| children.gd | Children's songs | Children's songs known worldwide |
| folk.gd | Folk songs | Folk songs known worldwide |
| countries.gd | From other countries | From other countries, known worldwide |
| czech_children.gd | Czech children's songs | Czech children's songs |
| czech_folk.gd | Czech folk songs | Czech folk songs everyone knows |
| christmas.gd | Christmas | Christmas, known worldwide |
| czech_carols.gd | Czech carols | Czech Christmas carols |
| classical_a.gd | Classical | Classical themes known worldwide: its first 30 `- [ ]` songs |
| classical_b.gd | Classical | Classical themes known worldwide: the rest |
| czech_classics.gd | Czech classics | Czech classics |
| films.gd | From films | From films, cartoons and games |

## The format (binding for every song)

```gdscript
{name = "London Bridge", category = "Children's songs", difficulty = 2, notes = [
	["G4", 1.5, "C"], ["A4", 0.5], ["G4", 1], ["F4", 1], ["E4", 1], ["F4", 1], ["G4*", 2],
	...
]},
{name = "Happy Birthday", category = "Children's songs", difficulty = 3, key = "F", meter = 3, pickup = 1, notes = [
	["C4", 0.5], ["C4", 0.5],
	["D4", 1, "F"], ...
]},
```

- **name:** the list's title. Drop remarks in brackets ("(written out)", "(over an octave)",
  a film it was used in, "the old chant behind…"); keep an alternate title the list gives
  ("Bratře Kubo (Frère Jacques)"). A composer's piece: "Title (Composer)", e.g. "Morning Mood
  (Grieg)". Czech titles keep their diacritics. No name may repeat one in the game.
- **category:** the file's `CATEGORY`, exactly. **difficulty:** the list's stars (1–5).
- **key:** the key it is written in, if not C: "G", "F", "D", "Bb", "Eb", "A", or minor "Am",
  "Dm", "Em", "Gm", "Cm", "Fm"… Notes are spelled as they sound and as the key spells them
  (Bb in F, F# in G); a note outside the key is written with its own sharp or flat.
- **Range:** every note from **A3 to F5**; best **C4 to C5** (the computer keys). Pick the key
  that fits the tune; a tune wider than A3–F5 keeps its real shape where it can and moves as
  few notes as it must by an octave.
- **notes:** `[note, beats]` or `[note, beats, chord]`. A note is "C4", "F#4", "Bb3" (letter,
  # or b, octave). Beats: 1 a quarter, 0.5 an eighth, 0.25 a sixteenth, 0.75, 1.5, 2, 3, 4
  (6 only in 6/8 for a whole bar). No triplets: even them out. `["r", beats]` is a rest
  (never first). One note at a time, the tune only.
- **meter:** beats a bar, 4 if left out; 3/4 → `meter = 3`; 2/4 → `meter = 2`; 6/8 → `meter =
  3` with the eighth as 0.5 (Row Your Boat). **pickup:** the beats before the first bar line,
  if the tune starts on an upbeat. The notes add up to whole bars after the pickup (a final
  bar may be short by the pickup).
- **chords:** songbook triads only: major "C", "F", "Bb", "D", minor "Am", "Dm", "F#m", rarely
  "dim"/"aug"; no sevenths (write G for G7). A chord goes on the note where it starts and
  lasts until the next chord. The first chord comes by the first downbeat (pickup notes may
  have none). Spell chords in the key (Bb, not A#).
- **Bananas:** a trailing "*" on a note ("G4*"): on the last note of most 2- or 4-bar phrases,
  two per song at least.
- **Length:** a song is one verse with its chorus, as people sing it; a classical or film
  piece is its famous theme, about 8–16 bars.
- **Truth:** write a tune only if you know it note for note. One you remember only in part is
  skipped and named in the report: a wrong tune is worse than a missing one.
- The six songs already written out at the end of song-ideas.md are used as they are, with
  category and difficulty added, "in F" dropped from the name, `bars` replaced by `meter` and
  `pickup` (Row Your Boat: meter 3; Happy Birthday: meter 3, pickup 1).

## Check

`dev_songbook_check.gd` (`-- --file=<name>` for one file) fails on a broken rule and warns
where a chord fits few downbeats, a key needs many signs, or a song is very short or long.
Every file passes; each warning is looked at. Then the library, cursor and sound checks, the
bot rows that open the library, and the full suite once. The user listens to the songs in the
library (preview, Listen) and says which sound wrong.
