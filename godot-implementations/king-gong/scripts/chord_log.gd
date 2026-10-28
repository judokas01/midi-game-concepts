extends Node2D
## A chord change: a log across the gorilla's path just before the branch where the new chord
## starts, coloured by the chord, with a sign on top that names it or writes it in the bass
## clef. The chord, played on time, breaks it: the top is kicked off and falls away, the stump
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

var _shake: Tween

@onready var _stump: Line2D = $Stump
@onready var _splinters: Sprite2D = $Splinters
@onready var _chips: CPUParticles2D = $Chips
@onready var _top: Node2D = $Top
@onready var _bark: Line2D = $Top/Bark
@onready var _sign: Node2D = $Top/Sign
@onready var _name: Label = $Top/Sign/Name
@onready var _staff: Node2D = $Top/Sign/Staff
@onready var _key: Label = $Top/Sign/Key


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
	var colour: Color = COLOURS[chord.name[0]].darkened(0.35 if chord.minor else 0.0)
	_stump.default_color = colour
	_bark.default_color = colour
	_splinters.self_modulate = colour
	_chips.color = colour
	_name.text = chord.name
	for k in 3:
		var y := (4 - chord.steps[k]) * SIGN_STEP   # the staff's middle line, D3, is step 4
		(_staff.get_node("Head%d" % (k + 1)) as Sprite2D).position.y = y
		var mark: Label = _staff.get_node("Accidental%d" % (k + 1))
		mark.text = ["♭", "", "♯"][chord.accidentals[k] + 1]
		mark.position.y = y - mark.size.y / 2.0


## The chord by name or in the bass clef, and the computer key that plays it, if any.
func show_hint(hint: Hint, key: String) -> void:
	_name.visible = hint == Hint.NAME
	_staff.visible = hint == Hint.BASS_CLEF
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
