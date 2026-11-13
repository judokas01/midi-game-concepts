extends Control
## The selection on the menus. Worked with six white keys of the piano in any octave (C ▲ and
## D ▼ move it, E ◀ and F ▶ change the selected row, A ✓ presses, B ✕ goes back), with the
## arrows, Enter, Space and Esc, which hud.gd turns into the same acts, or with the mouse,
## which selects what it points at. Each menu hands it its rows; it shows what is selected (a
## plank straightened, a yellow button lit, or a frame round the row and the cell) and puts the
## sign (menu_sign.gd) beside it, the keys that do something there lit.

signal back_requested

enum Act { UP, DOWN, LEFT, RIGHT, PRESS, BACK }
enum Kind { PRESS, CELLS, CHOICE, VALUE }

const MenuSign := preload("res://scripts/menu_sign.gd")
const NOTE_ACTS := {0: Act.UP, 2: Act.DOWN, 4: Act.LEFT, 5: Act.RIGHT, 9: Act.PRESS, 11: Act.BACK}   # by pitch class
const KEY_ACTS := {KEY_UP: Act.UP, KEY_DOWN: Act.DOWN, KEY_LEFT: Act.LEFT, KEY_RIGHT: Act.RIGHT}
const MARK := Color("f2c230")    # the frames: the colour of the next note on the little keyboard
const OWN_LOOKS := [&"Plank", &"StartButton"]   # these show being selected themselves, no frame
const SIGN_GAP := 8.0


## A row of a menu, made by press(), cells(), choice() or value().
class Row:
	var kind := 0
	var cells: Array[Button] = []   # what A presses (a press row's one, a cell row's), or a choice's options
	var cell := 0                   # the cell under the cursor
	var step: Callable              # a value row's step(by)
	var can_step: Callable          # and whether it can step by `by`
	var parts: Array[Control] = []  # framed together; the first is the row itself, hidden with it

	## Its own `visible` and every parent's, read directly: while a menu's visibility_changed
	## runs, is_visible_in_tree() of what is in it still says what it was.
	func shown() -> bool:
		var node: Node = parts[0]
		while node is CanvasItem:
			if not (node as CanvasItem).visible:
				return false
			node = node.get_parent()
		return true


var _rows: Array = []
var _at := -1                 # the selected row, -1 with no menu
var _anchor: Control          # the board the sign sits outside, or null
var _back := false            # B goes somewhere here
var _sign_from := 0.0         # ms; the sign shows from then
var _lit_button: Button       # the selected button showing it itself
var _sign: MenuSign


## A button or plank, or an on/off, which E and F flip too.
static func press(button: Button, parts: Array = []) -> Row:
	return _row(Kind.PRESS, [button], 0, parts if not parts.is_empty() else [button])


## Buttons side by side, walked with E and F round from one end to the other; A presses the
## one under the cursor, `start` at first.
static func cells(buttons: Array, start := 0, parts: Array = []) -> Row:
	return _row(Kind.CELLS, buttons, start, parts if not parts.is_empty() else [buttons[0].get_parent()])


## One of several, as a radio: E and F pick the one before or after, stopping at the ends.
static func choice(buttons: Array, parts: Array) -> Row:
	return _row(Kind.CHOICE, buttons, 0, parts)


## A value E and F step down and up: `step(by)`, as long as `can_step(by)`.
static func value(step: Callable, can_step: Callable, parts: Array) -> Row:
	var row := _row(Kind.VALUE, [], 0, parts)
	row.step = step
	row.can_step = can_step
	return row


static func _row(kind: Kind, buttons: Array, cell: int, parts: Array) -> Row:
	var row := Row.new()
	row.kind = kind
	row.cells.assign(buttons)
	row.cell = cell
	row.parts.assign(parts)
	return row


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # it works the pause menu
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_sign = MenuSign.new()
	_sign.name = "Sign"
	_sign.hide()
	add_child(_sign)


## Works the menu of `rows`, from row `start` (the last if negative). The sign sits outside
## `anchor`, a board, or beside the selected button without one; it shows `sign_after_s`
## seconds from now. `back`: B goes somewhere here.
func use(rows: Array, start: int, anchor: Control, back: bool, sign_after_s := 0.0) -> void:
	_unlight()
	_rows = rows
	_anchor = anchor
	_back = back
	_sign_from = Time.get_ticks_msec() + sign_after_s * 1000.0
	for row: Row in rows:
		for button in _buttons_of(row):
			_hook(button)
	_select(_shown_from(start if start >= 0 else rows.size() - 1, 1))


## No menu: nothing selected, no sign.
func clear() -> void:
	_unlight()
	_rows = []
	_at = -1
	_sign.hide()
	queue_redraw()


## Does `a` where the cursor is, if it does something there, and flashes its key on the sign.
func act(a: Act) -> void:
	if not a in lit():
		return
	_sign.flash(a)
	var row: Row = _rows[_at]
	match a:
		Act.UP, Act.DOWN:
			_move(-1 if a == Act.UP else 1)
		Act.LEFT, Act.RIGHT:
			_side(row, -1 if a == Act.LEFT else 1)
		Act.PRESS:
			_press(selected())
		Act.BACK:
			back_requested.emit()


## The acts that would do something now, in Act order.
func lit() -> Array[int]:
	var out: Array[int] = []
	if _at < 0:
		return out
	var row: Row = _rows[_at]
	if _rows.filter(func(r: Row) -> bool: return r.shown()).size() > 1:
		out.append_array([Act.UP, Act.DOWN])
	if _can_side(row, -1):
		out.append(Act.LEFT)
	if _can_side(row, 1):
		out.append(Act.RIGHT)
	if (row.kind == Kind.PRESS or row.kind == Kind.CELLS) and not (selected() as Button).disabled:
		out.append(Act.PRESS)
	if _back:
		out.append(Act.BACK)
	return out


## The button under the cursor; on a choice or a value, its row (its first part).
func selected() -> Control:
	if _at < 0:
		return null
	var row: Row = _rows[_at]
	match row.kind:
		Kind.PRESS:
			return row.cells[0]
		Kind.CELLS:
			return row.cells[row.cell]
	return row.parts[0]


func sign_shown() -> bool:
	return _at >= 0 and Time.get_ticks_msec() >= _sign_from


func _process(_delta: float) -> void:
	if _at < 0:
		return
	if not _rows[_at].shown():   # its row went away under it
		_select(_shown_from(_at, 1))
		return
	queue_redraw()   # planks swing and boards settle: the frames follow
	_place_sign()


func _draw() -> void:
	if _at < 0 or _lit_button:
		return
	var row: Row = _rows[_at]
	_frame(_rect_of(row.parts).grow(4.0), 1.0, 0.08)
	if row.kind == Kind.CELLS:
		_frame(_global_rect(selected()).grow(2.0), 2.0, 0.0)


func _frame(rect: Rect2, width: float, fill: float) -> void:
	var at := Rect2(rect.position - global_position, rect.size)
	if fill > 0.0:
		draw_rect(at, Color(MARK, fill))
	draw_rect(at, MARK, false, width)


## The sign at the selected row's height, just outside the board, or beside the selected
## button without one; inside the screen, but never over the row.
func _place_sign() -> void:
	var row: Row = _rows[_at]
	var rect := _rect_of(row.parts)
	var x := (_anchor.get_global_rect().end.x if _anchor else _global_rect(selected()).end.x) + SIGN_GAP
	x = minf(x, get_viewport_rect().size.x - _sign.size.x - 4.0)
	x = maxf(x, rect.end.x + 4.0)
	_sign.global_position = Vector2(x, rect.get_center().y - _sign.size.y / 2.0)
	_sign.visible = sign_shown()
	_sign.show_acts(lit())


func _move(by: int) -> void:
	var from: Row = _rows[_at]
	var to := _shown_from(posmod(_at + by, _rows.size()), by)
	var row: Row = _rows[to]
	if row.kind == Kind.CELLS and from.kind == Kind.CELLS and row != from:
		row.cell = _nearest(row, _global_rect(selected()).get_center().x)
	_select(to)


func _can_side(row: Row, by: int) -> bool:
	match row.kind:
		Kind.PRESS:
			return row.cells[0].toggle_mode and row.cells[0].button_group == null and not row.cells[0].disabled
		Kind.CELLS:
			return row.cells.size() > 1
		Kind.CHOICE:
			var i := _chosen(row)
			return i < 0 or (i + by >= 0 and i + by < row.cells.size())
		Kind.VALUE:
			return row.can_step.call(by)
	return false


func _side(row: Row, by: int) -> void:
	match row.kind:
		Kind.PRESS:
			_press(row.cells[0])
		Kind.CELLS:
			row.cell = posmod(row.cell + by, row.cells.size())
			_select(_at)
		Kind.CHOICE:
			var i := _chosen(row)
			_press(row.cells[i + by if i >= 0 else (0 if by > 0 else row.cells.size() - 1)])
		Kind.VALUE:
			row.step.call(by)


## As a click would: a button is pressed, one of a group chosen, an on/off flipped.
func _press(button: Button) -> void:
	if button.disabled:
		return
	if not button.toggle_mode:
		button.pressed.emit()
	elif button.button_group:
		button.button_pressed = true
	else:
		button.button_pressed = not button.button_pressed


func _select(i: int) -> void:
	_unlight()
	_at = i
	queue_redraw()
	if i < 0:
		_sign.hide()
		return
	var button := selected() as Button
	if button and button.theme_type_variation in OWN_LOOKS:
		_lit_button = button
		_light(button, true)
	_place_sign()


func _unlight() -> void:
	if _lit_button and is_instance_valid(_lit_button):
		_light(_lit_button, false)
	_lit_button = null


## A plank or a yellow button looks as under the mouse while selected; a plank also straightens.
func _light(button: Button, on: bool) -> void:
	if on:
		button.add_theme_stylebox_override(&"normal", button.get_meta(&"cursor_hover"))
		button.add_theme_stylebox_override(&"hover", button.get_meta(&"cursor_hover"))
		button.add_theme_color_override(&"font_color", button.get_meta(&"cursor_hover_font"))
	else:
		button.remove_theme_stylebox_override(&"normal")
		button.remove_theme_color_override(&"font_color")
		button.add_theme_stylebox_override(&"hover", button.get_theme_stylebox(&"normal"))
	if button.has_method(&"reach"):
		button.call(&"reach", on)


## The first row shown from `i` on, going `by`; -1 if none is.
func _shown_from(i: int, by: int) -> int:
	for k in _rows.size():
		var j := posmod(i + k * by, _rows.size())
		if _rows[j].shown():
			return j
	return -1


func _chosen(row: Row) -> int:
	for i in row.cells.size():
		if row.cells[i].button_pressed:
			return i
	return -1


## The cell of `row` whose middle is nearest `x`.
func _nearest(row: Row, x: float) -> int:
	var best := 0
	for i in row.cells.size():
		if absf(_global_rect(row.cells[i]).get_center().x - x) < absf(_global_rect(row.cells[best]).get_center().x - x):
			best = i
	return best


## The mouse on `button` selects its row, and the cell if it is one. The selected row first,
## as a button can belong to several (the chord grid's Sevenths).
func _pointed(button: BaseButton) -> void:
	var order := range(_rows.size())
	if _at >= 0:
		order.erase(_at)
		order.push_front(_at)
	for i: int in order:
		var row: Row = _rows[i]
		if not button in _buttons_of(row) or not row.shown():
			continue
		if row.kind == Kind.CELLS:
			row.cell = row.cells.find(button)
		_select(i)
		return


## Every button of `row`: its cells, and the buttons in its parts (a value's ◀ ▶).
func _buttons_of(row: Row) -> Array:
	var out: Array = []
	out.append_array(row.cells)
	for part in row.parts:
		if part is BaseButton and not part in out:
			out.append(part)
		for found in part.find_children("*", "BaseButton", true, false):
			if not found in out:
				out.append(found)
	return out


## Once per button: the mouse on it selects it, and Godot's own hover look goes, so only
## the cursor shows what is selected. The hover look is kept for a plank or yellow button.
func _hook(button: BaseButton) -> void:
	if button.has_meta(&"cursor_hover"):
		return
	button.set_meta(&"cursor_hover", button.get_theme_stylebox(&"hover"))
	button.set_meta(&"cursor_hover_font", button.get_theme_color(&"font_hover_color"))
	button.add_theme_stylebox_override(&"hover", button.get_theme_stylebox(&"normal"))
	button.add_theme_stylebox_override(&"hover_pressed", button.get_theme_stylebox(&"pressed"))
	button.add_theme_color_override(&"font_hover_color", button.get_theme_color(&"font_color"))
	button.add_theme_color_override(&"font_hover_pressed_color", button.get_theme_color(&"font_pressed_color"))
	button.mouse_entered.connect(_pointed.bind(button))


func _rect_of(parts: Array) -> Rect2:
	var rect := _global_rect(parts[0])
	for part: Control in parts.slice(1):
		if part.is_visible_in_tree():
			rect = rect.merge(_global_rect(part))
	return rect


## Where `c` is on the screen, without the grow of a plank reached for.
func _global_rect(c: Control) -> Rect2:
	return Rect2(c.global_position, c.size)
