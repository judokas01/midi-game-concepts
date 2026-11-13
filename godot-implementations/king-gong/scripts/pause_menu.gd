extends ColorRect
## The pause menu, over a song frozen by Esc: continue, restart, practice mode, the tempo, the
## beat tick, the labels, the chord sign (with chords), or back to the main menu. It runs
## while the game is paused. It shows the game's settings as they are when it opens and only
## reports changes; the game keeps them. Worked with the mouse, or through the menu cursor
## (menu_cursor.gd).

signal continue_pressed
signal restart_pressed
signal menu_pressed
signal practice_toggled(on: bool)
signal tempo_changed(bpm: float)
signal tick_toggled(on: bool)
signal labels_toggled(on: bool)
signal hint_chosen(hint: ChordLog.Hint)

const MenuCursor := preload("res://scripts/menu_cursor.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const TEMPO_MIN := 40
const TEMPO_MAX := 120
const TEMPO_STEP := 5

var _bpm := 60

@onready var _practice: Button = $Center/Panel/Rows/Practice/Toggle
@onready var _tick: Button = $Center/Panel/Rows/Tick/Toggle
@onready var _labels: Button = $Center/Panel/Rows/Labels/Toggle
@onready var _tempo: Label = $Center/Panel/Rows/Tempo/Value
@onready var _signs: Array[Button] = [$Center/Panel/Rows/Sign/Name, $Center/Panel/Rows/Sign/Bass]   # by ChordLog.Hint


func _ready() -> void:
	$Center/Panel/Rows/Continue.pressed.connect(func() -> void: continue_pressed.emit())
	$Center/Panel/Rows/Restart.pressed.connect(func() -> void: restart_pressed.emit())
	$Center/Panel/Rows/Menu.pressed.connect(func() -> void: menu_pressed.emit())
	$Center/Panel/Rows/Tempo/Down.pressed.connect(step_tempo.bind(-1))
	$Center/Panel/Rows/Tempo/Up.pressed.connect(step_tempo.bind(1))
	_toggle(_practice, practice_toggled)
	_toggle(_tick, tick_toggled)
	_toggle(_labels, labels_toggled)
	for hint: ChordLog.Hint in [ChordLog.Hint.NAME, ChordLog.Hint.BASS_CLEF]:
		_signs[hint].toggled.connect(func(on: bool) -> void:
			if on:
				hint_chosen.emit(hint))


## Shows the menu with the game's settings. Practice mode is only for playing a song, the
## chord sign only for a level with chords.
func open(play_mode: bool, practice: bool, bpm: float, tick: bool, labels: bool, chords: bool, hint: ChordLog.Hint) -> void:
	$Center/Panel/Rows/Practice.visible = play_mode
	$Center/Panel/Rows/Sign.visible = chords
	for k in _signs.size():
		_signs[k].set_pressed_no_signal(k == hint)
	for setting: Array in [[_practice, practice], [_tick, tick], [_labels, labels]]:
		var button: Button = setting[0]
		button.set_pressed_no_signal(setting[1])
		button.text = "on" if setting[1] else "off"
	_bpm = roundi(bpm)
	_tempo.text = "%d BPM" % _bpm
	show()


func close() -> void:
	hide()


## The tempo `by` steps up (down if negative), within TEMPO_MIN to TEMPO_MAX.
func step_tempo(by: int) -> void:
	var bpm := clampi(_bpm + by * TEMPO_STEP, TEMPO_MIN, TEMPO_MAX)
	if bpm == _bpm:
		return
	_bpm = bpm
	_tempo.text = "%d BPM" % _bpm
	tempo_changed.emit(float(_bpm))


## The rows for the menu cursor, top to bottom. Practice mode's and the chord sign's are
## skipped while hidden.
func cursor_rows() -> Array:
	var rows: Node = $Center/Panel/Rows
	return [
		MenuCursor.press(rows.get_node("Continue")),
		MenuCursor.press(rows.get_node("Restart")),
		MenuCursor.press(_practice, [rows.get_node("Practice")]),
		MenuCursor.value(step_tempo, _can_step_tempo, [rows.get_node("Tempo")]),
		MenuCursor.press(_tick, [rows.get_node("Tick")]),
		MenuCursor.press(_labels, [rows.get_node("Labels")]),
		MenuCursor.choice(_signs, [rows.get_node("Sign")]),
		MenuCursor.press(rows.get_node("Menu")),
	]


func _can_step_tempo(by: int) -> bool:
	return clampi(_bpm + by * TEMPO_STEP, TEMPO_MIN, TEMPO_MAX) != _bpm


func _toggle(button: Button, changed: Signal) -> void:
	button.toggled.connect(func(on: bool) -> void:
		button.text = "on" if on else "off"
		changed.emit(on))
