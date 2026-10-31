extends ColorRect
## The chord drill's chord menu: which chords a round deals, on a grid of the kinds of chord,
## by difficulty, against the twelve roots, and how many chords a round has. Worked with the
## mouse, or from the MIDI keyboard: a note from C4 to B4 picks the button on its key in the
## marked row, a note below C4 marks the row above, one above B4 the row below.

signal closed(chords: Array, count: int)

const Drill := preload("res://scripts/drill.gd")
const Song := preload("res://scripts/song.gd")
const LOW := 60                    # C4: the key over the grid's first column, C
const COUNT_KEYS := [0, 2, 4, 5]   # C4 D4 E4 F4 pick Drill.COUNTS
const GROUP_W := 104               # the difficulties' column
const KIND_W := 52                 # the kinds of chord's
const CHORD_W := 64
const MARK := Color("f2c230")      # the marked row's frame: the colour of the next note on the little keyboard

var count: int = Drill.COUNT
var _chords := {}                  # chord name -> its button, in the grid's order
var _rows: Array = []              # top to bottom, what the twelve keys pick in each row: a button or null
var _frames: Array[StyleBoxFlat] = []   # each row's frame, lit on the marked one
var _mark := 0

@onready var _grid: VBoxContainer = $Center/Box/Grid


func _ready() -> void:
	_add_keys()
	for group: Array in Drill.GROUPS:
		_add_group(group[0], group[1])
	_add_counts()
	var done := _button("Done · %s" % Song.note_name(LOW), 0)
	done.pressed.connect(close)
	var keyed := []
	keyed.resize(12)
	keyed.fill(done)   # any key, on the Done row
	_add_row(_gap(GROUP_W), [_gap(KIND_W), done], keyed)


## The chords picked, by name, in the grid's order.
func picked() -> Array:
	return _chords.keys().filter(func(name: String) -> bool: return _chords[name].button_pressed)


func open() -> void:
	_mark_row(0)
	show()


func close() -> void:
	hide()
	closed.emit(picked(), count)


## A MIDI note: below C4 marks the row above, above B4 the row below, round from one end to
## the other, and from C4 to B4 picks the button on that key in the marked row, as a click would.
func play(m: int) -> void:
	if m < LOW or m >= LOW + 12:
		_mark_row(posmod(_mark + (-1 if m < LOW else 1), _rows.size()))
		return
	var button: Button = _rows[_mark][m - LOW]
	if button == null:
		return
	if not button.toggle_mode:
		button.pressed.emit()
	elif button.button_group:
		button.button_pressed = true
	else:
		button.button_pressed = not button.button_pressed


## Over the columns, the key that picks in each.
func _add_keys() -> void:
	var cells: Array = [_gap(KIND_W)]
	for i in 12:
		var key := Label.new()
		key.text = Song.note_name(LOW + i)
		key.custom_minimum_size.x = CHORD_W
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key.add_theme_font_size_override("font_size", 12)
		key.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
		cells.append(key)
	_grid.add_child(_line(_gap(GROUP_W), [_row(cells, false)]))


## A difficulty: a row for each of its `qualities`, the twelve roots across.
func _add_group(difficulty: String, qualities: Array) -> void:
	var in_group: Array[Button] = []
	var rows := []
	for quality: String in qualities:
		var keyed := []
		var in_row: Array[Button] = []
		var cells := []
		for root: String in Drill.ROOTS[quality]:
			var chord: Button = _chord(root + quality) if root != "" else null
			keyed.append(chord)
			if chord:
				in_row.append(chord)
			cells.append(chord if chord else _gap(CHORD_W))
		cells.push_front(_all(quality, KIND_W, in_row) if qualities.size() > 1 else _gap(KIND_W))
		rows.append(_row(cells))
		_rows.append(keyed)
		in_group.append_array(in_row)
	_grid.add_child(_line(_all(difficulty, GROUP_W, in_group), rows))


## How many chords a round has, on C4 D4 E4 F4.
func _add_counts() -> void:
	var counts := ButtonGroup.new()
	var keyed := []
	keyed.resize(12)
	var cells: Array = [_gap(KIND_W)]
	for i in Drill.COUNTS.size():
		var n: int = Drill.COUNTS[i]
		var b := _button("%d chords · %s" % [n, Song.note_name(LOW + COUNT_KEYS[i])], 0)
		b.toggle_mode = true
		b.button_group = counts
		b.button_pressed = n == count
		b.toggled.connect(func(on: bool) -> void:
			if on:
				count = n)
		keyed[COUNT_KEYS[i]] = b
		cells.append(b)
	var caption := Label.new()
	caption.text = "In a round"
	caption.custom_minimum_size.x = GROUP_W
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_add_row(caption, cells, keyed)


func _add_row(left: Control, cells: Array, keyed: Array) -> void:
	_grid.add_child(_line(left, [_row(cells)]))
	_rows.append(keyed)


func _mark_row(i: int) -> void:
	_mark = i
	for k in _frames.size():
		_frames[k].border_color = Color(MARK, 1.0 if k == i else 0.0)
		_frames[k].bg_color = Color(MARK, 0.08 if k == i else 0.0)


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


## `cells` side by side in a frame; with `markable`, the frame is lit while the row is marked.
func _row(cells: Array, markable := true) -> PanelContainer:
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(MARK, 0.0)
	frame.border_color = Color(MARK, 0.0)
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(4)
	frame.set_content_margin_all(3)
	if markable:
		_frames.append(frame)
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
