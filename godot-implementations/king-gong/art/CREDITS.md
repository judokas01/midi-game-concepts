# Credits

Every file in this folder was drawn for this project, copying the shapes and colours the
browser spike draws in code (concepts/002-king-gong/spike). No third-party assets.

They are plain SVGs at 1 SVG unit = 1 screen pixel (a staff step is 36 px). Edit them in
Inkscape or any vector editor; Godot re-imports them when the editor window gets focus.

The chord log (`chord_log_bark.svg`, `chord_log_splinters.svg`, `chip.svg`) is not in the
spike. It is drawn in pale greys so the game can tint it with each chord's colour.

`branch_bark.svg` is a tile: the branch scene repeats it along the branch, however long the
note is. `branch_twig.svg` and `branch_leaves.svg` have their origin (0, 0) where they meet
the branch's left and right end.

`sharp.svg` and `flat.svg` are the key signature's signs, ink-dark with a pale rim so they
read on the staff-line bushes. Their origin (0, 0) goes on the line or space: the sharp's
middle, and the flat's stem level with the middle of its bowl.

`macaw.svg`, `bat.svg` and `blossom.svg` are the signs a branch carries for a note the key
signature doesn't give: sharp, flat and natural. Their origin (0, 0) goes on the branch's
middle line: the macaw's feet and the blossom's stalk are on its top edge, the bat's feet
on its bottom edge.

`plank.svg` and `board.svg` are the menus' wood: a plank for the hanging buttons and signs,
and a board with a dark panel inside for the menus' options. Both are stretched as 9-slice
(the theme's `Plank`, `Sign` and `Board`), so their ends and corners keep their size.
