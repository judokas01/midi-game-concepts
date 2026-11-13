extends Control
## The main menu: wooden planks hanging from the canopy (Play song, Learn song, Chord drill,
## Exit game, and Tutorial and Campaign still to come), and the boards they open, where a song
## or the drill's chords are chosen before Start. Play song and Learn song share one board. It
## shows the choices and reports them; the game keeps them. Worked with the mouse, or through
## the menu cursor (menu_cursor.gd), which hud.gd hands the rows of the page shown.

enum Page { MAIN, PLAY, LEARN, DRILL }

signal page_opened(page: Page)   # a board, which plays in its own mode
signal page_shown                # any page, the main one too
signal start_pressed
signal song_chosen(song: int)
signal style_chosen(clef: Song.Clef, chords: bool, by_itself: bool)
signal hint_chosen(hint: ChordLog.Hint)
signal practice_toggled(on: bool)
signal piano_toggled(on: bool)
signal drill_changed(count: int, beats: int)
signal chords_requested   # More options: the chord grid
signal kind_toggled(quality: String, on: bool)

const Song := preload("res://scripts/song.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const Drill := preload("res://scripts/drill.gd")
const MenuCursor := preload("res://scripts/menu_cursor.gd")
const TITLES := {Page.PLAY: "Play song", Page.LEARN: "Learn song"}
const KINDS := {"Major": "", "Minor": "m", "Dom7": "7", "Maj7": "maj7", "Min7": "m7", "Dim": "dim", "Aug": "aug"}   # button: quality
const PICKED_LETTERS := 24   # the chords picked are named up to this many letters, so the line keeps its width

var page := Page.MAIN
var count: int = Drill.COUNT   # chords in a drill round
var beats: int = Drill.BEATS   # beats from one drill chord to the next
var _last_board := Page.PLAY    # the main page opens with its plank selected

@onready var _main: Control = $Main
@onready var _songs: Control = $Songs
@onready var _drill: Control = $Drill
@onready var _song_rows: GridContainer = $Songs/Board/Rows/Grid
@onready var _drill_rows: GridContainer = $Drill/Board/Rows/Grid
@onready var _song: OptionButton = _song_rows.get_node("Song/Pick")
@onready var _practice: Button = _song_rows.get_node("Practice/Toggle")
@onready var _hints: Array[Button] = [_song_rows.get_node("Hint/Toggle"), _drill_rows.get_node("Hint/Toggle")]
@onready var _beats: Label = _drill_rows.get_node("Every/Value")
@onready var _picked: Label = _drill_rows.get_node("Chords/Picked/Summary")
@onready var _kinds: Control = _drill_rows.get_node("Chords/Kinds")


func _ready() -> void:
	$Main/Column/Play.pressed.connect(open.bind(Page.PLAY))
	$Main/Column/Learn.pressed.connect(open.bind(Page.LEARN))
	$Main/Column/Drill.pressed.connect(open.bind(Page.DRILL))
	$Main/Column/Exit.pressed.connect(func() -> void: get_tree().quit())
	for board: Control in [_songs, _drill]:
		board.get_node("Board/Rows/Foot/Back").pressed.connect(back)
		board.get_node("Board/Rows/Foot/Start").pressed.connect(func() -> void: start_pressed.emit())
	_ready_songs()
	_ready_drill()
	for hint in _hints:
		_toggle(hint, func(on: bool) -> void:
			for other in _hints:
				_set_toggle(other, on)   # the same on both boards
			piano_toggled.emit(on))
	open(Page.MAIN)


func _ready_songs() -> void:
	for song: Dictionary in Song.library():
		_song.add_item(song.name)
	_song.item_selected.connect(func(i: int) -> void: song_chosen.emit(i))
	_song_rows.get_node("Song/Previous").pressed.connect(_next_song.bind(-1))
	_song_rows.get_node("Song/Next").pressed.connect(_next_song.bind(1))
	_on_chosen(_song_rows.get_node("Part/Treble"), func() -> void: style_chosen.emit(Song.Clef.TREBLE, false, false))
	_on_chosen(_song_rows.get_node("Part/Bass"), func() -> void: style_chosen.emit(Song.Clef.BASS, false, false))
	_on_chosen(_song_rows.get_node("Part/Chords"), func() -> void: style_chosen.emit(Song.Clef.TREBLE, true, false))
	_on_chosen(_song_rows.get_node("Part/ChordsOnly"), func() -> void: style_chosen.emit(Song.Clef.TREBLE, true, true))
	_on_chosen(_song_rows.get_node("Sign/Name"), func() -> void: hint_chosen.emit(ChordLog.Hint.NAME))
	_on_chosen(_song_rows.get_node("Sign/Bass"), func() -> void: hint_chosen.emit(ChordLog.Hint.BASS_CLEF))
	_toggle(_practice, func(on: bool) -> void: practice_toggled.emit(on))


func _ready_drill() -> void:
	for button: Button in _drill_rows.get_node("Round").get_children().filter(func(c: Node) -> bool: return c is Button):
		var n := int(button.text)
		_on_chosen(button, func() -> void:
			count = n
			drill_changed.emit(count, beats))
	_drill_rows.get_node("Every/Down").pressed.connect(_step_beats.bind(-1))
	_drill_rows.get_node("Every/Up").pressed.connect(_step_beats.bind(1))
	_drill_rows.get_node("Chords/Picked/More").pressed.connect(func() -> void: chords_requested.emit())
	for button: String in KINDS:
		var quality: String = KINDS[button]
		_kinds.get_node(button).toggled.connect(func(on: bool) -> void: kind_toggled.emit(quality, on))
	_show_beats()


## Shows the menu on page `p`. Opening a board tells the game which mode it plays, so the level
## behind it is laid out for that.
func open(p: Page) -> void:
	page = p
	if p != Page.MAIN:
		_last_board = p
	_main.visible = p == Page.MAIN
	_songs.visible = p == Page.PLAY or p == Page.LEARN
	_drill.visible = p == Page.DRILL
	if _songs.visible:
		$Songs/Board/Rows/Title.text = TITLES[p]
		_show_row("Practice", p == Page.PLAY)
		_show_row("Hint", p == Page.LEARN)
	show()
	if p != Page.MAIN:
		page_opened.emit(p)
	page_shown.emit()


## From a board back to the main page. False on the main page, where there is no back.
func back() -> bool:
	if page == Page.MAIN:
		return false
	open(Page.MAIN)
	return true


## The rows of the page shown, top to bottom, for the menu cursor. Tutorial and Campaign,
## still to come, are left out.
func cursor_rows() -> Array:
	match page:
		Page.MAIN:
			return ["Play", "Learn", "Drill", "Exit"].map(func(plank: String) -> MenuCursor.Row:
				return MenuCursor.press(_main.get_node("Column/" + plank)))
		Page.DRILL:
			var kinds: Array = _kinds.get_children().filter(func(c: Node) -> bool: return c is Button)
			var rounds: Array = _drill_rows.get_node("Round").get_children().filter(func(c: Node) -> bool: return c is Button)
			return [
				MenuCursor.cells(kinds, 0, [_kinds]),   # not its caption, which sits lower, by the line of chords too
				MenuCursor.press(_drill_rows.get_node("Chords/Picked/More")),
				MenuCursor.choice(rounds, _parts(_drill_rows, "Round")),
				MenuCursor.value(_step_beats, _can_step_beats, _parts(_drill_rows, "Every")),
				MenuCursor.press(_drill_rows.get_node("Hint/Toggle"), _parts(_drill_rows, "Hint")),
				_foot(_drill),
			]
	var parts := ["Treble", "Bass", "Chords", "ChordsOnly"].map(func(b: String) -> Button: return _song_rows.get_node("Part/" + b))
	return [
		MenuCursor.value(_next_song, _can_step_song, _parts(_song_rows, "Song")),
		MenuCursor.choice(parts, _parts(_song_rows, "Part")),
		MenuCursor.choice([_song_rows.get_node("Sign/Name"), _song_rows.get_node("Sign/Bass")], _parts(_song_rows, "Sign")),
		MenuCursor.press(_practice, _parts(_song_rows, "Practice")),
		MenuCursor.press(_song_rows.get_node("Hint/Toggle"), _parts(_song_rows, "Hint")),
		_foot(_songs),
	]


## Where the cursor starts: on the main page the plank of the board last opened, on a board
## Start.
func cursor_start() -> int:
	if page == Page.MAIN:
		return [Page.PLAY, Page.LEARN, Page.DRILL].find(_last_board)
	return -1


## The board the sign sits outside; none on the main page, where it sits beside the plank.
func cursor_anchor() -> Control:
	match page:
		Page.MAIN:
			return null
		Page.DRILL:
			return _drill.get_node("Board")
	return _songs.get_node("Board")


## A board row's parts: its control and the caption beside it, so its frame takes in both.
func _parts(rows: GridContainer, row: String) -> Array:
	return [rows.get_node(row), rows.get_node(row + "Caption")]


## Back | Start, on Start.
func _foot(board: Control) -> MenuCursor.Row:
	return MenuCursor.cells([board.get_node("Board/Rows/Foot/Back"), board.get_node("Board/Rows/Foot/Start")], 1)


## The Chord sign row is for a part with chords only.
func show_style(chords: bool) -> void:
	_show_row("Sign", chords)


func set_practice(on: bool) -> void:
	_set_toggle(_practice, on)


## The drill's `chords`, by name, under the kind buttons: "C D E F G A B", as many names as fit
## in PICKED_LETTERS, then "and 9 more". The buttons of the `kinds` (qualities) picked are lit.
func show_picked(chords: Array, kinds: Array) -> void:
	for button: String in KINDS:
		_kinds.get_node(button).set_pressed_no_signal(KINDS[button] in kinds)
	var names := []
	for chord: String in chords:
		if " ".join(names + [chord]).length() > PICKED_LETTERS:
			break
		names.append(chord)
	var text := " ".join(names)
	if names.size() < chords.size():
		text += " and %d more" % (chords.size() - names.size())
	_picked.text = text


func _show_row(row: String, on: bool) -> void:
	_song_rows.get_node(row + "Caption").visible = on
	_song_rows.get_node(row).visible = on


func _step_beats(by: int) -> void:
	var to := clampi(beats + by, Drill.BEATS_MIN, Drill.BEATS_MAX)
	if to == beats:
		return
	beats = to
	_show_beats()
	drill_changed.emit(count, beats)


func _can_step_beats(by: int) -> bool:
	return clampi(beats + by, Drill.BEATS_MIN, Drill.BEATS_MAX) != beats


func _can_step_song(_by: int) -> bool:
	return _song.item_count > 1   # round from the end to the start


func _show_beats() -> void:
	_beats.text = "%d beat%s" % [beats, "" if beats == 1 else "s"]


## The song `by` places down the list (up if negative), round from the end to the start.
func _next_song(by: int) -> void:
	_song.select(posmod(_song.selected + by, _song.item_count))
	song_chosen.emit(_song.selected)


## `picked` runs when `button`, one of a group, becomes the chosen one.
func _on_chosen(button: Button, picked: Callable) -> void:
	button.toggled.connect(func(on: bool) -> void:
		if on:
			picked.call())


## An on/off button: it says which it is, and `changed` hears it.
func _toggle(button: Button, changed: Callable) -> void:
	button.toggled.connect(func(on: bool) -> void:
		button.text = "on" if on else "off"
		changed.call(on))


func _set_toggle(button: Button, on: bool) -> void:
	button.set_pressed_no_signal(on)
	button.text = "on" if on else "off"
