extends Control
## A little piano keyboard: the keys to play next lit in their colour with their names, the
## keys held down pressed in, and a wrong one grey with a red cross. On the chord's keyboard,
## `fold`, a note held outside its keys shows on the lit key of the same name, or else on its
## first octave, as the chord counts in any octave.

const Song := preload("res://scripts/song.gd")
const WHITE_W := 26.0
const WHITE_H := 74.0
const BLACK_W := 16.0
const BLACK_H := 46.0
const WHITE := Color("f4f1e6")
const BLACK := Color("23201c")
const EDGE := Color("5b564c")
const FAINT := Color("8f897c")
const DARK_TEXT := Color("2b2620")
const WRONG := Color("7d756d")       # not a colour any chord has
const CROSS := Color("ff3b30")

var fold := false
var letters := {}       # white key -> the computer key that plays it
var _lo := 60
var _hi := 71
var _lit := {}          # key -> [colour, name]
var _held := {}         # key -> true
var _wrong := {}        # key -> true


## The keys from `lo` to `hi`, out to white keys at both ends.
func set_range(lo: int, hi: int) -> void:
	_lo = lo - 1 if _is_black(lo) else lo
	_hi = hi + 1 if _is_black(hi) else hi
	custom_minimum_size = Vector2(_whites(_lo, _hi + 1) * WHITE_W, WHITE_H)
	queue_redraw()


## `lit`: midi -> [colour, name] of the keys to play; `held`: the notes held down, `wrong`
## those of them to show red.
func show_keys(lit: Dictionary, held: Array, wrong: Array) -> void:
	var held_keys := _keys_of(held, lit)
	var wrong_keys := _keys_of(wrong, lit)
	if lit == _lit and held_keys == _held and wrong_keys == _wrong:
		return
	_lit = lit
	_held = held_keys
	_wrong = wrong_keys
	queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	for m in range(_lo, _hi + 1):
		if _is_black(m):
			continue
		var x := _whites(_lo, m) * WHITE_W
		var rect := Rect2(x, 0.0, WHITE_W, WHITE_H)
		var fill := _fill(m, WHITE)
		draw_rect(rect, fill)
		draw_rect(rect, EDGE, false, 1.0)
		var ink := _ink(fill)
		if _lit.has(m):
			draw_string(font, Vector2(x, WHITE_H - 22.0), _lit[m][1], HORIZONTAL_ALIGNMENT_CENTER, WHITE_W, 12, ink)
		elif m % 12 == 0:   # every C, to find your way
			draw_string(font, Vector2(x, WHITE_H - 22.0), Song.note_name(m), HORIZONTAL_ALIGNMENT_CENTER, WHITE_W, 11, FAINT)
		if letters.has(m):
			draw_string(font, Vector2(x, WHITE_H - 6.0), letters[m], HORIZONTAL_ALIGNMENT_CENTER, WHITE_W, 11, ink if _lit.has(m) else FAINT)
		if _wrong.has(m):
			_cross(font, x, WHITE_W, BLACK_H + 16.0)
	for m in range(_lo, _hi + 1):
		if not _is_black(m):
			continue
		var x := _whites(_lo, m) * WHITE_W - BLACK_W / 2.0
		var fill := _fill(m, BLACK)
		draw_rect(Rect2(x, 0.0, BLACK_W, BLACK_H), fill)
		if _lit.has(m):
			draw_string(font, Vector2(x - 4.0, BLACK_H - 6.0), _lit[m][1], HORIZONTAL_ALIGNMENT_CENTER, BLACK_W + 8.0, 10, _ink(fill))
		if _wrong.has(m):
			_cross(font, x, BLACK_W, BLACK_H - 12.0)


func _cross(font: Font, x: float, width: float, y: float) -> void:
	draw_string(font, Vector2(x, y), "×", HORIZONTAL_ALIGNMENT_CENTER, width, 30, CROSS)


func _fill(m: int, base: Color) -> Color:
	if _wrong.has(m):
		return WRONG
	var colour: Color = _lit[m][0] if _lit.has(m) else base
	if not _held.has(m):
		return colour
	return colour.lightened(0.35) if colour == BLACK else colour.darkened(0.3)   # pressed in


func _ink(fill: Color) -> Color:
	return DARK_TEXT if fill.get_luminance() > 0.5 else Color.WHITE


## The key that shows note `m`: its own, or on the chord's keyboard if it has none, the `lit`
## key of the same name or that name in the first octave.
func _key(m: int, lit: Dictionary) -> int:
	if not fold or (m >= _lo and m <= _hi):
		return m
	for k: int in lit:
		if posmod(k - m, 12) == 0:
			return k
	return _lo + posmod(m - _lo, 12)


func _keys_of(notes: Array, lit: Dictionary) -> Dictionary:
	var out := {}
	for m: int in notes:
		var k := _key(m, lit)
		if k >= _lo and k <= _hi:
			out[k] = true
	return out


## White keys from `from` up to, not including, `to`.
func _whites(from: int, to: int) -> int:
	return range(from, to).filter(func(m: int) -> bool: return not _is_black(m)).size()


func _is_black(m: int) -> bool:
	return posmod(m, 12) in [1, 3, 6, 8, 10]
