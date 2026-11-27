extends ColorRect
## The song library, over a song board (A or Enter on its Song row, or Browse…): two filters,
## a category (All songs, or one with songs in it) and a difficulty (Any, or exactly one to
## five stars), and under them the songs that match both, easiest first, then by name, each
## with its stars; beside a list longer than the page, a scroll bar (scroll_bar.gd) shows
## where in it the view is. Through the menu cursor (menu_cursor.gd) the rows are Category,
## Difficulty, the list, and Back: E and F change a filter, and on the list the category; C
## and D move along the list and out of it at its ends; A picks the song; B and Esc close it,
## as Back does. With the mouse, pointing selects, a click picks, the wheel scrolls.
##
## Once the selection has rested on a song for PREVIEW_AFTER_MS, its first PREVIEW_MS play on
## the piano (its own SongPlayer, on the Preview bus): tune and chords at PREVIEW_BPM, the
## last FADE_MS fading out. A move, another filter, a pick or closing stops it at once.
## After another filter none plays, not even on the song the list kept, until the selection
## moves to a song; on opening, the song it opens on plays as after a move.

signal picked(song: int, filter: Dictionary)

const Song := preload("res://scripts/song.gd")
const MenuCursor := preload("res://scripts/menu_cursor.gd")
const SongPlayer := preload("res://scripts/song_player.gd")
const ListBar := preload("res://scripts/scroll_bar.gd")
const LINES := 10        # songs in view at once
const LINE_SIZE := Vector2(460, 34)
const STARS_W := 96      # the stars' column, so the names line up
const STARS_SIZE := 17
const FONT_SIZE := 15
const PREVIEW_BPM := 80.0
const PREVIEW_AFTER_MS := 600.0
const PREVIEW_MS := 10000.0
const FADE_MS := 1000.0
const LEAD_MS := 100.0     # the preview's first beat is heard this long after it starts, on time
const RESTORE_MS := 60.0   # after a stop in the fade, the bus stays down this long
const BUS := &"Preview"

var at := 0              # the song selected, its place in the list
var top := 0             # the place of the song on the first line

var _categories: Array = []   # "" (All songs), then the categories with songs
var _levels: Array = []       # 0 (Any), then the difficulties some song has
var _category := 0            # the filters chosen, their places in those
var _level := 0
var _only: Array = []         # songs to list in place of the filters', for a check
var _songs: Array = []        # the list: the songs that match
var _current := -1            # the song picked on the board: the list opens on it if it has it
var _lines: Array[Button] = []
var _rest_from := 0.0         # ms, when the selection last moved
var _previewed := true        # this rest has had its preview
var _preview := -1            # the song previewing, -1 for none
var _preview_from := 0.0      # ms, when its first beat is heard
var _preview_ms := 0.0        # how long it plays: PREVIEW_MS, or the song's length if shorter
var _player: SongPlayer
var _bus := -1
var _restore_at := 0.0        # ms, when the bus goes back to 0 dB after a stop in the fade; 0 for none

@onready var _category_row: Control = $Center/Board/Box/Filters/Category
@onready var _level_row: Control = $Center/Board/Box/Filters/Difficulty
@onready var _list: VBoxContainer = $Center/Board/Box/Songs/List
@onready var _empty: Label = $Center/Board/Box/Songs/Empty
@onready var _above: Label = $Center/Board/Box/Above/Mark
@onready var _below: Label = $Center/Board/Box/Below/Mark
@onready var _bar: ListBar = $Center/Board/Box/Songs/Bar
@onready var _back: Button = $Center/Board/Box/Foot/Back


func _ready() -> void:
	for k in LINES:
		_lines.append(_line(k))
	$Center/Board/Box/Songs.custom_minimum_size = Vector2(LINE_SIZE.x, LINES * LINE_SIZE.y + (LINES - 1) * _list.get_theme_constant(&"separation"))
	_list.gui_input.connect(_on_list_input)
	_category_row.get_node("Previous").pressed.connect(step_category.bind(-1))
	_category_row.get_node("Next").pressed.connect(step_category.bind(1))
	_level_row.get_node("Previous").pressed.connect(step_level.bind(-1))
	_level_row.get_node("Next").pressed.connect(step_level.bind(1))
	_back.pressed.connect(close)
	_bus = AudioServer.get_bus_index(BUS)
	if _bus < 0:   # the project's bus layout has none: one of its own, into Master
		AudioServer.add_bus()
		_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_bus, BUS)
		AudioServer.set_bus_send(_bus, &"Master")
	_player = SongPlayer.new()
	_player.name = "Preview"
	_player.bus = BUS
	add_child(_player)
	visibility_changed.connect(func() -> void:
		if not visible:
			_stop_preview())


## Shows the library with `filter` ({category, difficulty}, "" and 0 for all), on `song` if
## it matches. `only` lists those songs instead, for a check.
func open(song: int, filter: Dictionary, only: Array = []) -> void:
	_categories = [""] + Song.categories_used()
	_levels = [0] + Song.levels_used()
	_category = maxi(_categories.find(filter.get("category", "")), 0)
	_level = maxi(_levels.find(filter.get("difficulty", 0)), 0)
	_only = only
	_current = song
	_filter(true)
	show()


func close() -> void:
	hide()


## The filters chosen, as open() takes them.
func filter() -> Dictionary:
	return {category = _categories[_category], difficulty = _levels[_level]}


## The song selected, its number in Song.library().
func selected_song() -> int:
	return _songs[at]


## Line `k` from the top, a Button.
func line(k: int) -> Button:
	return _lines[k]


## The song previewing, or -1.
func previewing() -> int:
	return _preview


## Category, Difficulty, the list, Back, for the menu cursor; it starts on the list.
func cursor_rows() -> Array:
	return [
		MenuCursor.value(step_category, func(_by: int) -> bool: return _categories.size() > 1, [_category_row, _category_row.get_parent().get_node("CategoryCaption")]),
		MenuCursor.value(step_level, func(_by: int) -> bool: return _levels.size() > 1, [_level_row, _level_row.get_parent().get_node("DifficultyCaption")]),
		MenuCursor.list(_lines, move, func(_by: int) -> bool: return _songs.size() > 1,
			func() -> Button: return _lines[at - top], _point,
			step_category, func(_by: int) -> bool: return _categories.size() > 1, [_list]),
		MenuCursor.press(_back),
	]


## Where the cursor starts: the list, or Category when nothing matches.
func cursor_start() -> int:
	return 2 if not _songs.is_empty() else 0


## The selection `by` songs along the list; false, without moving, past either end.
func move(by: int) -> bool:
	if at + by < 0 or at + by >= _songs.size():
		return false
	at += by
	_keep_in_view()
	_show()
	_moved()
	return true


## The category `by` on, round from the last to All songs.
func step_category(by: int) -> void:
	_category = posmod(_category + by, _categories.size())
	_filter(false)


## The difficulty `by` on, round from the hardest to Any.
func step_level(by: int) -> void:
	_level = posmod(_level + by, _levels.size())
	_filter(false)


## The list for the filters chosen, on the song picked if it is in it, else on its first.
## With `preview` false, that song is not previewed: only a move starts one again.
func _filter(preview: bool) -> void:
	var f := filter()
	_songs = _only if not _only.is_empty() else Song.matching(f.category, f.difficulty)
	at = maxi(_songs.find(_current), 0)
	top = 0
	_keep_in_view()
	_show()
	_moved(preview)


## The view moves so the selection is never on its first or last line, unless the list
## starts or ends there.
func _keep_in_view() -> void:
	top = clampi(top, at - (LINES - 2), at - 1)
	top = clampi(top, 0, maxi(_songs.size() - LINES, 0))


func _show() -> void:
	var library := Song.library()
	var f := filter()
	_category_row.get_node("Value").text = Song.ALL_SONGS if f.category == "" else f.category
	_category_row.get_node("Count").text = "%d song%s" % [_songs.size(), "" if _songs.size() == 1 else "s"]
	var level: Label = _level_row.get_node("Value")
	level.text = "Any" if f.difficulty == 0 else Song.stars(f.difficulty)
	if f.difficulty == 0:   # stars in gold, as on the list
		level.remove_theme_color_override(&"font_color")
		level.add_theme_font_size_override(&"font_size", FONT_SIZE)
	else:
		level.add_theme_color_override(&"font_color", MenuCursor.MARK)
		level.add_theme_font_size_override(&"font_size", STARS_SIZE)
	_list.visible = not _songs.is_empty()
	_empty.visible = _songs.is_empty()
	for k in LINES:
		var b := _lines[k]
		b.visible = top + k < _songs.size()
		if b.visible:
			var song: Dictionary = library[_songs[top + k]]
			b.get_node("Row/Stars").text = Song.stars(song.get("difficulty", 0))
			b.get_node("Row/Title").text = song.name
	_above.visible = top > 0
	_below.visible = top + LINES < _songs.size()
	_bar.show_view(top, LINES, _songs.size())


## A line of the list: the stars, then the name. A click picks its song.
func _line(k: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = LINE_SIZE
	b.focus_mode = Control.FOCUS_NONE
	_list.add_child(b)
	var row := HBoxContainer.new()
	row.name = "Row"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 12.0
	row.offset_right = -12.0
	b.add_child(row)
	for part: String in ["Stars", "Title"]:
		var label := Label.new()
		label.name = part
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_FILL
		label.add_theme_font_size_override(&"font_size", FONT_SIZE)
		label.add_theme_color_override(&"font_color", b.get_theme_color(&"font_color"))
		row.add_child(label)
	var stars: Label = row.get_node("Stars")
	stars.custom_minimum_size.x = STARS_W
	stars.add_theme_font_size_override(&"font_size", STARS_SIZE)
	stars.add_theme_color_override(&"font_color", MenuCursor.MARK)   # gold, as the cursor's
	var title: Label = row.get_node("Title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.clip_text = true
	b.pressed.connect(func() -> void: _pick(top + k))
	return b


func _point(button: Button) -> void:
	var to := top + _lines.find(button)
	if to != at:
		at = to
		_show()
		_moved()


func _pick(i: int) -> void:
	if i >= _songs.size():   # a line left from a list that has emptied
		return
	picked.emit(_songs[i], filter())
	hide()


## The wheel scrolls a line at a time; the selection stays in view.
func _on_list_input(event: InputEvent) -> void:
	var wheel := event as InputEventMouseButton
	if not wheel or not wheel.pressed or not wheel.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		return
	top = clampi(top + (1 if wheel.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1), 0, maxi(_songs.size() - LINES, 0))
	var to := clampi(at, top, mini(top + LINES, _songs.size()) - 1)
	if to != at:
		at = to
		_moved()
	_show()
	_list.accept_event()


func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec() / 1000.0
	if _restore_at > 0.0 and now >= _restore_at:   # the stopped voices are gone: the bus back up
		_restore_at = 0.0
		AudioServer.set_bus_volume_db(_bus, 0.0)
	if not visible:
		return
	if not _previewed and now - _rest_from >= PREVIEW_AFTER_MS:
		_start_preview(now)
	elif _preview >= 0 and _preview_ms >= PREVIEW_MS:   # a shorter song plays whole
		var left := _preview_from + PREVIEW_MS - now
		if left <= 0.0:
			_stop_preview()
		elif left < FADE_MS:
			AudioServer.set_bus_volume_db(_bus, linear_to_db(left / FADE_MS))


func _start_preview(now: float) -> void:
	_previewed = true
	if _songs.is_empty():
		return
	_preview = selected_song()
	var notes := Song.parse(_preview, Song.Clef.TREBLE, true)
	var beat_ms := 60000.0 / PREVIEW_BPM
	_preview_ms = (notes[-1].beat + notes[-1].beats - notes[0].beat) * beat_ms
	_preview_from = now + LEAD_MS
	_restore_at = 0.0
	AudioServer.set_bus_volume_db(_bus, 0.0)
	_player.load_song(notes, true, true, Song.bar_lines(_preview, notes))
	_player.play(beat_ms, _preview_from)


## Stopped voices still sound for a mix block as they fade, so a bus turned down in the fade
## goes back to 0 dB only RESTORE_MS later, or that block would come back loud as a click.
func _stop_preview() -> void:
	_preview = -1
	if _player:
		_player.stop()
	if _bus >= 0 and AudioServer.get_bus_volume_db(_bus) < 0.0 and _restore_at == 0.0:
		_restore_at = Time.get_ticks_usec() / 1000.0 + RESTORE_MS


## The selection moved: any preview stops, and the next waits for it to rest; with
## `preview` false there is no next until it moves again.
func _moved(preview := true) -> void:
	_stop_preview()
	_previewed = not preview
	_rest_from = Time.get_ticks_usec() / 1000.0
