extends Node
## MIDI notes and the computer-keyboard fallback, stamped with the time they arrived. On the
## keyboard a chord is one key, which plays its three notes.
##
## Godot's input events carry no timestamp, so the stamp is taken when the event is
## dispatched, which happens once per frame. That is ~16 ms of resolution at 60 fps,
## small against the ±0.35-beat window.

signal note_on(midi: int, t_ms: float)
signal note_off(midi: int, t_ms: float)
signal source_changed(source: String)
signal start_requested
signal restart_requested
signal menu_requested

const Song := preload("res://scripts/song.gd")
const KEYS: Array[Key] = [KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K]
const KEY_MIDI: Array[int] = [60, 62, 64, 65, 67, 69, 71, 72]   # C4 to C5, before octave_shift
const KEY_LABELS := "ASDFGHJK"
const CHORD_KEYS: Array[Key] = [KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M]   # chords on C D E F G A B
const CHORD_LABELS := "ZXCVBNM"
const RESCAN_S := 2.0

var source := "keyboard"
var octave_shift := 0      # octaves the keys are moved by, to where the song is: -1 in the bass clef
var _chord_keys := {}      # chord key -> the Song.Chord it plays; empty without chords
var _rescan := RESCAN_S


## The computer key that plays `midi`, while the keyboard is the live input.
func key_for(midi: int) -> String:
	var i := KEY_MIDI.find(midi - 12 * octave_shift)
	return KEY_LABELS[i] if i >= 0 and source == "keyboard" else ""


## What the keys play, "C4 D4 E4 F4 G4 A4 B4 C5".
func key_notes() -> String:
	return " ".join(KEY_MIDI.map(func(m: int) -> String: return Song.note_name(m + 12 * octave_shift)))


## One key for each chord of the song: the key under its root's letter. Two chords on the same
## root, C and Cm, would share a key; the first one gets it.
func set_chords(chords: Array) -> void:
	_chord_keys.clear()
	for chord: Song.Chord in chords:
		var key := CHORD_KEYS[Song.LETTERS.find(chord.name[0])]
		if not _chord_keys.has(key):
			_chord_keys[key] = chord


## The computer key that plays `chord`, while the keyboard is the live input.
func chord_key_for(chord: Song.Chord) -> String:
	var i := Song.LETTERS.find(chord.name[0])
	var own: Song.Chord = _chord_keys.get(CHORD_KEYS[i])
	return CHORD_LABELS[i] if source == "keyboard" and own != null and own.name == chord.name else ""


## What the chord keys play, "Z = C  V = F  B = G"; empty without chords.
func chord_key_notes() -> String:
	var pairs: Array[String] = []
	for i in CHORD_KEYS.size():
		if _chord_keys.has(CHORD_KEYS[i]):
			pairs.append("%s = %s" % [CHORD_LABELS[i], _chord_keys[CHORD_KEYS[i]].name])
	return "  ".join(pairs)


func _ready() -> void:
	OS.open_midi_inputs()   # REQUIRED — without it no InputEventMIDI ever arrives
	print("MIDI inputs: ", OS.get_connected_midi_inputs())


func _process(delta: float) -> void:
	# Godot does not notice devices plugged in after start-up; while none is open, look again.
	if not OS.get_connected_midi_inputs().is_empty():
		return
	_rescan -= delta
	if _rescan > 0.0:
		return
	_rescan = RESCAN_S
	OS.close_midi_inputs()
	OS.open_midi_inputs()
	var found := OS.get_connected_midi_inputs()
	if not found.is_empty():
		print("MIDI inputs: ", found)


func _input(event: InputEvent) -> void:
	var t := Time.get_ticks_usec() / 1000.0
	if event is InputEventMIDI:
		var midi := event as InputEventMIDI
		if midi.message == MIDI_MESSAGE_NOTE_ON and midi.velocity > 0:
			_set_source("MIDI")
			note_on.emit(midi.pitch, t)
		elif midi.message == MIDI_MESSAGE_NOTE_OFF or midi.message == MIDI_MESSAGE_NOTE_ON:
			note_off.emit(midi.pitch, t)   # note-on with velocity 0 IS a note-off
		return

	var key := event as InputEventKey
	if key == null:
		return
	var idx := KEYS.find(key.keycode)
	var chord: Song.Chord = _chord_keys.get(key.keycode)
	if not key.pressed:
		if idx >= 0:
			note_off.emit(KEY_MIDI[idx] + 12 * octave_shift, t)
		elif chord != null:
			for m in chord.midi:
				note_off.emit(m, t)
		return
	if key.echo or key.ctrl_pressed or key.meta_pressed or key.alt_pressed:
		return
	if key.keycode == KEY_SPACE:
		start_requested.emit()
	elif key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		restart_requested.emit()
	elif key.keycode == KEY_ESCAPE:
		menu_requested.emit()
	elif idx >= 0:
		_set_source("keyboard")
		note_on.emit(KEY_MIDI[idx] + 12 * octave_shift, t)
	elif chord != null:
		_set_source("keyboard")
		for m in chord.midi:
			note_on.emit(m, t)
	else:
		return
	get_viewport().set_input_as_handled()


func _set_source(src: String) -> void:
	if source == src:
		return
	source = src
	source_changed.emit(src)
