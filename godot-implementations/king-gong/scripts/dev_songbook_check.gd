extends SceneTree
## Dev check, not part of the game: every song in the song book (scripts/songbook/), as the
## game will read it. Each has a name no other song has, its file's category, a difficulty
## of 1 to 5, a key the game knows, notes it can read ("C4", "F#4", "Bb3", "r" a rest, a
## trailing "*" a banana) of lengths it lays out, every note between A3 and F5 so the staff
## moves none, triad chords from the first bar on, whole bars after its pickup, and two
## bananas at least. As warnings only: few downbeats that are notes of their chord, many
## signs for the key, very short or long songs.
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://scripts/dev_songbook_check.gd
##   (add -- --file=children to check one file)
## Prints "songbook: <n> songs, <w> warnings" and "songbook: ok", or an error for each rule broken.

const Song := preload("res://scripts/song.gd")
const LENGTHS := [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0]
const LOWEST := 57    # A3
const HIGHEST := 77   # F5
const TRIADS := ["", "m", "dim", "aug"]

var _failed := false
var _warnings := 0
var _note := RegEx.new()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_note.compile("^([A-G])(#|b)?([2-6])\\*?$")
	var only := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--file="):
			only = arg.trim_prefix("--file=")
	var names := {}
	for song: Dictionary in Song.SONGS:
		names[song.name] = "song.gd"
	var count := 0
	for part: GDScript in Song.SONG_BOOK:
		var file := part.resource_path.get_file().get_basename()
		for song: Dictionary in part.SONGS:
			var name: String = song.get("name", "")
			if names.has(name):
				_fail(file, name, "the name is taken already, in %s" % names[name])
			names[name] = file
			if only == "" or only == file:
				_check(file, part.CATEGORY, song)
				count += 1
	print("songbook: %d songs, %d warnings" % [count, _warnings])
	print("songbook: ok" if not _failed else "songbook: failed")
	quit()


func _check(file: String, category: String, song: Dictionary) -> void:
	var name: String = song.get("name", "")
	if name == "":
		_fail(file, "?", "no name")
	for error in Song.song_errors(song, false):
		_fail(file, name, error)
	if song.get("category") != category:
		_fail(file, name, "its category is %s, not this file's %s" % [song.get("category"), category])
	var key: String = song.get("key", "C")
	var tonic := key.trim_suffix("m")
	if tonic.is_empty() or not Song.LETTER_SEMI.has(tonic[0]) or not Song.ACCIDENTALS.has(tonic.substr(1)):
		_fail(file, name, "the key %s is none the game knows" % key)
		return
	var entries: Array = song.get("notes", [])
	if entries.is_empty() or entries[0][0] == "r":
		_fail(file, name, "no notes, or a rest first")
		return
	var meter := float(song.get("meter", 4))
	var pickup := float(song.get("pickup", 0))
	if pickup >= meter:
		_fail(file, name, "a pickup of %s beats is a bar or more" % pickup)
	var written: Array[int] = []
	var beat := 0.0
	var first_chord := -1.0
	var bananas := 0
	var chords := []   # [beat, pitch classes]
	var downbeats := []   # [beat, pitch class]
	for entry: Array in entries:
		if entry.size() < 2 or entry.size() > 3 or not entry[0] is String:
			_fail(file, name, "an entry %s is not [note, beats] or [note, beats, chord]" % [entry])
			return
		var raw: String = entry[0]
		var length := float(entry[1])
		if not LENGTHS.any(func(l: float) -> bool: return is_equal_approx(l, length)):
			_fail(file, name, "%s lasts %s beats, none of %s" % [raw, length, LENGTHS])
		if raw != "r":
			var m := _note.search(raw)
			if not m:
				_fail(file, name, "%s is not a note" % raw)
				return
			var midi: int = 12 * (int(m.get_string(3)) + 1) + Song.LETTER_SEMI[m.get_string(1)] + Song.ACCIDENTALS[m.get_string(2)]
			if midi < LOWEST or midi > HIGHEST:
				_fail(file, name, "%s is outside A3 to F5" % raw)
			written.append(midi)
			bananas += 1 if raw.ends_with("*") else 0
			if beat >= pickup - 0.001 and is_equal_approx(fposmod(beat - pickup, meter), 0.0):
				downbeats.append([beat, midi % 12])
		elif entry.size() > 2:
			_fail(file, name, "a rest carries a chord")
		if entry.size() > 2:
			var chord: String = entry[2]
			var root := chord.left(2) if chord.length() > 1 and chord[1] in "#b" else chord.left(1)
			if root.is_empty() or not Song.LETTER_SEMI.has(root[0]) or not chord.substr(root.length()) in TRIADS:
				_fail(file, name, "the chord %s is not a triad the game knows" % chord)
				return
			if first_chord < 0.0:
				first_chord = beat
			var classes := Array(Song.parse_chord(chord).midi).map(func(x: int) -> int: return x % 12)
			chords.append([beat, classes])
		beat += length
	var bars := (beat - pickup) / meter
	if not is_equal_approx(fposmod(beat - pickup, meter), 0.0) and not (pickup > 0.0 and is_equal_approx(fposmod(beat, meter), 0.0)):
		_fail(file, name, "%s beats are not whole bars of %s after a pickup of %s" % [beat, meter, pickup])
	if chords.is_empty():
		_fail(file, name, "no chords")
	elif first_chord > pickup + 0.001:
		_fail(file, name, "no chord until beat %s" % first_chord)
	if bananas < 2:
		_fail(file, name, "%d banana%s, not two at least" % [bananas, "" if bananas == 1 else "s"])
	# as the game reads it: the staff may move the whole song by octaves, never a note alone
	var parsed := Song.parse_entries(entries, Song.Clef.TREBLE, true, Song.fifths(key))
	var shift := parsed[0].midi - written[0]
	for k in parsed.size():
		if parsed[k].midi - written[k] != shift:
			_fail(file, name, "the staff moves %s by an octave on its own" % parsed[k].name)
			break
	# warnings: a hint that a chord, the key or the length may be off
	if not downbeats.is_empty() and not chords.is_empty():
		var fits := 0
		for d: Array in downbeats:
			var under: Array = chords[0][1]
			for c: Array in chords:
				if c[0] <= d[0] + 0.001:
					under = c[1]
			fits += 1 if d[1] in under else 0
		if fits < downbeats.size() * 0.5:
			_warn(file, name, "only %d of %d downbeats are notes of their chord" % [fits, downbeats.size()])
	var signs := parsed.filter(func(n: Song.Note) -> bool: return n.sign != Song.Sign.NONE).size()
	if signs > parsed.size() * 0.3:
		_warn(file, name, "%d of %d notes carry a sign: is the key %s right?" % [signs, parsed.size(), key])
	if bars < 4 or bars > 40:
		_warn(file, name, "%s bars long" % bars)


func _fail(file: String, name: String, what: String) -> void:
	_failed = true
	push_error("songbook %s / %s: %s" % [file, name, what])


func _warn(file: String, name: String, what: String) -> void:
	_warnings += 1
	print("songbook warning %s / %s: %s" % [file, name, what])
