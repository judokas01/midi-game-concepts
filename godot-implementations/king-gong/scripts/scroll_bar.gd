extends Control
## The library's scroll bar, beside its list: a groove as tall as the list, and in it a thumb
## as much of the groove as the lines shown are of the songs, as far down it as the first
## line shown is down the list. Hidden while every song fits. It only shows where the view
## is; the menu cursor and the wheel scroll the list, as before.

const GROOVE := Color(0.243137, 0.294118, 0.25098)    # as the edge of a line of the list
const THUMB := Color(0.941176, 0.862745, 0.690196)    # cream, as the captions: gold is the selection's
const MIN_THUMB := 24.0   # a long list's thumb stays this tall, so it is still seen

var _first := 0
var _shown := 0
var _total := 0
var _groove := _box(GROOVE)
var _thumb := _box(THUMB)


## Lines `first` to `first + shown - 1` of `total` are in view.
func show_view(first: int, shown: int, total: int) -> void:
	_first = first
	_shown = shown
	_total = total
	visible = total > shown
	queue_redraw()


## The thumb, in the bar's own coordinates.
func thumb() -> Rect2:
	if _total <= _shown:
		return Rect2(Vector2.ZERO, size)
	var h := clampf(size.y * _shown / _total, MIN_THUMB, size.y)
	return Rect2(0.0, (size.y - h) * _first / (_total - _shown), size.x, h)


func _draw() -> void:
	draw_style_box(_groove, Rect2(Vector2.ZERO, size))
	draw_style_box(_thumb, thumb())


static func _box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(4)
	return box
