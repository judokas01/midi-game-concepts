extends SceneTree
## Dev check, not part of the game: the sign on a log, for every chord the drill offers. In the
## bass clef it shows all the chord's notes, sevenths too, each on the staff or on one ledger
## line next to it, inside the board, with its sharp or flat, and the computer key under the
## board. A triad's sign keeps the size it always had; so does every sign that shows a name.
## Prints `sign: ok`, or what is wrong. Run from the project folder:
##   godot --headless --path . --script res://scripts/dev_sign_check.gd

const Song := preload("res://scripts/song.gd")
const Drill := preload("res://scripts/drill.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const LOG := preload("res://scenes/chord_log.tscn")
const FRAME := 3.0        # the board's dark edge, in pixels
const HEAD_HALF := 5.0    # half a note head's height, tilted, rounded up
const BOARD_H := 74       # the sign's board as it was for triads and names

var _failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for chord: String in Drill.all_chords():
		_check(chord)
	print("sign: FAILED" if _failed else "sign: ok")
	quit(1 if _failed else 0)


func _check(name: String) -> void:
	var chord := Song.parse_chord(name)
	var note := Song.Note.new()
	note.name = "C4"
	note.midi = 60
	note.chord = chord
	var chord_log: ChordLog = LOG.instantiate()
	root.add_child(chord_log)
	chord_log.setup(note)
	var board: Sprite2D = chord_log.get_node("Top/Sign/Board")
	var key: Label = chord_log.get_node("Top/Sign/Key")
	var staff: Node2D = chord_log.get_node("Top/Sign/Staff")

	chord_log.show_hint(ChordLog.Hint.NAME, "a")
	_expect(board.texture.get_height() == BOARD_H, name, "the name's board is %d high, not %d" % [board.texture.get_height(), BOARD_H])

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


func _shown(staff: Node2D, line: String) -> bool:
	var node := staff.get_node_or_null(line) as CanvasItem
	return node != null and node.visible


func _expect(ok: bool, chord: String, what: String) -> void:
	if not ok:
		_failed = true
		printerr("sign %s: %s" % [chord, what])
