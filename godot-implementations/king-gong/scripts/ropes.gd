extends Control
## The two lianas a plank, a sign or a board hangs by, drawn up from its parent's top edge.
## Add it as a child of what hangs; it measures from the parent's own rect, so it works inside
## a container too, and ignores the mouse.

const EDGE := Color("8a6a3a")
const CORE := Color("c9a46a")
const WIDTH := 4.0

@export var inset := 36.0    # from each side of the parent
@export var length := 30.0   # up from the parent's top edge; 0 or less: up to the top of the screen


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	item_rect_changed.connect(queue_redraw)
	get_parent().item_rect_changed.connect(queue_redraw)


func _draw() -> void:
	var parent := get_parent() as Control
	var top := -position.y + 2.0   # the parent's top edge, a little inside it
	var up := length if length > 0.0 else parent.get_global_rect().position.y + 2.0
	for x: float in [inset, parent.size.x - inset]:
		var from := Vector2(x - position.x, top)
		var to := from - Vector2(0.0, up + 2.0)
		draw_line(from, to, EDGE, WIDTH)
		draw_line(from, to, CORE, WIDTH / 2.0)
