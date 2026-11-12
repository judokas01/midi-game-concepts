extends Control
## How much of the level is done, along the top edge of the screen: a yellow line that fills
## as the gorilla crosses the level, faint ticks at the quarters, and the percentage under the
## knob at its end. A light glide smooths over the moments the gorilla stands still or swings
## back; going back (a restart, a new song) the line snaps.

const HEIGHT := 6.0
const KNOB := 6.0          # the knob's radius, its dark rim included
const RIM := 2.0
const LAG := 0.3           # seconds: the glide's smoothing time; the line trails the gorilla by about twice this
const TRACK := Color(0.04, 0.063, 0.04, 0.45)
const FILL := Color("f2c230")   # the colour of the next note on the little keyboard
const GLOW := Color(0.949, 0.761, 0.188, 0.3)
const TICK := Color(1.0, 1.0, 1.0, 0.18)
const RIM_COLOUR := Color("2b3a2c")
const TEXT := Color("f7e7a6")
const SHADOW := Color(0.0, 0.0, 0.0, 0.8)
const FONT_SIZE := 13
const CLEAR := 8.0         # the percentage keeps this far left of keep_clear

var keep_clear: Control    # the pill: the percentage stops short of it, so it is never hidden under it
var _target := 0.0         # the share of the level done, 0 to 1
var _shown := 0.0          # the share drawn, gliding towards _target
var _speed := 0.0          # of the glide, in shares a second


func _ready() -> void:
	set_process(false)


func show_progress(share: float) -> void:
	if share == _target:
		return
	_target = share
	if _target < _shown:
		_shown = _target
		_speed = 0.0
		queue_redraw()
	set_process(true)


## A critically damped spring towards the share done: smooth in speed too, so the line never
## lurches.
func _process(delta: float) -> void:
	var omega := 2.0 / LAG
	var x := omega * delta
	var decay := 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var gap := _shown - _target
	var pull := (_speed + omega * gap) * delta
	_speed = (_speed - omega * pull) * decay
	_shown = _target + (gap + pull) * decay
	if absf(_target - _shown) < 0.0005 and absf(_speed) < 0.001:
		_shown = _target
		_speed = 0.0
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	draw_rect(Rect2(0.0, 0.0, w, HEIGHT), TRACK)
	for quarter: float in [0.25, 0.5, 0.75]:
		draw_rect(Rect2(w * quarter - 1.0, 0.0, 2.0, HEIGHT), TICK)
	var x := w * _shown
	draw_rect(Rect2(0.0, 0.0, x, HEIGHT + 3.0), GLOW)
	draw_rect(Rect2(0.0, 0.0, x, HEIGHT), FILL)
	var knob := Vector2(_knob_x(), HEIGHT / 2.0)
	draw_circle(knob, KNOB, RIM_COLOUR)
	draw_circle(knob, KNOB - RIM, FILL)
	var font := get_theme_default_font()
	var at := _label_box().position + Vector2(0.0, font.get_ascent(FONT_SIZE))
	draw_string(font, at + Vector2(0.0, 1.0), _label_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, SHADOW)
	draw_string(font, at, _label_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, TEXT)


## Where the percentage is drawn, on screen.
func label_rect() -> Rect2:
	var box := _label_box()
	box.position += global_position
	return box


func _knob_x() -> float:
	return clampf(size.x * _shown, KNOB, size.x - KNOB)


func _label_text() -> String:
	return "%d%%" % floori(_shown * 100.0)


## The percentage's box, here: centred under the knob, inside the screen, and left of
## keep_clear once the knob passes over it.
func _label_box() -> Rect2:
	var text_size := get_theme_default_font().get_string_size(_label_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE)
	var right := size.x - 2.0
	if keep_clear and keep_clear.visible:
		right = minf(right, keep_clear.get_global_rect().position.x - global_position.x - CLEAR)
	var x := clampf(_knob_x() - text_size.x / 2.0, 2.0, right - text_size.x)
	return Rect2(Vector2(x, HEIGHT + KNOB), text_size)
