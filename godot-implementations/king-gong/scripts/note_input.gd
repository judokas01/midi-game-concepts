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
# the white keys on the home row, the black ones in the row above, as on a piano
const KEYS: Array[Key] = [KEY_A, KEY_W, KEY_S, KEY_E, KEY_D, KEY_F, KEY_T, KEY_G, KEY_Y, KEY_H, KEY_U, KEY_J, KEY_K]
const KEY_MIDI: Array[int] = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72]   # C4 to C5, before octave_shift
const KEY_LABELS := "AWSEDFTGYHUJK"
# chords on C to B: Z X C V B N M on the white keys, with shift on the black key above
const CHORD_KEYS: Array[int] = [KEY_Z, KEY_Z | KEY_MASK_SHIFT, KEY_X, KEY_X | KEY_MASK_SHIFT, KEY_C, KEY_V,
	KEY_V | KEY_MASK_SHIFT, KEY_B, KEY_B | KEY_MASK_SHIFT, KEY_N, KEY_N | KEY_MASK_SHIFT, KEY_M]
const CHORD_LABELS := ["Z", "Shift+Z", "X", "Shift+X", "C", "V", "Shift+V", "B", "Shift+B", "N", "Shift+N", "M"]
const RESCAN_S := 2.0

var source := "keyboard"
var octave_shift := 0      # octaves the keys are moved by, to where the song is: -1 in the bass clef
var _chord_keys := {}      # chord key, with shift -> the Song.Chord it plays; empty without chords
var _sounding := {}        # chord key held down -> the chord it played, let go of on release even if the keys changed since
var _rescan := RESCAN_S


## The computer key that plays `midi`, while the keyboard is the live input.
func key_for(midi: int) -> String:
	var i := KEY_MIDI.find(midi - 12 * octave_shift)
	return KEY_LABELS[i] if i >= 0 and source == "keyboard" else ""


## What the keys play, as [keys, notes]: ["A S D F G H J K", "C4 D4 E4 F4 G4 A4 B4 C5"], and
## with `black` the black keys after it, ["W E T Y U", "C#4 D#4 F#4 G#4 A#4"], with `flats`
## "Db4 Eb4 Gb4 Ab4 Bb4".
func key_notes(black: bool, flats: bool) -> Array:
	var out := []
	for blacks: bool in ([false, true] if black else [false]):
		var letters: Array[String] = []
		var names: Array[String] = []
		for i in KEYS.size():
			var m := KEY_MIDI[i] + 12 * octave_shift
			if Song.is_black(m) == blacks:
				letters.append(KEY_LABELS[i])
				names.append(Song.note_name(m, flats))
		out.append([" ".join(letters), " ".join(names)])
	return out


## One key for each chord of the song: the key of its root. Two chords on the same root, C and
## Cm, would share a key; the first one gets it.
func set_chords(chords: Array) -> void:
	_chord_keys.clear()
	for chord: Song.Chord in chords:
		var key := CHORD_KEYS[chord.midi[0] % 12]
		if not _chord_keys.has(key):
			_chord_keys[key] = chord


## The computer key that plays `chord`, while the keyboard is the live input.
func chord_key_for(chord: Song.Chord) -> String:
	var root := chord.midi[0] % 12
	var own: Song.Chord = _chord_keys.get(CHORD_KEYS[root])
	return CHORD_LABELS[root] if source == "keyboard" and own != null and own.name == chord.name else ""


## What the chord keys play, "Z = C  V = F  Shift+N = Bb"; empty without chords.
func chord_key_notes() -> String:
	var pairs: Array[String] = []
	for root in CHORD_KEYS.size():
		if _chord_keys.has(CHORD_KEYS[root]):
			pairs.append("%s = %s" % [CHORD_LABELS[root], _chord_keys[CHORD_KEYS[root]].name])
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
	var chord: Song.Chord = _chord_keys.get(key.get_keycode_with_modifiers())
	if not key.pressed:
		if idx >= 0:
			note_off.emit(KEY_MIDI[idx] + 12 * octave_shift, t)
		elif _sounding.has(key.keycode):
			for m in _sounding[key.keycode].midi:
				note_off.emit(m, t)
			_sounding.erase(key.keycode)
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
		_sounding[key.keycode] = chord
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
