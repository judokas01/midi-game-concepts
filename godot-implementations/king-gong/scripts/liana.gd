extends Node2D
## A rest: a liana slung low across the gap after a branch, between two posts. The gorilla
## drops into it, it dips, and throws the gorilla back up.

const Staff := preload("res://scripts/staff.gd")
const SLACK := 0.45 * Staff.STEP   # how far the middle hangs below the posts with nobody in it

var width := 0.0

@onready var _vine: Line2D = $Vine
@onready var _leaves: Node2D = $Leaves
@onready var _post_right: ColorRect = $PostRight


## Spans from x0 to x1, in world pixels.
func setup(x0: float, x1: float) -> void:
	position = Vector2(x0, Staff.LIANA_Y - 0.3 * Staff.STEP)
	width = x1 - x0
	_post_right.position.x = width - 0.15 * Staff.STEP
	set_sag(SLACK)


## The vine is a curve through both posts; `sag` is how far its middle hangs.
func set_sag(sag: float) -> void:
	var bend := Vector2(width / 2.0, 2.0 * sag)
	var points := PackedVector2Array()
	for k in 13:
		points.append(_along(bend, k / 12.0))
	_vine.points = points
	for i in _leaves.get_child_count():
		var t := 0.1 + 0.16 * i
		var leaf: Node2D = _leaves.get_child(i)
		leaf.position = _along(bend, t) + Vector2(0.0, 0.12 * Staff.STEP)
		leaf.rotation = t * 6.0


func _along(bend: Vector2, t: float) -> Vector2:
	return Vector2.ZERO.lerp(bend, t).lerp(bend.lerp(Vector2(width, 0.0), t), t)
