extends Control
## The sign beside the selection on the menus: a little wooden board, pointed towards what is
## selected, with one octave C to B on it. The keys that do something there are gold with
## their mark (C ▲, D ▼, E ◀, F ▶, A ✓, B ✕); a key flashes darker as it is played. Made and
## placed by the menu cursor (menu_cursor.gd), which says what is lit by its acts.

const KEY_W := 14.0
const KEY_H := 44.0
const BLACK_W := 9.0
const BLACK_H := 26.0
const POINT := 18.0                     # how far the point reaches out on the left
const KEYS_AT := Vector2(24.0, 7.0)
const SIZE := Vector2(131.0, 59.0)
const WOOD_TOP := Color("a7774a")
const WOOD_MID := Color("80562f")
const WOOD_BOTTOM := Color("62401f")
const WHITE := Color("f4f1e6")
const BLACK := Color("23201c")
const EDGE := Color("5b564c")
const GOLD := Color("f2c230")
const INK := Color("2b2620")
const HIT := Color("b9860c")
const BLACK_BEFORE := [1, 2, 4, 5, 6]   # a black key sits on the line before these white keys
const KEY_OF_ACT := [0, 1, 2, 3, 5, 6]  # the white key of each act, in MenuCursor.Act order: C D E F A B
const FLASH_MS := 150.0

var _acts: Array = []      # MenuCursor.Act numbers lit
var _flashed := -1         # the white key flashing, -1 for none
var _flash_until := 0.0


func _ready() -> void:
	size = SIZE
	custom_minimum_size = SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Lights the keys of `acts` (MenuCursor.Act numbers) with their marks.
func show_acts(acts: Array) -> void:
	if acts == _acts:
		return
	_acts = acts.duplicate()
	queue_redraw()


## The key of `act` flashes as if played.
func flash(act: int) -> void:
	_flashed = KEY_OF_ACT[act]
	_flash_until = Time.get_ticks_msec() + FLASH_MS
	queue_redraw()


func _process(_delta: float) -> void:
	if _flashed >= 0 and Time.get_ticks_msec() >= _flash_until:
		_flashed = -1
		queue_redraw()


func _draw() -> void:
	var outline := PackedVector2Array([Vector2(POINT, 0.0), Vector2(SIZE.x, 0.0), SIZE,
		Vector2(POINT, SIZE.y), Vector2(0.0, SIZE.y / 2.0)])
	var shadow := PackedVector2Array()
	for p in outline:
		shadow.append(p + Vector2(0.0, 3.0))
	draw_colored_polygon(shadow, Color(0.0, 0.0, 0.0, 0.35))
	draw_polygon(outline, PackedColorArray([WOOD_TOP, WOOD_TOP, WOOD_BOTTOM, WOOD_BOTTOM, WOOD_MID]))
	var edge := outline.duplicate()
	edge.append(outline[0])
	draw_polyline(edge, WOOD_BOTTOM.darkened(0.25), 1.0, true)   # smooths the point's edges
	for k in range(1, 8):   # the grain, a little uneven
		var y := k * SIZE.y / 8.0 + sin(k * 1.7) * 1.5
		var from_x := POINT * absf(y - SIZE.y / 2.0) / (SIZE.y / 2.0) + 2.0
		draw_line(Vector2(from_x, y), Vector2(SIZE.x - 2.0, y + 1.0), Color(0.0, 0.0, 0.0, 0.09), 1.0)
	draw_line(Vector2(POINT, 1.0), Vector2(SIZE.x - 1.0, 1.0), Color(1.0, 0.86, 0.63, 0.35), 1.0)
	draw_line(Vector2(POINT, SIZE.y - 1.0), Vector2(SIZE.x - 1.0, SIZE.y - 1.0), Color(0.0, 0.0, 0.0, 0.3), 2.0)
	var lit := {}
	for act: int in _acts:
		lit[KEY_OF_ACT[act]] = act
	for i in 7:
		var key := Rect2(KEYS_AT + Vector2(i * KEY_W, 0.0), Vector2(KEY_W, KEY_H))
		var fill := WHITE
		if lit.has(i):
			fill = HIT if i == _flashed else GOLD
		draw_rect(key, fill)
		draw_rect(key, EDGE, false, 1.0)
	for b: int in BLACK_BEFORE:
		draw_rect(Rect2(KEYS_AT.x + b * KEY_W - BLACK_W / 2.0, KEYS_AT.y, BLACK_W, BLACK_H), BLACK)
	for i: int in lit:
		_mark(lit[i], KEYS_AT + Vector2(i * KEY_W + KEY_W / 2.0, KEY_H - 9.0))


## The mark of `act`, drawn round `c`: a triangle for the four ways, a tick, a cross.
func _mark(act: int, c: Vector2) -> void:
	var s := 4.5
	match act:
		0:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s, s * 0.8), c + Vector2(-s, s * 0.8)]), INK)
		1:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, s), c + Vector2(-s, -s * 0.8), c + Vector2(s, -s * 0.8)]), INK)
		2:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-s, 0), c + Vector2(s * 0.8, -s), c + Vector2(s * 0.8, s)]), INK)
		3:
			draw_colored_polygon(PackedVector2Array([c + Vector2(s, 0), c + Vector2(-s * 0.8, s), c + Vector2(-s * 0.8, -s)]), INK)
		4:
			draw_polyline(PackedVector2Array([c + Vector2(-s, 0), c + Vector2(-s * 0.3, s * 0.8), c + Vector2(s, -s)]), INK, 2.0, true)
		5:
			draw_line(c + Vector2(-s * 0.8, -s * 0.8), c + Vector2(s * 0.8, s * 0.8), INK, 2.0, true)
			draw_line(c + Vector2(-s * 0.8, s * 0.8), c + Vector2(s * 0.8, -s * 0.8), INK, 2.0, true)
