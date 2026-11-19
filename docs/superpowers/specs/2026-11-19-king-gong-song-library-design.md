# King Gong (Godot): song categories, difficulty, and the song library

Design. Project: `godot-implementations/king-gong/`. One of three specs written on
2026-11-19 for later sessions. The other two are the piano sound
(`2026-11-19-king-gong-piano-sound-design.md`) and backing
(`2026-11-19-king-gong-backing-design.md`).

## Why

The game has 10 built-in songs today, and the user plans to add many more.
`godot-implementations/king-gong/song-ideas.md` lists about 290 public-domain candidates
with a difficulty rating each. The song boards (Play song, Learn song) don't scale to that:

- **The Song row** is a dropdown (`OptionButton`) with ◀ ▶ beside it.
- **On the piano,** E and F step through the songs one at a time, wrapping round.
- **The level behind the menu** redraws at each step.

With 300 songs a pick could take 150 presses, and a 300-item dropdown can't be worked from
the piano at all. Songs also carry no category or difficulty, so the board can't group or
sort them.

The user asked for:

- a difficulty level and a category on every song in the code;
- a library page to pick from (option 2 of the menu discussion), with a twist: the selected
  song plays its first 10 seconds as a preview.

## Goals

**Part A: every song has a category and a difficulty.**

- **In `song.gd`,** each `SONGS` entry gets two keys: `category` and `difficulty`.
- **`difficulty`** is a whole number from 1 to 5. It rates playing the tune alone, one note
  at a time, on the scale in `song-ideas.md`:

  | Value | Meaning |
  |---|---|
  | 1 | A few neighbouring notes, an even rhythm |
  | 2 | Easy: mostly steps within five or six notes, a plain rhythm |
  | 3 | Medium: about an octave, some leaps, dotted or quick notes, the odd black key |
  | 4 | Hard: fast runs, wide leaps, many black keys or off-beat rhythms |
  | 5 | Very hard: fast and chromatic, or far wider than an octave |

- **`category`** is one of a fixed, ordered list kept in `song.gd`. The list mirrors the
  sections of `song-ideas.md`, plus one for imported scores. The order is the shelf order in
  the library:
  1. Children's songs
  2. Folk songs
  3. From other countries
  4. Czech children's songs
  5. Czech folk songs
  6. Christmas
  7. Czech carols
  8. Classical
  9. Czech classics
  10. From films
  11. Your scores (MusicXML scores read from `songs/`; never on a built-in song)
- **The 10 built-in songs get these values.** They are my call, from the ratings in
  `song-ideas.md`; the user can change them:

  | Song | Category | Difficulty |
  |---|---|---|
  | Twinkle Twinkle | Children's songs | 2 |
  | Mary's Lamb | Children's songs | 1 |
  | Ducklings | Children's songs | 1 |
  | Lightly Row | Children's songs | 2 |
  | Ode to Joy | Classical | 2 |
  | Jingle Bells | Christmas | 2 |
  | Mary's Lamb in D | Children's songs | 2 |
  | Ode to Joy in F | Classical | 2 |
  | Mountain King in C minor | Classical | 3 |
  | Für Elise in F minor | Classical | 4 |

- **Imported scores** (`score_import.gd`) go in "Your scores" with no difficulty. They show
  no stars and sort after the rated songs.
- **A missing or unknown value is an error** at start-up, raised with `push_error`. A song
  added later can't go in without both values.
- **Song order.** A song's place in `Song.library()` stays its number everywhere else
  (`song_chosen(song: int)`, `Song.parse(song, …)`). The library page only changes the
  order it shows them in.

**Part B: the library page.**

- **Opening it.**
  - From the piano: A on the board's Song row. Today A does nothing on that row.
  - With the mouse: click the song's name. The name becomes a button, and the dropdown goes.
  - From the computer keyboard: Enter on the Song row.
- **Layout.**
  - A full-screen page over the game, on the same wood as the other menus, like the chord
    grid (`chord_menu.gd`): a dimmed background and a board in the middle.
  - At the top, the shelf's name with ◀ ▶ and how many songs it holds.
  - Under it, the shelf's songs as a list, one per line, each with five stars (filled up to
    its difficulty) and its name.
  - About ten lines show at once. The list scrolls so the selection is never at the very edge.
  - At the bottom, Back.
  - Sketch:
    ```
    ┌───────────── ◀ Czech children's songs ▶ ──── 21 songs ┐
    │   ★☆☆☆☆  Prší, prší                                    │
    │ ▸ ★☆☆☆☆  Skákal pes přes oves                          │
    │   ★☆☆☆☆  Pec nám spadla                                │
    │   ★★☆☆☆  Kočka leze dírou                              │
    │   ★★☆☆☆  Kalamajka                                  ▼  │
    │                       Back                             │
    └────────────────────────────────────────────────────────┘
    ```
- **Shelves.**
  - The first shelf is **All songs**: every song, sorted by difficulty, then by name.
  - The category shelves follow, in the list's order. Their songs are sorted the same way.
  - A shelf with no songs doesn't show.
- **Where it opens:** on the shelf the current song was picked from (All songs the first
  time), with the current song selected.
- **Keys** (the six-key scheme of the menus):
  - **C ▲ / D ▼** move up and down the list, wrapping round at the ends as other menus do.
  - **E ◀ / F ▶** change the shelf, wrapping round. The selection goes to the current song
    if the shelf has it, otherwise to the shelf's first song.
  - **A ✓** picks the selected song: the page closes, the board shows the song, and the
    level behind redraws for it.
  - **B ✕, Esc and Back** close the page, keeping the song picked before.
- **The rest of the input:**
  - The arrows, Enter and Space do the same as on every menu.
  - The mouse: pointing selects, a click picks, the wheel scrolls, and clicking ◀ or ▶
    changes the shelf.
  - The menu sign (`menu_sign.gd`) sits beside the selection as on every menu, with the
    keys that do something lit.
- **The board's ◀ ▶ stay.** E and F on the Song row step through the shelf the current
  song was picked from, in the library's order: All songs, by difficulty, until a shelf is
  used.
- **The board's Song row also shows the stars.** How it fits them is the builder's call.

**Part C: the preview.**

- **When it starts:** once the selection has rested on a song for 0.6 s, the song's first
  10 seconds play on the piano.
- **What plays:** the tune with its chords, at the current tempo (the pause menu's, 60 BPM
  by default), in the octave the song is written in. A song without chords plays its tune.
- **The beat tick** stays silent during a preview.
- **How it ends:** the last second fades out, and a song shorter than 10 s plays whole.
- **It stops at once** when the selection moves, the shelf changes, a song is picked, or
  the page closes.
- **Only one preview** plays at a time.
- **No level preview:** the level behind the page doesn't redraw while you browse, only
  when a song is picked.
- **The sound** comes from the piano sound's song player
  (`2026-11-19-king-gong-piano-sound-design.md`).

## Non-goals

- No search box, favourites or "recently played" shelf. These are possible later.
- No finding a song by playing its first notes. This is possible later.
- No difficulty per part (bass clef, chords). The one rating is for the tune.
- No campaign, progression or locked songs.
- No preview while stepping with E/F on the board itself. The level already redraws there.
- Adding the songs from `song-ideas.md` is not part of this. They come later, each with its
  rating and its section there as category.

## Approaches

The user picked the library page. The other two options:

- **A Shelf row on the board, with Song stepping inside the shelf.** This is the smallest
  change. But you step through 20 to 60 songs without seeing them, and it doesn't fit a
  preview.
- **A campaign path that unlocks songs by difficulty.** This answers "what next" rather
  than "find this song". It may still come as the main menu's Campaign, which is still to
  be built, and it would use the same difficulty values.

## Design notes

- **The menu cursor** (`menu_cursor.gd`) has four kinds of row: press, cells, choice and
  value. It skips hidden rows but knows nothing of scrolling. The library needs either a
  scrolling list kind in the cursor, or a page that handles C/D/E/F itself and gives the
  cursor a single row. Builder's call, as long as the six keys, the arrows, the mouse and
  the menu sign behave as on every other menu.
- **Builder's call:** the page's size, how many lines show, how the stars are drawn
  (glyphs or art), and the scroll indicator.
- **Order of work.**
  - Part A can be built first, on its own.
  - Part B doesn't need the sound.
  - Part C needs the piano sound spec's song player. If that isn't built yet, build A and B
    and leave C for after it.

## Check

The dev bot (`scripts/dev_autoplay.gd`) gets:

- **At start-up, in every run:** a song without a known category, or with a difficulty
  outside 1–5, is an error (above), so every existing run fails on it.
- **`--library`.** Before playing, this works the library from MIDI notes in mixed octaves:
  1. A on the Song row opens the library.
  2. F changes to the next shelf.
  3. D twice moves down the list.
  4. A picks the song.

  It then checks that the board's song is the one picked and that the level was rebuilt for
  it, and prints `library: picked <song> from <shelf>`. Then it plays the song as usual.
- **The preview.** In the same run, before picking, the bot waits on a song for longer
  than the delay, checks a preview is playing, and prints `library: preview <song>`. Then
  it moves and checks the preview stopped, and prints `library: preview stopped`. If the
  preview isn't built yet (Part C waits for the piano sound), this check waits too.
- **README.** Update the controls table, the Song row's description, the bot's flag list
  and the file map.
