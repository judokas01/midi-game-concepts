# King Gong (Godot): working the menus from the piano

Design. Project: `godot-implementations/king-gong/`. Follows the main-menu design of
2026-11-12, whose non-goal it lifts ("no piano control of the menus").

## Why

A player sits at a MIDI keyboard, not at the computer. Today only the chord grid hears the
piano; every other menu needs the mouse or the computer keyboard. The menus should be
worked from the piano alone, with the six white keys of any octave, and the game should
show which key does what right where you are looking: next to what is selected.

## Goals

- **Six keys, any octave.** On every menu, a note's name decides what it does, whatever
  its octave:
  - **C** ▲ moves the selection up, **D** ▼ down. At the ends they wrap round.
  - **E** ◀ and **F** ▶ change the selected row: the previous or next song, part, round
    size, beats, tempo or option. On a pair of buttons (Back | Start) they move between
    the two. On an on/off row they flip it.
  - **A** ✓ presses what is selected: a plank, a button, an on/off toggle, a chord.
  - **B** ✕ does what Esc does there: back a level, continue from the pause menu, Menu from
    the end panel.
  - G and the black keys do nothing on a menu.
- **The sign (design C of the mockups):** one wooden sign, pointed on its left, beside the
  selection. On it, one octave C to B. Every key that does something right now is gold and
  carries its mark (▲ ▼ ◀ ▶ ✓ ✕); the rest are plain. A key flashes darker when played.
  Reference: `.superpowers/brainstorm/559-1794560437/content/piano-hints.html`, design C
  (local only, not committed).
- **Every menu:** the main page, the Play song / Learn song board, the Chord drill board,
  the chord grid (More options), the pause menu, the end panel.
- **The chord grid follows the same keys** (the user's choice, for consistency): C/D change
  rows, E/F walk the cursor along the row, A turns the chord under it on or off, B goes back
  to the drill board. Its present scheme (C4 to B4 pick the root in the marked row, a note
  outside that octave moves the mark) goes, with the key names over its columns and the
  note in "Done · C4".

## Non-goals

- **Opening the pause menu from the piano during a song.** Notes during a song stay the
  song's. This is designed next, on its own; until then Esc pauses.
- The computer keyboard's note keys (A S D F … and Z X C …) don't work the menus; they
  play notes in songs only, as now.
- No sound or effect from notes on a menu, and no new options on any menu.

## Behaviour

- **Where the selection starts:** the main page on Play song; a board on **Start**, so A
  starts at once; the chord grid on its first row, column C; the pause menu on
  **Continue**; the end panel on **Play again**. Back from a board selects the plank that
  opened it.
- **What can be selected, top to bottom:**
  - Main page: Play song, Learn song, Chord drill, Exit game. Tutorial and Campaign are
    skipped.
  - Song board: Song, Part, Chord sign (when shown), Practice mode (Play) or Keyboard hint
    (Learn), then Back | Start as one row.
  - Drill board: Chords (E/F walk Major … aug, A turns the one under the cursor on or off;
    the last kind still can't go off), More options, In a round, Chord every, Keyboard
    hint, Back | Start.
  - Chord grid: each kind's row, then Done. A row's cells, left to right, are its group's
    button (Major, Minor, Sevenths, Dim & aug: picks the whole group), its kind's button
    where the group has several, and its chords. Moving up or down keeps the column where
    the new row has a chord there, or takes the nearest one.
  - Pause menu: Continue, Restart song, Practice mode (Play only), Tempo, Beat tick, Labels,
    Menu.
  - End panel: Play again | Menu as one row.
- **On a value row** (Song, Part, Chord sign, In a round, Chord every, Tempo) A does
  nothing, and the sign shows no ✓ there. The song list steps like its ◀ ▶ buttons, round
  from the end to the start; the others stop at their ends.
- **Cell rows and pairs wrap round** (my call): E/F along the drill board's Chords, a chord
  grid row, Back | Start or Play again | Menu go from the last back to the first and the
  other way. In the chord grid that halves the walk to a chord on the far side.
- **What the sign marks: exactly the keys that would do something now** (my call). So ▶
  goes plain on Tempo at 120 BPM or on the last part, ▲ ▼ go plain on the end panel (one
  row), ✓ shows wherever A presses something and ✕ wherever B goes somewhere (everywhere
  but the main page).
- **The end panel listens only after a second** (my call). It is the one menu that appears
  while the hands may still be playing ("Out of magic bananas" comes about 1.5 s after the
  wrong note), so for 1 s after it appears notes do nothing there, and its sign appears
  only then: the sign showing means the piano works the panel.
- **Selected look:** a plank straightens and brightens as under the mouse; the yellow
  button (Start, Continue, Play again) takes its hover look; a row of a board gets a light
  frame, as the chord grid's marked row has now; on a cell row the cell under the cursor
  gets its own frame.
- **The mouse** moves the same selection: pointing at something selects it, so the sign
  follows the mouse too, and only one thing ever looks selected. Clicks work as now.
- **The sign always shows**, with or without a MIDI keyboard connected (the user's call):
  it tells a player the piano works the menus before they plug one in. Only the end
  panel's first second goes without it.
- **The computer keyboard mimics the six keys** (the user's call): ↑ is C ▲, ↓ is D ▼,
  ← is E ◀, → is F ▶, **Enter or Space** is A ✓ (the user's call), Esc is B ✕. They do
  exactly what their piano key does on every menu, the chord grid included, and flash that
  key on the sign as a note would. The end panel's one-second wait is for notes only;
  these keys work there at once.
- **Space loses its own shortcuts on menus**: it presses what is selected, like Enter. As
  a board opens on Start and the pause menu on Continue, Space still starts and continues
  at once from where they open. In the chord grid it now turns the chord under the cursor
  on or off instead of closing the grid; Done or Esc closes it. During a song nothing
  changes: Enter restarts, Space does nothing, Esc pauses.
- **Notes that work a menu stay out of the song.** The note that presses Start, Continue
  or Play again is ignored when it is let go, as notes held over the pause already are.
- **The end panel's line** ("Enter plays again, Esc for the menu") stays; the sign covers
  the piano.

## Look

- The sign is wood like the planks (the same SVG family, warm brown with grain), pointed
  towards the selection. Its keys use the little keyboard's colours (white `#f4f1e6`,
  black `#23201c`, edge `#5b564c`); the lit keys are gold `#f2c230` with dark marks
  `#2b2620`. Roughly 120 × 56 px.
- It sits just right of the selected plank on the main page, and just outside a board's
  frame, level with the selected row, everywhere else. Where that leaves the screen (the
  chord grid is nearly screen-wide) it may overlap the frame's edge, but never the row's
  buttons.

## Approach (builder's call, chosen)

One small selection script, shared by all the menus: each menu hands it its rows in order,
each row saying what it is (a plank or button to press, a value to step, an on/off, a row
of cells, a pair) and how to change it. The script moves the selection, applies the keys,
draws the selected look and places the sign. Notes reach it through the HUD, which already
receives every note while a menu is up; the arrows, Enter and Space feed the same calls. The
chord grid's own note handling (`play()`) is replaced by rows of cells.

Considered and dropped: Godot's built-in focus (`ui_up`, `ui_accept` and focus
neighbours). Its left/right moves focus between buttons rather than stepping a row's
value, it has no notion of a row or a pair, and its focus look would need restyling on
every control anyway; the menus would end up fighting it.

## Also in scope

- `README.md`: the controls table (the six keys, the sign, the arrows, Enter and Space on menus),
  the chord grid's section, and the "MIDI notes on the menus" line.
- Dev check: with `--menu` the bot works the menus by notes, in mixed octaves: the main
  page, a board (a value row changed with F and checked), Back with B, the board again,
  Start with A; on the drill board a kind toggled with A, More options, a chord toggled in
  the grid, B back; with `--pause`, a tempo step with F in the pause menu and B to
  continue; on the end panel, a note in its first second doing nothing, then Menu with E/F
  and A. It checks the selection and the sign's lit keys at each step.

## Left to the builder

The sign's exact size, art and offset; the frame colours for rows and cells; how the chord
grid's cursor finds the nearest chord; the script's and nodes' names.

## Consequence to accept

The chord grid gets slower to work: F#m from where it opens takes about eight presses
(D, F six times, A) where it took two. The end panel ignores the piano for its first
second. Pausing during a song still needs Esc until its own design lands.
