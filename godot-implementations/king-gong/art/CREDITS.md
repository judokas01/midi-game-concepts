# Credits

Every file in this folder was drawn for this project, copying the shapes and colours the
browser spike draws in code (concepts/002-king-gong/spike). The only third-party assets are
the piano recordings in `sounds/piano/`, credited under Sounds below.

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
`plank_lit.svg` is the same plank with a gold rim, for the plank the menu selection is on.

## Sounds

The piano is the **Salamander Grand Piano** (V3), a Yamaha C5 recorded by **Alexander Holm**,
licensed under Creative Commons Attribution 3.0
(https://creativecommons.org/licenses/by/3.0/). The files are the Ogg Vorbis export the
Tone.js project hosts (https://github.com/Tonejs/audio, folder `salamander`): one velocity
layer, one note every minor third from A0 to C8. They are used as downloaded, on
2026-11-19; the game pitches each up or down a semitone for the notes between.

| File | Source | Author | Licence |
|---|---|---|---|
| `sounds/piano/A0.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A0.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C1.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C1.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Ds1.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Ds1.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Fs1.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Fs1.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/A1.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A1.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C2.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C2.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Ds2.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Ds2.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Fs2.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Fs2.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/A2.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A2.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C3.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C3.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Ds3.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Ds3.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Fs3.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Fs3.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/A3.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A3.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C4.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C4.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Ds4.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Ds4.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Fs4.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Fs4.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/A4.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A4.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C5.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C5.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Ds5.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Ds5.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Fs5.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Fs5.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/A5.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A5.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C6.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C6.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Ds6.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Ds6.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Fs6.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Fs6.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/A6.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A6.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C7.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C7.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Ds7.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Ds7.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/Fs7.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/Fs7.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/A7.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/A7.ogg | Alexander Holm | CC-BY 3.0 |
| `sounds/piano/C8.ogg` | https://raw.githubusercontent.com/Tonejs/audio/master/salamander/C8.ogg | Alexander Holm | CC-BY 3.0 |
