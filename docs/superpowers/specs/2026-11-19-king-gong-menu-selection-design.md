# King Gong (Godot): what is selected on a menu is plain to see

Short design. Project: `godot-implementations/king-gong/`. Replaces the "Selected look" of
the piano-menus design of 2026-11-13 for planks and the yellow button. The other rows keep
the look that design gave them.

## Why

The user reported this: on the song and drill boards, and in the pause menu, you can't tell
whether Back or Start is selected.

The cause is the colour gold, `#f2c230`. Everywhere else in the menus, gold means "this is
selected": it is the row frames, the lit keys on the sign and the next note on the little
keyboard (`MARK` in `scripts/menu_cursor.gd`). But gold is also the resting colour of the
yellow button: Start on both boards, Continue on the pause menu and Play again on the end
panel (`StyleBoxFlat_start` in `ui/theme.tres`). So the yellow button always looks
selected, and when it really is selected it only turns a little lighter (`#f7d35a`).

A selected plank also changes very little. Back, Restart song and both Menu planks hang
straight already, so being selected only makes them grow 4% and brighten slightly. The sign
can't help on the boards either. It sits level with the selected row, and Back and Start
share one row.

## Goals

- Gold means "selected", and nothing else, on every menu.
- At a glance you can tell which one thing is selected: on the main page, on both boards'
  Back | Start row, in the pause menu and on the end panel.
- The yellow button still reads as the main action on its menu.

## Non-goals

- No change to what any key or click does, or to where the selection starts.
- The rows with frames keep their look: board rows, cell rows, the chord grid and its Done
  button.
- No new pointer, sound or animation beyond what is listed below.

## Approaches

- **Gold only for what is selected.** This is my call: the user asked for the specs to be
  written with my choices. The yellow button rests in a dull amber and turns gold only while
  selected. A selected plank gets a gold edge. This removes the cause, and it uses the
  meaning gold already has on every other row.
- **A pointer next to what is selected**, such as a small arrow or banana, with the colours
  as they are. It is cheap, but gold would still mean two things, and the always-gold Start
  would still pull the eye away from the pointer.
- **Dim everything that isn't selected.** Very clear, but it makes the whole menu darker
  and harder to read, just to show one item.

## Design

- **The yellow button at rest:** same shape, size and rounded corners as now, in a muted
  ochre that is darker than the gold and about as bright as the plank wood. Its text is
  cream with a dark outline, like a plank's. It still stands out from the planks by its
  shape and colour, but nothing about it says "selected".
- **The yellow button selected:** the look it has at rest today: gold `#f2c230`, dark text
  and its shadow. It also grows 4% about its centre, as a plank does. The pressed look stays
  the darker gold it is now.
- **A plank selected:** it straightens, grows and brightens as now, and it also gets a gold
  edge. The edge hugs the plank's outline and follows its tilt and growth, so it never
  shows as a rectangle around a tilted plank.
- **The mouse:** pointing at something selects it, as now, so the mouse shows the same look.
  Godot's own hover look stays switched off.
- **Where:** the main page planks (Play song, Learn song, Chord drill, Exit game), Back |
  Start on both boards, the pause menu (Continue, Restart song, Menu) and the end panel
  (Play again | Menu). Disabled planks (Tutorial, Campaign) are never selected, so they don't
  change.
- **In code:** the theme's `StartButton` gets a new resting style, and today's resting
  style becomes the selected style. `menu_cursor.gd` keeps giving planks and yellow buttons
  their own selected look, now including the gold edge and the yellow button's growth.
- **Builder's calls:**
  - The exact ochre and text colours, as long as the text contrast is at least 4.5:1 and
    the ochre is clearly not gold next to the sign's lit keys.
  - How the plank's gold edge is drawn: a second plank texture with a gold rim, or a gold
    glow behind the plank (`art/glow.svg` exists). Either works if it is gold and hugs the
    plank.

## Check

- `dev_cursor_check.gd` also checks the looks. On a Back | Start row, moving the selection
  gives Start the selected style and Back the plain plank, and then the reverse. Only one
  button at a time ever has the selected style. It still prints `cursor: ok`.
- `--autoplay --menu` (and with `--learn` or `--drill`) gives the same results as now.
- `--menu --shots=<dir>` saves screenshots of each menu with Back, then Start, selected,
  for the user to look at. The user judges whether it is now clear; the checks can't.
- README: in "Menus" and the controls table, write down that gold marks what is selected.
