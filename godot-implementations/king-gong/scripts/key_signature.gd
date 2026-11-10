extends Node2D
## The key signature, after the clef: a sharp or a flat on the line or space of each note the
## key raises or lowers, in the order and at the heights sheet music puts them. Every note of
## that name in the song is played so; no branch carries a sign of its own (see Song.check).

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
const SHARP := preload("res://art/sharp.svg")
const FLAT := preload("res://art/flat.svg")
# Where each goes in the treble clef, in steps above the ledger line below the staff (C4), in
# the order a key adds them: sharps F C G D A E B, flats B E A D G C F. The bass clef has
# them two steps lower.
const SHARP_STEPS: Array[int] = [10, 7, 11, 8, 5, 9, 6]
const FLAT_STEPS: Array[int] = [6, 9, 5, 8, 4, 7, 3]
# Each SVG's top-left corner, from its origin: the sharp's middle, the flat's stem level with
# the middle of its bowl. The origin goes on the line or space.
const SHARP_CORNER := Vector2(-31, -80)
const FLAT_CORNER := Vector2(-8, -98)
const SHARP_EVERY := 1.6 * Staff.STEP   # across, from one sign to the next
const FLAT_EVERY := 1.4 * Staff.STEP
const AFTER_CLEF := {Song.Clef.TREBLE: 258.0, Song.Clef.BASS: 236.0}   # the first sign's left edge, in pixels from the window's


## `fifths` sharps, or flats when below 0, in `clef`.
func show_key(fifths: int, clef: Song.Clef) -> void:
	for old in get_children():
		old.queue_free()
	position.x = AFTER_CLEF[clef]
	var sharps := fifths > 0
	var steps := SHARP_STEPS if sharps else FLAT_STEPS
	var corner := SHARP_CORNER if sharps else FLAT_CORNER
	var drop := 2 if clef == Song.Clef.BASS else 0
	for k in absi(fifths):
		var mark := Sprite2D.new()
		mark.texture = SHARP if sharps else FLAT
		mark.centered = false
		mark.offset = corner
		mark.position = Vector2(k * (SHARP_EVERY if sharps else FLAT_EVERY) - corner.x, Staff.y_of(steps[k] - drop))
		add_child(mark)
