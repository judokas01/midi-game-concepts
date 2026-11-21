extends SceneTree
## Dev check, not part of the game: the sign on a log, for every chord the drill offers. In the
## bass clef it shows all the chord's notes, sevenths too, each on the staff or on one ledger
## line next to it, inside the board, with its sharp or flat, and the computer key under the
## board. A triad's sign keeps the size it always had; so does every sign that shows a name.
## Its name, and the name of every chord the songs use, fits inside the board's face, centred,
## drawn at its own font size (not scaled): full size if it fits, smaller if it doesn't, and only
## on its own log. Prints `sign: ok`, or what is wrong. Run from the project folder:
##   godot --headless --path . --script res://scripts/dev_sign_check.gd

const Song := preload("res://scripts/song.gd")
const Drill := preload("res://scripts/drill.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const LOG := preload("res://scenes/chord_log.tscn")
const FRAME := 3.0        # the board's dark edge, in pixels
const HEAD_HALF := 5.0    # half a note head's height, tilted, rounded up
const BOARD_H := 74       # the sign's board as it was for triads and names
const FACE := 45.0        # half the board's light face, across
const NAME_SIZE := 40     # the name's font size, as the scene has it
const FITS := 88.0        # a name this wide, or less, at NAME_SIZE keeps it

var _failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var drill := Drill.all_chords()
	for chord: String in drill:
		await _check(chord)
	for chord: String in _song_chords():
		if chord not in drill:
			var chord_log := _log(chord)
			await _check_name(chord_log, chord)
			chord_log.free()
	await _check_own_size()
	print("sign: FAILED" if _failed else "sign: ok")
	quit(1 if _failed else 0)


func _check(name: String) -> void:
	var chord := Song.parse_chord(name)
	var chord_log := _log(name)
	var board: Sprite2D = chord_log.get_node("Top/Sign/Board")
	var key: Label = chord_log.get_node("Top/Sign/Key")
	var staff: Node2D = chord_log.get_node("Top/Sign/Staff")

	_expect(board.texture.get_height() == BOARD_H, name, "the name's board is %d high, not %d" % [board.texture.get_height(), BOARD_H])
	await _check_name(chord_log, name)

	chord_log.show_hint(ChordLog.Hint.BASS_CLEF, "a")
	var half := board.texture.get_height() / 2.0
	if chord.midi.size() == 3:
		_expect(board.texture.get_height() == BOARD_H, name, "a triad's board is %d high, not %d" % [board.texture.get_height(), BOARD_H])
	_expect(key.position.y >= half, name, "the key label at %.1f is on the board, which reaches %.1f" % [key.position.y, half])
	var heads := staff.get_children().filter(func(c: Node) -> bool: return c.name.begins_with("Head") and c.visible)
	_expect(heads.size() == chord.midi.size(), name, "%d heads shown for %d notes" % [heads.size(), chord.midi.size()])
	var marks := staff.get_children().filter(func(c: Node) -> bool: return c.name.begins_with("Accidental") and c.visible and c.text != "")
	_expect(marks.size() == chord.accidentals.count(1) + chord.accidentals.count(-1), name,
		"%d sharps and flats shown for %s" % [marks.size(), chord.tones])
	for k in mini(heads.size(), chord.steps.size()):
		var y: float = (heads[k] as Sprite2D).position.y
		_expect(is_equal_approx(y, (4 - chord.steps[k]) * ChordLog.SIGN_STEP), name, "%s is drawn at %.1f" % [chord.tones[k], y])
		_expect(absf(y) + HEAD_HALF <= half - FRAME, name, "%s at %.1f sticks out of the board, %.1f high" % [chord.tones[k], y, 2.0 * half])
	var lowest: int = chord.steps.min()
	var highest: int = chord.steps.max()
	_expect(lowest >= -2 and highest <= 10, name, "%s reaches more than a ledger line off the staff: steps %d to %d" % [chord.tones, lowest, highest])
	_expect(_shown(staff, "LedgerBelow") == (lowest == -2), name, "the ledger line below shows: %s, the lowest note at step %d" % [_shown(staff, "LedgerBelow"), lowest])
	_expect(_shown(staff, "LedgerAbove") == (highest == 10), name, "the ledger line above shows: %s, the highest note at step %d" % [_shown(staff, "LedgerAbove"), highest])
	chord_log.free()


## A log for chord `name`, set up on C4, its sign showing the name.
func _log(name: String) -> ChordLog:
	var note := Song.Note.new()
	note.name = "C4"
	note.midi = 60
	note.chord = Song.parse_chord(name)
	var chord_log: ChordLog = LOG.instantiate()
	root.add_child(chord_log)
	chord_log.setup(note)
	chord_log.show_hint(ChordLog.Hint.NAME, "a")
	return chord_log


## Where the name is drawn a frame after setup(), once the label's deferred layout has run:
## inside the board's face, centred on it, at its own font size, full size if it fits there.
func _check_name(chord_log: ChordLog, name: String) -> void:
	await process_frame
	var board: Sprite2D = chord_log.get_node("Top/Sign/Board")
	var label: Label = chord_log.get_node("Top/Sign/Name")
	var settings := label.label_settings
	var full := settings.font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, NAME_SIZE).x
	var wide := settings.font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, settings.font_size).x * label.scale.x
	var centre := label.position + label.pivot_offset + label.scale * (label.size / 2.0 - label.pivot_offset)
	var left := centre.x - wide / 2.0 - board.position.x
	var right := centre.x + wide / 2.0 - board.position.x
	_expect(left >= -FACE and right <= FACE, name, "the name is drawn from x %.1f to %.1f, past the board's face (%.0f to %.0f)" % [left, right, -FACE, FACE])
	_expect(centre.distance_to(board.position) <= 1.0, name, "the name's centre is at (%.1f, %.1f), not the board's (%.1f, %.1f)" % [centre.x, centre.y, board.position.x, board.position.y])
	_expect(label.scale == Vector2.ONE, name, "the name is scaled by %.2f, not drawn at its own size" % label.scale.x)
	if full <= FITS:
		_expect(settings.font_size == NAME_SIZE, name, "the name fits at %d px (%.0f wide) but is drawn at %d" % [NAME_SIZE, full, settings.font_size])


## A long name's smaller size is its own log's: a short name on a log set up before it keeps
## its full size.
func _check_own_size() -> void:
	var short := _log("C")
	var long := _log("Ebmaj7")
	await process_frame
	var size: int = (short.get_node("Top/Sign/Name") as Label).label_settings.font_size
	_expect(size == NAME_SIZE, "C", "drawn at %d px once Ebmaj7's log is set up, not %d" % [size, NAME_SIZE])
	short.free()
	long.free()


## The chords the songs use, by name, each once.
func _song_chords() -> Array:
	var out := []
	for song: Dictionary in Song.library():
		for entry: Array in song.notes:
			if entry.size() > 2 and entry[2] not in out:
				out.append(entry[2])
	return out


func _shown(staff: Node2D, line: String) -> bool:
	var node := staff.get_node_or_null(line) as CanvasItem
	return node != null and node.visible


func _expect(ok: bool, chord: String, what: String) -> void:
	if not ok:
		_failed = true
		printerr("sign %s: %s" % [chord, what])
