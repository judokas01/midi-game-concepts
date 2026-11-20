extends Parallax2D
## The clef and the key signature, pinned at the left while the level scrolls behind them.
## Both are drawn at SIZE of full notation size, so they stay clear of the gorilla. Each clef
## is a font glyph, placed by the point in it that goes on the line it names.

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
const KeySignature := preload("res://scripts/key_signature.gd")
const SIZE := 0.4   # of full size, the clef and the key signature alike
const FULL := {Song.Clef.TREBLE: 468, Song.Clef.BASS: 330}   # each clef's font size at full size
# The point that goes on the line, from the Label's top, as a share of the font size (measured
# on Segoe UI Symbol's glyphs): the treble clef's lower bowl's middle, its curl, on the G line;
# the midpoint of the bass clef's dots, by its head, on the F line.
const ON_LINE := {Song.Clef.TREBLE: 0.925, Song.Clef.BASS: 0.636}
const LINE := {Song.Clef.TREBLE: 4, Song.Clef.BASS: 8}   # G4 and F3, in steps (Staff.y_of())
const LEFT := {Song.Clef.TREBLE: 7.2, Song.Clef.BASS: 13.3}   # the Label's left edge, in the window's pixels
const KEY_AFTER := {Song.Clef.TREBLE: 258.0, Song.Clef.BASS: 236.0}   # the key signature's left edge at full size

@onready var _labels := {Song.Clef.TREBLE: $Treble as Label, Song.Clef.BASS: $Bass as Label}
@onready var _key: KeySignature = $KeySignature


## `clef`, with the key signature of `fifths` (sharps, or flats when below 0) after it.
func show_clef(clef: Song.Clef, fifths: int) -> void:
	for kind: Song.Clef in _labels:
		var label: Label = _labels[kind]
		label.visible = kind == clef
		var font_size := roundi(FULL[kind] * SIZE)
		label.label_settings.font_size = font_size
		label.position = Vector2(LEFT[kind], Staff.y_of(LINE[kind]) - ON_LINE[kind] * font_size)
		label.reset_size()
	_key.show_key(fifths, clef, LEFT[clef] + (KEY_AFTER[clef] - LEFT[clef]) * SIZE, SIZE)
