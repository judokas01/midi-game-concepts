extends ColorRect
## The chord drill's chord grid (More options on the drill board): which chords a round deals,
## on a grid of the kinds of chord, by difficulty, against the twelve roots. Worked with the
## mouse, or through the menu cursor (menu_cursor.gd): a row for each kind of chord, its cells
## the difficulty's button, the kind's where the difficulty has several, and its chords.

signal closed(chords: Array)

const Drill := preload("res://scripts/drill.gd")
const MenuCursor := preload("res://scripts/menu_cursor.gd")
const GROUP_W := 104               # the difficulties' column
const KIND_W := 52                 # the kinds of chord's
const CHORD_W := 64
const WHITE_ROOTS := [0, 2, 4, 5, 7, 9, 11]   # C D E F G A B, by their place in Drill.ROOTS

var _chords := {}                  # chord name -> its button, in the grid's order
var _lines: Array = []             # each kind's row, top to bottom: [its buttons left to right, its frame, the cell of its C]
var _done: Button

@onready var _grid: VBoxContainer = $Center/Board/Box/Grid


func _ready() -> void:
	for group: Array in Drill.GROUPS:
		_add_group(group[0], group[1])
	_done = _button("Done", 0)
	_done.pressed.connect(close)
	_grid.add_child(_line(_gap(GROUP_W), [_row([_gap(KIND_W), _done])]))


## The chords picked, by name, in the grid's order.
func picked() -> Array:
	return _chords.keys().filter(func(name: String) -> bool: return _chords[name].button_pressed)


## Picks the kind of chord `quality` ("" major, "m", "7" ...) on the white-key roots, or unpicks
## every chord of that kind, unless that would leave none picked.
func set_kind(quality: String, on: bool) -> void:
	var of_kind := _chords.keys().filter(func(name: String) -> bool: return Drill.quality_of(name) == quality)
	if on:
		for i: int in WHITE_ROOTS:
			var root: String = Drill.ROOTS[quality][i]
			if root != "":
				_chords[root + quality].set_pressed_no_signal(true)
	elif not picked().all(func(name: String) -> bool: return name in of_kind):
		for name: String in of_kind:
			_chords[name].set_pressed_no_signal(false)


## The kinds of chord with any chord picked, as qualities, in the grid's order.
func kinds() -> Array:
	var out := []
	for name: String in picked():
		var quality := Drill.quality_of(name)
		if not quality in out:
			out.append(quality)
	return out


func open() -> void:
	show()


## The rows for the menu cursor: each kind's, on the chord on C at first, then Done.
func cursor_rows() -> Array:
	var rows: Array = _lines.map(func(line: Array) -> MenuCursor.Row: return MenuCursor.cells(line[0], line[2], [line[1]]))
	rows.append(MenuCursor.press(_done))
	return rows


func close() -> void:
	hide()
	closed.emit(picked())


## A difficulty: a row for each of its `qualities`, the twelve roots across.
func _add_group(difficulty: String, qualities: Array) -> void:
	var in_group: Array[Button] = []
	var rows := []
	var lines := []
	for quality: String in qualities:
		var in_row: Array[Button] = []
		var cells := []
		for root: String in Drill.ROOTS[quality]:
			var chord: Button = _chord(root + quality) if root != "" else null
			if chord:
				in_row.append(chord)
			cells.append(chord if chord else _gap(CHORD_W))
		var own: Array[Button] = []   # the kind's button, where the difficulty has several kinds
		if qualities.size() > 1:
			own.append(_all(quality, KIND_W, in_row))
		cells.push_front(own[0] if own else _gap(KIND_W))
		var row := _row(cells)
		rows.append(row)
		lines.append([own + in_row, row, own.size() + 1])   # the chord on C comes first in the row
		in_group.append_array(in_row)
	var all := _all(difficulty, GROUP_W, in_group)
	for line: Array in lines:
		line[0].push_front(all)
	_lines.append_array(lines)
	_grid.add_child(_line(all, rows))


## A chord to pick. One at least stays picked.
func _chord(name: String) -> Button:
	var b := _button(name, CHORD_W)
	b.toggle_mode = true
	b.button_pressed = name in Drill.START_CHORDS
	b.toggled.connect(func(on: bool) -> void:
		if not on and picked().is_empty():
			b.set_pressed_no_signal(true))
	_chords[name] = b
	return b


## A kind's or a difficulty's name: picks all its `chords`, or none if they all are already,
## unless they are all that is picked.
func _all(text: String, width: int, chords: Array[Button]) -> Button:
	var b := _button(text, width)
	b.pressed.connect(func() -> void:
		var on := not chords.all(func(c: Button) -> bool: return c.button_pressed)
		if not on and picked().size() == chords.size():
			return
		for c in chords:
			c.set_pressed_no_signal(on))
	return b


func _button(text: String, width: int) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, 28)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 14)
	return b


func _gap(width: int) -> Control:
	var gap := Control.new()
	gap.custom_minimum_size.x = width
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return gap


## `left`, beside `rows` one under the other.
func _line(left: Control, rows: Array) -> HBoxContainer:
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 2)
	for row: Control in rows:
		column.add_child(row)
	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_constant_override("separation", 4)
	line.add_child(left)
	line.add_child(column)
	return line


## `cells` side by side, a little apart from the next row: the menu cursor frames it.
func _row(cells: Array) -> PanelContainer:
	var frame := StyleBoxEmpty.new()
	frame.set_content_margin_all(3)
	var side_by_side := HBoxContainer.new()
	side_by_side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side_by_side.add_theme_constant_override("separation", 4)
	for cell: Control in cells:
		side_by_side.add_child(cell)
	var row := PanelContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_stylebox_override("panel", frame)
	row.add_child(side_by_side)
	return row
