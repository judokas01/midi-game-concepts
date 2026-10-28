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


## How far across the liana (0..1) the world position `x` is.
func across(x: float) -> float:
	return clampf(to_local(Vector2(x, 0.0)).x / width, 0.05, 0.95)


## The vine hangs `sag` below the posts at its lowest point, `at` of the way across: the middle
## when nobody is in it, under the gorilla when it lands.
func set_sag(sag: float, at := 0.5) -> void:
	var points := PackedVector2Array()
	for k in 13:
		points.append(_along(k / 12.0, sag, at))
	_vine.points = points
	for i in _leaves.get_child_count():
		var t := 0.1 + 0.16 * i
		var leaf: Node2D = _leaves.get_child(i)
		leaf.position = _along(t, sag, at) + Vector2(0.0, 0.12 * Staff.STEP)
		leaf.rotation = t * 6.0


func _along(t: float, sag: float, at: float) -> Vector2:
	var u := t / at if t < at else (1.0 - t) / (1.0 - at)   # 0 at a post, 1 at the lowest point
	return Vector2(t * width, sag * (1.0 - (1.0 - u) * (1.0 - u)))
