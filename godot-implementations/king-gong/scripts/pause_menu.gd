extends ColorRect
## The pause menu, over a song frozen by Esc: continue, restart, practice mode, the tempo, the
## beat tick, backing (the part you don't play, when there is one), the labels, the chord sign (with chords), a bug report, or back to the main menu. It runs
## while the game is paused. It shows the game's settings as they are when it opens and only
## reports changes; the game keeps them. Worked with the mouse, or through the menu cursor
## (menu_cursor.gd).
##
## Report bug… swaps the rows for a box to write what happened in; Save hands the words to the
## game, which writes the report (run_record.gd), and a line under the title says where it went.

signal continue_pressed
signal restart_pressed
signal menu_pressed
signal practice_toggled(on: bool)
signal tempo_changed(bpm: float)
signal tick_toggled(on: bool)
signal backing_toggled(on: bool)
signal labels_toggled(on: bool)
signal hint_chosen(hint: ChordLog.Hint)
signal report_written(text: String)
signal reporting_changed   # the report box opened or closed: the menu cursor works the other rows

const MenuCursor := preload("res://scripts/menu_cursor.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const TEMPO_MIN := 40
const TEMPO_MAX := 120
const TEMPO_STEP := 5

var _bpm := 60

@onready var _rows: Control = $Center/Panel/Rows
@onready var _note: Label = $Center/Panel/Rows/Note
@onready var _report: Control = $Center/Panel/Report
@onready var _text: TextEdit = $Center/Panel/Report/Text
@onready var _practice: Button = $Center/Panel/Rows/Practice/Toggle
@onready var _tick: Button = $Center/Panel/Rows/Tick/Toggle
@onready var _backing: Button = $Center/Panel/Rows/Backing/Toggle
@onready var _labels: Button = $Center/Panel/Rows/Labels/Toggle
@onready var _tempo: Label = $Center/Panel/Rows/Tempo/Value
@onready var _signs: Array[Button] = [$Center/Panel/Rows/Sign/Name, $Center/Panel/Rows/Sign/Bass]   # by ChordLog.Hint


func _ready() -> void:
	$Center/Panel/Rows/Continue.pressed.connect(func() -> void: continue_pressed.emit())
	$Center/Panel/Rows/Restart.pressed.connect(func() -> void: restart_pressed.emit())
	$Center/Panel/Rows/Menu.pressed.connect(func() -> void: menu_pressed.emit())
	$Center/Panel/Rows/Report.pressed.connect(open_report)
	$Center/Panel/Report/Buttons/Cancel.pressed.connect(close_report)
	$Center/Panel/Report/Buttons/Save.pressed.connect(_save_report)
	$Center/Panel/Rows/Tempo/Down.pressed.connect(step_tempo.bind(-1))
	$Center/Panel/Rows/Tempo/Up.pressed.connect(step_tempo.bind(1))
	_toggle(_practice, practice_toggled)
	_toggle(_tick, tick_toggled)
	_toggle(_backing, backing_toggled)
	_toggle(_labels, labels_toggled)
	for hint: ChordLog.Hint in [ChordLog.Hint.NAME, ChordLog.Hint.BASS_CLEF]:
		_signs[hint].toggled.connect(func(on: bool) -> void:
			if on:
				hint_chosen.emit(hint))


## Shows the menu with the game's settings. Practice mode is only for playing a song, the
## chord sign only for a level with chords.
func open(play_mode: bool, practice: bool, bpm: float, tick: bool, backing_shown: bool, backing: bool, labels: bool, chords: bool, hint: ChordLog.Hint) -> void:
	$Center/Panel/Rows/Practice.visible = play_mode
	$Center/Panel/Rows/Backing.visible = backing_shown
	$Center/Panel/Rows/Sign.visible = chords
	for k in _signs.size():
		_signs[k].set_pressed_no_signal(k == hint)
	for setting: Array in [[_practice, practice], [_tick, tick], [_backing, backing], [_labels, labels]]:
		var button: Button = setting[0]
		button.set_pressed_no_signal(setting[1])
		button.text = "on" if setting[1] else "off"
	_bpm = roundi(bpm)
	_tempo.text = "%d BPM" % _bpm
	if not visible:   # opened afresh, not shown again with a setting changed
		_note.hide()
		_close_report_quietly()
	show()


func close() -> void:
	_close_report_quietly()
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
		MenuCursor.press(_backing, [rows.get_node("Backing")]),
		MenuCursor.press(_labels, [rows.get_node("Labels")]),
		MenuCursor.choice(_signs, [rows.get_node("Sign")]),
		MenuCursor.press(rows.get_node("Report")),
		MenuCursor.press(rows.get_node("Menu")),
	]


## The report box's rows for the menu cursor: Cancel and Save, on Save. The words are typed.
func report_rows() -> Array:
	var buttons: Node = $Center/Panel/Report/Buttons
	return [MenuCursor.cells([buttons.get_node("Cancel"), buttons.get_node("Save")], 1)]


## The report box is open in place of the rows.
func reporting() -> bool:
	return _report.visible


## Report bug…: the box to write what happened in, empty, the keys going to it.
func open_report() -> void:
	_note.hide()
	_text.text = ""
	_rows.hide()
	_report.show()
	_text.grab_focus()
	reporting_changed.emit()


## Back to the rows, writing nothing.
func close_report() -> void:
	if _close_report_quietly():
		reporting_changed.emit()


## A line of `text` under the title, until the menu closes or a report box opens.
func show_note(text: String) -> void:
	_note.text = text
	_note.show()


func _save_report() -> void:
	var text := _text.text.strip_edges()
	close_report()
	report_written.emit(text)


## The report box closed, if it was open; true if it was.
func _close_report_quietly() -> bool:
	if not _report.visible:
		return false
	_text.release_focus()
	_report.hide()
	_rows.show()
	return true


func _can_step_tempo(by: int) -> bool:
	return clampi(_bpm + by * TEMPO_STEP, TEMPO_MIN, TEMPO_MAX) != _bpm


func _toggle(button: Button, changed: Signal) -> void:
	button.toggled.connect(func(on: bool) -> void:
		button.text = "on" if on else "off"
		changed.emit(on))
