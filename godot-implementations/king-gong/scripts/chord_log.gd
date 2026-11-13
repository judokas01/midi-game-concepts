extends Node2D
## A chord change: a log across the gorilla's path just before the branch where the new chord
## starts, coloured by the chord, with a sign on top that names it or writes it in the bass
## clef, on a taller board for a seventh, whose four notes reach a ledger line off the staff.
## The chord, played on time, breaks it: the top is kicked off and falls away, the stump
## stays. Run into, it shakes and stays up.

enum Hint { NAME, BASS_CLEF }

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
# by the chord's root, after the colours of Boomwhackers tubes; a minor chord is darker
const COLOURS := {"C": Color("d8453a"), "D": Color("ec8a2c"), "E": Color("e0bd2a"), "F": Color("4fa83d"),
	"G": Color("3f7fd8"), "A": Color("8a5bd1"), "B": Color("d65aa8")}
const SIGN_Y := Staff.SKY_TOP + 2.6 * Staff.STEP   # every sign hangs here, in the staff's top space
const BREAKS_BELOW := 1.9                          # steps below its branch: where the gorilla's foot lands
const SIGN_STEP := 5.5                             # half a line spacing of the sign's bass staff, in pixels
const BOARD := preload("res://art/chord_sign.svg")
const TALL_BOARD := preload("res://art/chord_sign_tall.svg")   # for a seventh in the bass clef

var _shake: Tween
var _tall := false   # four notes: in the bass clef, the taller board

@onready var _stump: Line2D = $Stump
@onready var _splinters: Sprite2D = $Splinters
@onready var _chips: CPUParticles2D = $Chips
@onready var _top: Node2D = $Top
@onready var _bark: Line2D = $Top/Bark
@onready var _sign: Node2D = $Top/Sign
@onready var _board: Sprite2D = $Top/Sign/Board
@onready var _name: Label = $Top/Sign/Name
@onready var _staff: Node2D = $Top/Sign/Staff
@onready var _key: Label = $Top/Sign/Key
@onready var _key_y := _key.position.y   # under the board


## Stands just before `note`'s branch, from the floor up to the sign.
func setup(note: Song.Note) -> void:
	position = Vector2(Staff.x_of(note.beat), Staff.FLOOR_Y + 0.3 * Staff.STEP)
	var break_y := Staff.y_of(note.step) + BREAKS_BELOW * Staff.STEP - position.y
	_stump.set_point_position(1, Vector2(0.0, break_y))
	for piece: Node2D in [_splinters, _chips, _top]:
		piece.position.y = break_y
	_sign.position.y = SIGN_Y - position.y - break_y
	_bark.set_point_position(1, _sign.position)
	var chord := note.chord
	var colour := colour_of(chord)
	_stump.default_color = colour
	_bark.default_color = colour
	_splinters.self_modulate = colour
	_chips.color = colour
	_name.text = chord.name
	var wide := _name.label_settings.font.get_string_size(chord.name, HORIZONTAL_ALIGNMENT_LEFT, -1, _name.label_settings.font_size).x
	_name.pivot_offset = _name.size / 2.0
	_name.scale = Vector2.ONE * minf(1.0, (_name.size.x - 4.0) / wide)   # "Cmaj7" shrinks to fit the board
	_tall = chord.steps.size() > 3
	for k in 4:
		var head: Sprite2D = _staff.get_node("Head%d" % (k + 1))
		var mark: Label = _staff.get_node("Accidental%d" % (k + 1))
		head.visible = k < chord.steps.size()
		mark.visible = head.visible
		if not head.visible:
			continue
		var y := (4 - chord.steps[k]) * SIGN_STEP   # the staff's middle line, D3, is step 4
		head.position.y = y
		mark.text = ["♭", "", "♯"][chord.accidentals[k] + 1]
		mark.position.y = y - mark.size.y / 2.0
	# past the spaces just off the staff (F2 below, B3 above): only a seventh, on E2 or up to C4
	_staff.get_node("LedgerBelow").visible = chord.steps.min() <= -2
	_staff.get_node("LedgerAbove").visible = chord.steps.max() >= 10


## By its root, darker for a minor chord.
static func colour_of(chord: Song.Chord) -> Color:
	return COLOURS[chord.name[0]].darkened(0.35 if chord.minor else 0.0)


## The chord by name or in the bass clef, and the computer key that plays it, if any.
func show_hint(hint: Hint, key: String) -> void:
	_name.visible = hint == Hint.NAME
	_staff.visible = hint == Hint.BASS_CLEF
	var tall := _tall and hint == Hint.BASS_CLEF
	_board.texture = TALL_BOARD if tall else BOARD
	_key.position.y = _key_y + (TALL_BOARD.get_height() - BOARD.get_height()) / 2.0 if tall else _key_y
	_key.text = "key " + key if key != "" else ""


## Where the gorilla's foot hits it.
func kick_spot() -> Vector2:
	return to_global(_top.position)


## Kicked: chips fly, the top topples away and the splintered stump stays.
func break_off() -> void:
	_splinters.show()
	_chips.restart()
	var fall := create_tween().set_parallel()
	fall.tween_property(_top, "rotation", 1.6, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_property(_top, "position", _top.position + Vector2(2.5, 6.0) * Staff.STEP, 0.9) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_property(_top, "modulate:a", 0.0, 0.4).set_delay(0.5)


## Run into: it shakes, and stays up.
func wobble() -> void:
	if _shake:
		_shake.kill()
	_shake = create_tween()
	for angle: float in [0.07, -0.05, 0.03, -0.015, 0.0]:
		_shake.tween_property(self, "rotation", angle, 0.1).set_trans(Tween.TRANS_SINE)
