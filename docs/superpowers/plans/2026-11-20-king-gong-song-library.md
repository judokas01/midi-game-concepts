# King Gong: song categories, difficulty and the song library — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every song has a category and a difficulty; a library page picks songs from shelves
with the six piano keys, the arrows and the mouse; the song the selection rests on plays its
first 10 seconds on the piano.

**Architecture:** `song.gd` gains the categories, each song's two values, their check, and
`shelves()`. A new `library.gd` page (beside the chord grid under the HUD) shows a shelf as a
scrolling list and works through a new LIST kind of menu-cursor row. The song boards' Song row
becomes a name button that opens it; its ◀ ▶ step within the shelf. The page plays previews
on its own SongPlayer, on an audio bus it fades.

**Tech Stack:** Godot 4.7.2, typed GDScript, `main.tscn`.

**Spec:** [song library](../specs/2026-11-19-king-gong-song-library-design.md)

## Global Constraints

- Project root: `godot-implementations/king-gong/`. No commits: the user commits.
- Difficulty 1–5 (whole); categories, in shelf order: Children's songs, Folk songs, From
  other countries, Czech children's songs, Czech folk songs, Christmas, Czech carols,
  Classical, Czech classics, From films, Your scores (imported scores only).
- The 10 built-in songs' values as the spec's table.
- A song keeps its number in `Song.library()` everywhere (`song_chosen(song: int)`).
- Preview: after 0.6 s at rest, the first 10 s, the last second fading; tune and chords, at
  the game's tempo, in the treble clef's octave (the written one for the built-in songs).
- Test runs: the headless checks and the rows this touches while building; the full suite
  once at the end.

## Decided here

- **Song row:** the OptionButton `Song/Pick` becomes a Button `Song/Name`: "★★☆☆☆  Name"
  (imported: the name alone). A, Enter or a click opens the library: the row is a value row
  with a `press` callable (`MenuCursor.value(step, can_step, parts, press)`), so A is lit.
- **LIST cursor row:** `MenuCursor.list(lines, move, can_move, line, point, step, can_step,
  parts)`. C/D call `move(±1)` and stay on the row; E/F `step(±1)`; A presses `line()`; the
  mouse on a line calls `point(button)`; the frame and the sign follow the selected line.
- **The page's rows:** the list, then Back (reached with the mouse; C/D stay in the list,
  wrapping, as the spec asks). ◀ ▶ in the heading are in the list row's parts, so they are
  hooked like every menu button.
- **10 lines**, the list's height fixed so the board doesn't jump between shelves; the
  selection kept one line from the edge where the shelf allows; ▲ ▼ marks when more lie
  above or below. The wheel scrolls a line at a time, the selection kept in view.
- **Stars** are text: ★ filled, ☆ empty, in a label of fixed width before the name.
- **Shelf kept by the board:** `main_menu.shelf`; E/F on the board step within it; picking
  from the library sets it. `game.set_song()` tells the board (so `--song=` shows too).
- **Preview player:** the page's own SongPlayer on bus "Preview" (made at run time if the
  layout lacks it); `PianoSound.bus` and `SongPlayer.bus` say where voices go. The fade sets
  the bus volume each frame over the last second; stop resets it to 0 dB.
- Sort: difficulty, then name (`naturalnocasecmp_to`); imported (difficulty 0) after rated.

## Review Focus

1. A shelf with one song (Christmas): C/D unlit, E/F still change shelf.
2. A shelf longer than 10 (All songs once more are added): scrolling, the ▲ ▼ marks, the
   selection never at the edge, wrap from last to first jumps the view.
3. The preview and the game's own sound: no preview after the page closes or a song is
   picked; the beat tick silent; nothing left on the Preview bus at 0 dB lower afterwards.
4. Esc / B on the page while a preview plays: silent at once, the board back on Song.
5. The board's ◀ ▶ after a pick from a category shelf: they step within that shelf.

Tests: 1, 2, 5 → Task 2 headless check (a fake long shelf for 2); 3, 4 → Task 3 headless
check and the bot's `--library` row.

---

### Task 1: Categories, difficulty, shelves

**Files:** `scripts/song.gd`; create `scripts/dev_library_check.gd`; the suite runs it.

**Produces:** `Song.CATEGORIES: Array[String]`, `Song.ALL_SONGS := "All songs"`,
`Song.YOUR_SCORES := "Your scores"`; `static func song_errors(song: Dictionary, imported:
bool) -> Array[String]`; `static func shelves() -> Array` and `static func shelves_of(songs:
Array) -> Array` (each `{name: String, songs: Array[int]}`); `static func stars(difficulty:
int) -> String`.

- [ ] Failing headless check: every built-in song valid with the table's values; errors for
  a missing / unknown / "Your scores" category and difficulty 0, 6, 2.5; an imported song
  valid without a difficulty; `shelves()` = All songs (10, by difficulty then name: Ducklings,
  Mary's Lamb, Lightly Row, …) then Children's songs, Christmas, Classical; `shelves_of()`
  with a fake imported song puts it last in All songs and on Your scores; `stars(2)` ==
  "★★☆☆☆", `stars(0)` == "". Run → fails (no `song_errors`). Implement. Run → `library: ok`.

### Task 2: The library page and the Song row

**Files:** create `scripts/library.gd`; modify `scripts/menu_cursor.gd`, `scripts/main_menu.gd`,
`scripts/hud.gd`, `scripts/game.gd`, `main.tscn` (node `Hud/Library`, `Song/Name`),
`scripts/dev_library_check.gd`, `scripts/dev_cursor_check.gd`, `scripts/dev_autoplay.gd`,
`README.md`.

**Produces:** `library.gd`: `signal picked(song: int, shelf: int)`, `open(song: int, shelf:
int, bpm: float)`, `close()`, `cursor_rows() -> Array`, `shelf: int`, `at: int`;
`main_menu`: `signal library_requested`, `song: int`, `shelf: int`, `show_song(song: int,
shelf := -1)`; `hud`: `signal library_requested`, `open_library(song, bpm)`,
`library_open() -> bool`, `close_library()`, `show_song(song: int)`.

- [ ] Failing checks: cursor check — a LIST row: C/D call move and stay, E/F step, A presses
  `line()`, pointing calls `point`, UP/DOWN unlit when `can_move` is false. Library check, on
  the instanced game: A on the Song row (lit `CDEFAB`) opens the page on All songs with the
  current song selected; D/C move and wrap; F → Children's songs, the current song selected;
  F to Christmas: C/D unlit; E wraps from the first shelf to the last; A picks (the board's
  name, `game.song`, the page closed, the board's E/F within that shelf); B closes keeping
  the song; a fake shelf of 25: after 12 D the selection is on line 2–9, ▲ and ▼ shown.
- [ ] Bot `--library` (with `--autoplay`): main → board → D to Song → A (page up) → F → D D →
  wait → (Task 3's preview check) → A; `library: picked Mary's Lamb from Children's songs`;
  then plays it. The `--menu` board step expects `CDEFAB` on the Song row.
- [ ] Implement; run the headless checks and `--library`, `--menu`; README: controls, a
  "The song library" section, the file map, the flag.

### Task 3: The preview

**Files:** `scripts/piano_sound.gd`, `scripts/song_player.gd`, `scripts/library.gd`,
`scripts/dev_library_check.gd`, `scripts/dev_autoplay.gd`, `README.md`.

**Produces:** `PianoSound.bus: StringName`, `SongPlayer.bus: StringName`;
`library.previewing() -> int` (the song, or -1).

- [ ] Failing checks (headless): after 0.7 s at rest, `previewing()` is the selected song and
  its player has played sounds on bus Preview; a move stops it at once (sounding 0); 9.5 s in
  (the start moved back), the bus is quieter than 0 dB; 10.5 s in, stopped and the bus at
  0 dB; closing or picking stops it. Bot: `library: preview Mary's Lamb`, then after C
  `library: preview stopped`.
- [ ] Implement; run; then the full suite once; README.

---

## After the user tried it (2026-11-20)

The user: "I asked to create a category and difficulty filters or selections. In the menu
there is not very obvious you can input enter to go to detailed selection. Also increase the
listen tempo on those songs to 80." Their answers: two filter rows; a difficulty is exactly
that level; a Browse… button on the Song row; the preview alone at 80 BPM.

- The library's shelves became two filters at its top, **Category** (All songs or one with
  songs) and **Difficulty** (Any or exactly 1–5 stars); the list shows the songs matching
  both. Rows: Category, Difficulty, the list, Back. C/D move along the list and out of it at
  its ends (no wrap inside); E/F change a filter, and on the list the category. An empty
  match says so and the cursor skips the list.
- `Song.shelves()` gave way to `sorted()`, `matching(category, difficulty)` (cached),
  `categories_used()`, `levels_used()`. The board keeps `filter` instead of `shelf`; its
  ◀ ▶ step through the filter's songs.
- **Browse…** at the end of the Song row opens the library (as A, Enter and a click on the
  name do).
- The preview plays at `PREVIEW_BPM := 80`, whatever the game's tempo.
