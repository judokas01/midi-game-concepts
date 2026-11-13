# King Gong (Godot) — main menu, as jungle signs, and the pause menu to match

Short design. Project: `godot-implementations/king-gong/`. Follows the pause-menu design of
the same day.

## Why

The start screen is a wall of text and every option at once. Nobody reads the paragraphs; a
tutorial will teach the rules later. The start screen becomes a main menu of a few buttons,
and each way to play gets its own small menu with only its own options. The pause menu
takes on the same look, so the menus read as one game.

## Goals

- **Main menu**, as design **D** from the mockups (jungle signs): the title on a wooden sign
  and wooden planks hanging on lianas from the canopy, over the lightly dimmed level. Top to
  bottom: **Tutorial** and **Campaign** (both greyed, tagged "coming soon", do nothing),
  **Play song**, **Learn song**, **Chord drill**, and a smaller **Exit game** plank (quits).
- **Play song** opens a hanging wooden board with:
  - **Song** `◀ [list ▾] ▶`
  - **Part**: Treble clef · Bass clef · Treble + chords · Chords only
  - **Chord sign**: Name · Bass clef, shown only when the part has chords
  - **Practice mode** off/on (infinite bananas)
  - **Back** and **Start**
- **Learn song** is the same board, played in learn mode (untimed, no falls, note hints),
  with **Keyboard hint** on/off in place of Practice mode.
- **Chord drill** board:
  - **Chords**: Major · Minor · 7 · maj7 · m7 · dim · aug, any number on, and under them a
    line naming what is picked (`C D E F G A B`, or `… and 9 more`) and **More options**
  - **In a round**: 8 · 16 · 32 · 64 chords
  - **Chord every** `◀ 4 beats ▶`, 1 to 8
  - **Keyboard hint** on/off
  - **Back** and **Start**
- **More options** opens the existing chord grid, every kind on every root. Its "in a round"
  row moves to the drill board. Done returns to the drill board.
- **Chord every n beats** is new: each chord gets n beats of tune before the next log. The
  default goes from today's 2 beats to 4.
- **The pause menu** becomes a hanging wooden board titled **Paused**, with its rows and
  order unchanged: **Continue** (yellow, like Start), **Restart song** (a plank), Practice
  mode, Tempo `◀ 60 BPM ▶`, Beat tick, Labels, and **Menu** (a plank). It behaves exactly as
  it does now. Reference: `pause-board.html` beside the designs below.
- **The end panel** ("Home in the nest!") hangs on the same wood: its title and line on a
  board, **Play again** yellow and **Menu** a plank.
- No descriptions anywhere in the menus: the start screen's paragraphs, the chord-rule
  paragraphs, the "No MIDI? Keys …" line and the "play any note to start" line all go. On
  the computer keyboard the branches already show their letters.

## Non-goals

- No piano control of the menus. Only the chord grid (More options) keeps its MIDI control;
  the end panel's buttons lose their notes too, and a note on any other menu does nothing.
  There is a plan for piano control later.
- Tutorial and Campaign themselves.
- Tempo, labels and beat tick stay in the pause menu only.

## Behaviour

- **Chord kinds:** a kind's button is lit while any chord of that kind is picked. Turning a
  kind on adds it on the seven white-key roots (Major: C D E F G A B; aug has no B). Turning
  it off drops every chord of that kind, black-key roots included. The last kind can't be
  turned off. Picks made in More options show on the kind buttons and the line on return.
- **Keys:** `Space` starts from a board. `Esc` goes back one level: board to main menu, chord
  grid to drill board. On the main menu `Esc` and `Space` do nothing. Clicking empty space no
  longer starts the game.
- **Back to the menu:** the pause menu's and the end panel's menu button open the board you
  started from, with your song and options as you left them; the main menu is one Back from
  there. The button reads **Menu**.
- **The level behind** redraws as you choose, as now: opening a board sets its mode, and a
  song or part change lays the level out again.
- **While a menu is up** the counters (progress line, pill) and the little keyboard are
  hidden, so they don't show through the light dimming.
- Practice mode stays in sync between the Play board and the pause menu; Keyboard hint
  between the Learn and drill boards.

## Look (design D)

- Planks and the board are wood drawn for this project, as SVGs in `art/` like the rest
  (warm brown with grain, a light top edge and a dark bottom edge), stretched as 9-slice.
- Each plank hangs on two lianas from the one above; the title sign and the board hang from
  the top of the screen. Planks tilt a degree or so, alternately left and right, and
  straighten and brighten under the mouse. Coming-soon planks are greyed with a small paper
  tag.
- Text on wood is bold cream (`#f7e7a6`) with a dark shadow. Inside the board the controls
  keep the game's button theme; Start is yellow (`#f2c230`) with dark text.
- Reference: `.superpowers/brainstorm/1695-1794519058/content/main-menu-designs.html`,
  design D, and `pause-board.html` beside it (git-ignored, local only).

## Approach (builder's call, chosen)

A new menu script owns the main menu and the boards, laid out in the scene like the pause
menu; Play song and Learn song share one board. A small plank script handles the tilt, hover
and lianas. The chord grid stays code-built and becomes the More options page, minus its
count row; the kind buttons read and change its picks, so the grid stays the one record of
what the drill deals. The drill's tune generator takes the beats per chord. The pause menu
keeps its script and gets the same board, sign and plank pieces in the scene.

Considered and dropped: building the boards in code like the chord grid (harder to adjust in
the editor), and reworking the old start overlay row by row (the old screen's structure is
what makes it a mess).

## Also in scope

- `README.md`: controls table, menus, the drill's new option, the reworded menu button.
- Dev check: the bot drives the menus at least once (main menu → a board → Start, and Esc
  back), and a drill check that consecutive chords sit n beats apart.

## Left to the builder

Exact sizes, spacing, tilt angles, liana colour, the wood SVGs' detail, and where the
board's title sign sits.

## Consequence to accept

A player on a MIDI keyboard alone can't work the menus, and the end panel no longer takes
notes, until piano control comes back.
