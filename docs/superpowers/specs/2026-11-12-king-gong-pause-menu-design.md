# King Gong (Godot) — pause menu, and the bars come off

Short design. Project: `godot-implementations/king-gong/`.

## Why

The play screen is cluttered: a settings bar across the top and a legend strip along the
bottom. The settings move into a pause menu, the bars go, and only the three counters stay on
screen. This is step one of a UI cleanup; a main-menu redesign follows, and for now the
existing start screen counts as the main menu.

## Goals

- `Esc` during a song opens a pause menu; `Esc` or `Space` closes it again (Continue).
- The pause menu has, in this order: **Continue**, **Restart song**, **Practice mode**
  (infinite bananas, on/off, Play mode only), **Tempo** `◀ 60 BPM ▶` in steps of 5 from 40 to
  120 (the arrows are clickable, and `←`/`→` step it while the menu is open), **Beat tick**
  on/off, **Labels** on/off, **Main menu**.
- The top bar and the bottom strip (legend line and computer-key cheat sheet) are removed.
- The counters stay, as design **C** from the mockups: a thin yellow progress line along the
  top edge that fills as you climb, with `6/42` riding under its knob and faint ticks at the
  quarters, plus a small dark pill top-right with `🍌 2 · falls 1 · Esc ‖`.

## Non-goals

- No MIDI notes on the pause menu's buttons. There's a plan for piano control later.
- No changes to the start screen, the end panel or the chord menu, beyond what the bars'
  removal forces.
- No cheat sheet and no MIDI/keyboard tag in the pause menu. The start screen's own "No MIDI?
  Keys ..." line stays.

## Behaviour

- **Pausing freezes the world:** the gorilla, falling bark, banner fade, beat tick, all of it.
  Notes played or released while paused are ignored, and what the hands were holding is
  forgotten.
- **Continue while hanging, in the air or in a rest** (any mode): the gorilla floats up on a
  magic banana at the branch it was on (hanging) or the next one (in the air or a rest) and
  waits for that branch's note, untimed, the way a retry after a fall does. It costs no
  banana and no fall. The beat restarts at your grab, so a tempo change applies cleanly. If a
  log stands before that branch, it waits for the chord too. When the gorilla plays the tune
  itself (Chords only, the drill), it simply grabs again, or waits for the log's chord.
- **Continue during a fall or a bounce:** it carries on where it was; the fall still costs
  its banana.
- **Continue while waiting** for a note: nothing changes.
- **Restart song** and **Main menu** close the menu and do what the end panel's buttons do.
- Pause is only for a running song. On the start screen and the chord menu `Esc` does what it
  does now; with the end panel up, `Esc` still goes to the main menu.
- **Counters by mode:** the pill shows `🍌 ∞` in practice mode, and `wrong N` in place of
  `falls N` in Learn mode and the drill. The drill's line counts chords (`3/16`), as
  `chord 3/16` does now. A collected banana flies to the pill's banana.
- **The little keyboard** at the bottom in Learn mode and the drill stays; it is not the
  bottom strip.

## Approach (builder's call, chosen)

Pause with Godot's tree pause (`get_tree().paused`), so tweens and `_process` freeze for free.
The pause menu and `NoteInput` run with `PROCESS_MODE_ALWAYS`; the game ignores notes while
paused. On Continue, the game shifts its stored wall-clock times (fall and bounce timers, the
blend) by the time spent paused, and turns hanging, air and rest into the floating wait
described above.

Considered and dropped: a pausable game clock, subtracting paused time from every clock
read. It is cleaner in theory but touches `note_input.gd`, `metronome.gd` and the dev bot for
no visible gain, since hanging can't survive a pause anyway: the key is let go.

## Also in scope

- `README.md` of the Godot project: controls table (Esc, tempo, labels, beat tick), the
  "which input is live" line, the floor-strip and layout notes.
- The dev check gets a `--pause` flag: the bot pauses while hanging on one branch, continues
  a second later, and plays on. Expect the same result as without it (`WON falls=2
  bananas=5` for song 0), which shows a pause costs nothing.

## Left to the builder

The panel's look within the existing theme (the end panel's dark style is the reference),
exact sizes and spacing, and keeping the start screen's Practice button in sync with the
pause menu's.

## Consequence to accept

With the top bar gone, tempo, labels and beat tick can only be changed from the pause menu
until the main-menu redesign adds them to the start screen.
