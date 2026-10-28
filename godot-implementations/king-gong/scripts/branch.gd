extends Node2D
## One note of the tune: a branch on its staff line, as long as the note lasts. It is two
## halves meeting at the grip, which bend when the gorilla hangs on too long and come apart
## when the branch breaks.

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")

var _half := 0.0
var _done := false
var _broken := false
var _has_banana := false
var _break: Tween

@onready var _left: Node2D = $Left
@onready var _right: Node2D = $Right
@onready var _cracks: Node2D = $Cracks
@onready var _banana: Node2D = $Banana
@onready var _label: Label = $NoteLabel


func setup(note: Song.Note) -> void:
	position = Staff.note_pos(note)
	_half = Staff.branch_length(note) / 2.0
	# each half pivots on its outer end
	_left.position.x = -_half
	$Left/Wood.set_point_position(1, Vector2(_half, 0.0))
	_right.position.x = _half
	$Right/Wood.set_point_position(0, Vector2(-_half, 0.0))
	_banana.position.x = minf(_banana.position.x, 0.9 * _half)   # a short branch holds it nearer the middle
	_has_banana = note.banana
	_banana.visible = _has_banana
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
	var bend := atan2(sag, _half)
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
