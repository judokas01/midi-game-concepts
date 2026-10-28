extends Node2D
## One note of the tune: a branch on its staff line, thin for one beat and thick for two.
## The sprite is split in two halves that bend when the gorilla hangs on too long and
## come apart when the branch breaks.

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
const THIN := preload("res://art/branch_thin.svg")
const THICK := preload("res://art/branch_thick.svg")

var thickness := 0.0

var _done := false
var _broken := false
var _has_banana := false
var _break: Tween

@onready var _left: Sprite2D = $Left
@onready var _right: Sprite2D = $Right
@onready var _cracks: Node2D = $Cracks
@onready var _banana: Node2D = $Banana
@onready var _label: Label = $NoteLabel


func setup(note: Song.Note) -> void:
	position = Staff.note_pos(note)
	var thick := note.beats >= 2
	_left.texture = THICK if thick else THIN
	_right.texture = _left.texture
	thickness = (0.6 if thick else 0.26) * Staff.STEP
	_cracks.scale.y = thickness / (0.6 * Staff.STEP)   # crack.svg is drawn for a thick branch
	_label.position.y = -thickness / 2.0 - 0.12 * Staff.STEP - _label.size.y
	_has_banana = note.banana
	_banana.visible = _has_banana
	$Banana/Stem.set_point_position(1, Vector2(0.0, thickness / 2.0 + 0.3 * Staff.STEP))
	$Banana/Fruit.position.y = thickness / 2.0 + 0.8 * Staff.STEP
	set_strain(0.0, 0.0)


func set_label(text: String) -> void:
	_label.text = text
	_label.visible = text != "" and not _broken


## Left behind: drawn faded from now on.
func mark_done() -> void:
	_done = true
	modulate.a = 0.5


func take_banana() -> void:
	_has_banana = false
	_banana.hide()


## `sag` in pixels at the grip; `crack` 0..1 shows up to three cracks.
func set_strain(sag: float, crack: float) -> void:
	if _broken:
		return
	var bend := atan2(sag, Staff.HALF_BRANCH)
	_left.rotation = bend
	_right.rotation = -bend
	_cracks.position.y = sag
	for i in _cracks.get_child_count():
		_cracks.get_child(i).visible = i < ceili(crack * 3.0)


func break_off() -> void:
	_broken = true
	_label.hide()
	_cracks.hide()
	_banana.hide()
	_break = create_tween().set_parallel()
	_break.tween_property(_left, "rotation", 1.2, 0.4)
	_break.tween_property(_right, "position:y", 20.0 * Staff.STEP * 1.6 * 1.6, 1.6) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_break.tween_property(_right, "rotation", -3.2, 1.6)
	_break.tween_property(self, "modulate:a", 0.0, 1.0).set_delay(0.6)


## Grown back, for the retry after a magic banana.
func restore() -> void:
	if _break:
		_break.kill()
	_broken = false
	_right.position.y = 0.0
	modulate.a = 0.5 if _done else 1.0
	_cracks.show()
	_banana.visible = _has_banana
	_label.visible = _label.text != ""
	set_strain(0.0, 0.0)
