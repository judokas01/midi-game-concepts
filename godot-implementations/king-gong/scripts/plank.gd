extends Button
## A wooden plank on the menus (theme variation Plank). It hangs a little askew and, under the
## mouse, straightens and grows a touch, like a sign you reach for. A disabled one stays put.
## A container sets its children straight whenever it lays them out, so the plank hangs itself
## again after every layout of its parent.

const GROW := 1.04
const EASE_S := 0.12

@export var tilt := 0.0   # degrees, as it hangs

var _reached := false     # the mouse is on it
var _ease: Tween


func _ready() -> void:
	resized.connect(func() -> void: pivot_offset = size / 2.0)
	var box := get_parent() as Container
	if box:
		box.sort_children.connect(_hang)
	mouse_entered.connect(_lean.bind(true))
	mouse_exited.connect(_lean.bind(false))
	_hang()


## Where it rests: askew, or straight and a touch bigger under the mouse.
func _hang() -> void:
	pivot_offset = size / 2.0
	rotation_degrees = 0.0 if _reached else tilt
	scale = Vector2.ONE * (GROW if _reached else 1.0)


func _lean(reached: bool) -> void:
	if disabled and reached:
		return
	_reached = reached
	if _ease:
		_ease.kill()
	_ease = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_ease.tween_property(self, "rotation_degrees", 0.0 if reached else tilt, EASE_S)
	_ease.tween_property(self, "scale", Vector2.ONE * (GROW if reached else 1.0), EASE_S)
