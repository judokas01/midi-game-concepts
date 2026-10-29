extends Node2D
## One note of the tune: a branch on its staff line, as long as the note lasts, drawn as two
## halves meeting at the grip. While the gorilla hangs on it, it breaks away piece by piece
## from its left end, and its last piece, at the right end, falls when it is time to let go.
## The piece under the gorilla's hand holds until it does; hung on too long, it bends, cracks
## and snaps.

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
const PIECE := 0.3 * Staff.STEP    # the branch comes away in pieces about this long
const STUB := 0.2 * Staff.STEP     # half the piece under the gorilla's hand

var _half := 0.0
var _broken := false
var _has_banana := false
var _pieces: Array[Line2D] = []   # once hung on: the pieces of wood still on the branch, the stub among them
var _stub: Line2D
var _drops: Array[Tween] = []     # the pieces falling

@onready var _left: Node2D = $Left
@onready var _right: Node2D = $Right
@onready var _twig: Sprite2D = $Left/Twig
@onready var _leaves: Sprite2D = $Right/Leaves
@onready var _piece_layer: Node2D = $Pieces
@onready var _cracks: Node2D = $Cracks
@onready var _banana: Node2D = $Banana
@onready var _label: Label = $NoteLabel


func setup(note: Song.Note) -> void:
	position = Staff.note_pos(note)
	_half = Staff.branch_length(note) / 2.0
	_left.position.x = -_half
	$Left/Wood.set_point_position(1, Vector2(_half, 0.0))
	_right.position.x = _half
	$Right/Wood.set_point_position(0, Vector2(-_half, 0.0))
	# near the right end, on the last piece to fall, so it is still there at the let-go
	_banana.position.x = _half - 0.2 * Staff.STEP
	_has_banana = note.banana
	_banana.visible = _has_banana
	set_strain(0.0, 0.0)


func set_label(text: String) -> void:
	_label.text = text
	_label.visible = text != "" and not _broken


## Left behind: drawn faded from now on.
func mark_done() -> void:
	modulate.a = 0.5


func take_banana() -> void:
	_has_banana = false
	_banana.hide()


## Where the banana hangs, in the world.
func banana_spot() -> Vector2:
	return $Banana/Fruit.global_position


## `sag` in pixels at the grip; `crack` 0..1 shows up to three cracks. The pieces still on
## bend about the branch's two ends.
func set_strain(sag: float, crack: float) -> void:
	if _broken:
		return
	var bend := atan2(sag, _half)
	for piece in _pieces:
		piece.position.y = (_half - absf(piece.position.x)) * sin(bend)
		piece.rotation = -signf(piece.position.x) * bend
	_cracks.position.y = sag
	for i in _cracks.get_child_count():
		_cracks.get_child(i).visible = i < ceili(crack * 3.0)


## The gorilla is `p` of the way through its note on this branch, 1 when it should let go.
## The break runs from the left end at 0 to the right end at 1, and each piece falls once it
## has passed it, but the stub.
func crumble(p: float) -> void:
	if _stub == null:
		_split()
	var x := lerpf(-_half, _half, p)
	for piece in _pieces.duplicate():
		if piece != _stub and piece.position.x + piece.get_point_position(1).x <= x + 0.5:
			_drop(piece)


## The gorilla let go, or fell: the stub it held falls too.
func let_go() -> void:
	if _stub in _pieces:
		_drop(_stub)


## Held too long: the stub snaps.
func break_off() -> void:
	_broken = true
	_label.hide()
	_cracks.hide()
	_banana.hide()
	let_go()


## Grown back, for the retry after a magic banana.
func restore() -> void:
	for drop in _drops:
		drop.kill()
	_drops.clear()
	_broken = false
	_cracks.show()
	_banana.visible = _has_banana
	_label.visible = _label.text != ""
	_mend()
	set_strain(0.0, 0.0)


## The wood becomes pieces that can fall one by one, with the stub under the hand among
## them. The twig goes with the first piece and the leaves with the last.
func _split() -> void:
	var wood: Line2D = $Left/Wood
	var stub := minf(STUB, _half)
	var spans: Array[Vector2] = []   # each piece's left and right end
	var stub_at := 0
	for side: Vector2 in [Vector2(-_half, -stub), Vector2(stub, _half)]:
		var n := roundi((side.y - side.x) / PIECE)
		for k in n:
			spans.append(Vector2(lerpf(side.x, side.y, float(k) / n), lerpf(side.x, side.y, float(k + 1) / n)))
		if side.x < 0.0:
			stub_at = spans.size()
			spans.append(Vector2(-stub, stub))
	for k in spans.size():
		var length := spans[k].y - spans[k].x
		var piece: Line2D = wood.duplicate()
		piece.position = Vector2(spans[k].x + length / 2.0, 0.0)
		piece.points = PackedVector2Array([Vector2(-length / 2.0, 0.0), Vector2(length / 2.0, 0.0)])
		piece.begin_cap_mode = Line2D.LINE_CAP_ROUND if k == 0 else Line2D.LINE_CAP_NONE
		piece.end_cap_mode = Line2D.LINE_CAP_ROUND if k == spans.size() - 1 else Line2D.LINE_CAP_NONE
		_piece_layer.add_child(piece)
		_pieces.append(piece)
	_stub = _pieces[stub_at]
	wood.hide()
	$Right/Wood.hide()
	_twig.reparent(_pieces[0])
	_twig.show_behind_parent = true
	_leaves.reparent(_pieces[-1])


## The branch whole again: twig and leaves back on their halves, the pieces gone.
func _mend() -> void:
	if _stub == null:
		return
	for end: Array in [[_twig, _left], [_leaves, _right]]:
		var sprite: Sprite2D = end[0]
		sprite.reparent(end[1], false)
		sprite.position = Vector2.ZERO
		sprite.rotation = 0.0
	_left.move_child(_twig, 0)
	_twig.show_behind_parent = false
	for piece in _piece_layer.get_children():
		piece.queue_free()
	_pieces.clear()
	_stub = null
	$Left/Wood.show()
	$Right/Wood.show()


## `piece` falls off the branch, turning, and fades.
func _drop(piece: Line2D) -> void:
	_pieces.erase(piece)
	var fall := create_tween().set_parallel()
	fall.tween_property(piece, "position", piece.position + Vector2(0.3, 4.0) * Staff.STEP, 0.7) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_property(piece, "rotation", piece.rotation + randf_range(-1.2, 1.2), 0.7)
	fall.tween_property(piece, "modulate:a", 0.0, 0.3).set_delay(0.4)
	_drops.append(fall)
