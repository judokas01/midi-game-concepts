extends RefCounted
## Reads MusicXML scores, as MuseScore exports them (.mxl, or uncompressed .musicxml or
## .xml), into songs like those in song.gd: the melody, its chord symbols and the bar lines,
## moved into C.
##
## The melody is the first part's top staff, voice 1, and its highest note where it has
## several. The chords are the chord symbols of whichever part has the most. Repeats and
## first and second endings are played out; D.C., D.S. and codas are not. Rhythms are
## rounded to sixteenths, a rest shorter than an eighth joins the note before it, and
## anything before the first note is dropped. Chord symbols become triads: sevenths and
## other extensions are left out, and sus and power chords are played as major.

const GRID := 0.25            # beats: a sixteenth
const SHORTEST_REST := 0.5    # beats; a shorter rest is added to the note before it
const BANANA_EVERY := 24      # notes; then the next one of a beat or more gets a banana
const EXTENSIONS: Array[String] = ["mxl", "musicxml", "xml"]
const LETTERS := "CDEFGAB"
const LETTER_SEMI: Array[int] = [0, 2, 4, 5, 7, 9, 11]
const NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


## One XML element: just enough of a DOM to read a score.
class El:
	var name: String
	var attrs := {}
	var text := ""
	var children: Array[El] = []

	func child(n: String) -> El:
		for c in children:
			if c.name == n:
				return c
		return null

	func all(n: String) -> Array[El]:
		var out: Array[El] = []
		for c in children:
			if c.name == n:
				out.append(c)
		return out

	## The first element called `n` anywhere below this one.
	func find(n: String) -> El:
		for c in children:
			var hit := c if c.name == n else c.find(n)
			if hit:
				return hit
		return null

	func text_of(n: String, default := "") -> String:
		var c := child(n)
		return c.text.strip_edges() if c else default


## Every score in `dir`, by file name, as {name, notes, bars}. A file that can't be read is
## left out with a warning.
static func load_dir(dir: String) -> Array:
	var songs := []
	if not DirAccess.dir_exists_absolute(dir):
		return songs
	var files := Array(DirAccess.get_files_at(dir))
	files.sort()
	for file: String in files:
		if not file.get_extension().to_lower() in EXTENSIONS:
			continue
		var song := load_file(dir.path_join(file))
		if song.is_empty():
			push_warning("Could not read a melody from " + file)
		else:
			songs.append(song)
	return songs


## The song in one score file; empty if there is none to read.
static func load_file(path: String) -> Dictionary:
	var compressed := path.get_extension().to_lower() == "mxl"
	var bytes := _unzip(path) if compressed else FileAccess.get_file_as_bytes(path)
	var score := _parse_xml(bytes).child("score-partwise") if not bytes.is_empty() else null
	if score == null or score.all("part").is_empty():
		return {}
	var parts := score.all("part")
	var harmony_part := parts[0]
	for part in parts:
		if _count(part, "harmony") > _count(harmony_part, "harmony"):
			harmony_part = part
	var key := {divisions = 1.0, bar = 4.0}
	var measures := parts[0].all("measure").map(func(m: El) -> Dictionary: return _read_measure(m, key))
	var chord_key := {divisions = 1.0, bar = 4.0}
	var chord_measures := harmony_part.all("measure").map(func(m: El) -> Dictionary: return _read_measure(m, chord_key))

	# lay the measures out in the order they are played
	var notes := []
	var chords := []
	var bars := []
	var t := 0.0
	for i in _play_order(measures):
		bars.append(t)
		for n: Dictionary in measures[i].notes:
			var last: Dictionary = notes[-1] if not notes.is_empty() else {}
			if n.tie_stop and not last.is_empty() and last.midi == n.midi and absf(last.t + last.dur - t - n.t) < 0.01:
				last.dur += n.dur
			else:
				notes.append(n.merged({t = t + n.t}, true))
		if i < chord_measures.size():
			for c: Dictionary in chord_measures[i].chords:
				chords.append(c.merged({t = t + c.t}, true))
		t += measures[i].length
	if notes.is_empty():
		return {}

	var title := score.find("work-title")
	var name: String = title.text.strip_edges() if title and title.text.strip_edges() != "" \
		else score.text_of("movement-title", path.get_file().get_basename())
	return _to_song(name, notes, chords, bars, key.get("fifths", 0))


## The beats of a <duration> (or <backup>, <forward>) element.
static func _beats(e: El, key: Dictionary) -> float:
	return float(e.text_of("duration", "0")) / key.divisions


## A measure's melody notes and chord symbols, with their times in beats from its start,
## its length, and its repeat signs. `key` carries divisions, time and key signature from
## one measure to the next.
static func _read_measure(m: El, key: Dictionary) -> Dictionary:
	var out := {length = 0.0, notes = [], chords = [], forward = false, backward = 0, ending = [], ending_ends = false}
	var cursor := 0.0
	var onset := 0.0
	var reach := 0.0
	for e in m.children:
		match e.name:
			"attributes":
				if e.child("divisions"):
					key.divisions = float(e.text_of("divisions"))
				var time := e.child("time")
				if time:
					key.bar = float(time.text_of("beats", "4")) * 4.0 / float(time.text_of("beat-type", "4"))
				var fifths := e.find("fifths")
				if fifths and not key.has("fifths"):
					key.fifths = int(fifths.text)
			"backup":
				cursor -= _beats(e, key)
			"forward":
				cursor += _beats(e, key)
			"harmony":
				var root := e.child("root")
				if root and LETTERS.contains(root.text_of("root-step", "?")) and e.text_of("kind") != "none":   # "none" is N.C.
					out.chords.append({t = cursor + float(e.text_of("offset", "0")) / key.divisions,
						letter = LETTERS.find(root.text_of("root-step")), alter = roundi(float(root.text_of("root-alter", "0"))),
						quality = _quality(e.text_of("kind"))})
			"barline":
				var repeat := e.child("repeat")
				if repeat and repeat.attrs.get("direction") == "forward":
					out.forward = true
				elif repeat:
					out.backward = int(repeat.attrs.get("times", "2"))
				var ending := e.child("ending")
				if ending and ending.attrs.get("type") == "start":
					out.ending = Array(ending.attrs.get("number", "1").split(",")).map(func(s: String) -> int: return int(s.strip_edges()))
				elif ending:
					out.ending_ends = true
			"note":
				if e.child("grace"):
					continue
				var in_chord := e.child("chord") != null
				if not in_chord:
					onset = cursor
					cursor += _beats(e, key)
					reach = maxf(reach, cursor)
				var pitch := e.child("pitch")
				if pitch == null or e.child("cue") or e.text_of("staff", "1") != "1" or e.text_of("voice", "1") != "1":
					continue
				var n := {t = onset, dur = _beats(e, key), letter = LETTERS.find(pitch.text_of("step")),
					alter = roundi(float(pitch.text_of("alter", "0"))), octave = int(pitch.text_of("octave")),
					tie_stop = e.all("tie").any(func(tie: El) -> bool: return tie.attrs.get("type") == "stop")}
				n.midi = 12 * (n.octave + 1) + LETTER_SEMI[n.letter] + n.alter
				var last: Dictionary = out.notes[-1] if not out.notes.is_empty() else {}
				if in_chord and not last.is_empty() and last.t == onset:
					if n.midi > last.midi:
						out.notes[-1] = n   # the top note of a chord is the melody
				else:
					out.notes.append(n)
		reach = maxf(reach, cursor)
	out.length = reach if reach > 0.0 else key.bar
	return out


## The measures in the order they are played: repeats taken and each ending on its pass.
static func _play_order(measures: Array) -> Array[int]:
	var ending := []   # each measure's ending numbers; empty outside an ending
	var open := []
	for m: Dictionary in measures:
		if not m.ending.is_empty():
			open = m.ending
		ending.append(open)
		if m.ending_ends:
			open = []
	var order: Array[int] = []
	var start := 0     # where the next backward repeat goes back to
	var pass_n := 1
	var jumps := {}
	var i := 0
	while i < measures.size() and order.size() < 20 * measures.size():
		var m: Dictionary = measures[i]
		if m.forward:
			start = i
		if not ending[i].is_empty() and not pass_n in ending[i]:
			i += 1
			continue
		order.append(i)
		if m.backward > 0:
			var done: int = jumps.get(i, 0)
			if done < m.backward - 1:
				jumps[i] = done + 1
				pass_n += 1
				i = start
				continue
			pass_n = 1
			start = i + 1
		elif m.ending_ends:
			pass_n = 1
			start = i + 1
		i += 1
	return order


## Notes and chords laid out in beats, as a song moved into C, from its first note.
static func _to_song(name: String, notes: Array, chords: Array, bars: Array, fifths: int) -> Dictionary:
	# the key's tonic, down to C: letters and semitones
	var tonic_letter := posmod(4 * fifths, 7)
	var shift := {letters = -tonic_letter, semis = -posmod(7 * fifths, 12)}
	var t0: float = notes[0].t
	var spans := []   # [start, end, note], rounded to the grid
	for n: Dictionary in notes:
		var s := snappedf(n.t - t0, GRID)
		var e := snappedf(n.t + n.dur - t0, GRID)
		if not spans.is_empty() and s <= spans[-1][0]:
			continue   # rounded onto the note before
		if not spans.is_empty():
			spans[-1][1] = minf(spans[-1][1], s)
		spans.append([s, maxf(e, s + GRID), n])
	for k in spans.size() - 1:
		if spans[k + 1][0] - spans[k][1] < SHORTEST_REST:
			spans[k][1] = spans[k + 1][0]

	# each chord goes to the first note at or after it; only changes count
	var chord_at := {}
	for c: Dictionary in chords:
		var at := snappedf(c.t - t0, GRID)
		for k in spans.size():
			if spans[k][0] >= at:
				chord_at[k] = _spell(c.letter, c.alter, 4, shift).rstrip("0123456789") + c.quality
				break
	var entries := []
	var chord := ""
	var since_banana := 0
	for k in spans.size():
		var n: Dictionary = spans[k][2]
		var beats: float = spans[k][1] - spans[k][0]
		var entry := [_spell(n.letter, n.alter, n.octave, shift), beats]
		since_banana += 1
		if since_banana >= BANANA_EVERY and beats >= 1.0:
			entry[0] += "*"
			since_banana = 0
		if chord_at.has(k) and chord_at[k] != chord:
			chord = chord_at[k]
			entry.append(chord)
		entries.append(entry)
		if k + 1 < spans.size() and spans[k + 1][0] > spans[k][1]:
			entries.append(["r", spans[k + 1][0] - spans[k][1]])
	var end: float = spans[-1][1]
	var lines := bars.map(func(b: float) -> float: return snappedf(b - t0, GRID)).filter(func(b: float) -> bool: return b > 0.0 and b < end)
	return {name = name, notes = entries, bars = lines}


## A note's name after `shift`, e.g. "Bb4": spelt on the letter it moves to, unless that
## takes a double sharp or flat.
static func _spell(letter: int, alter: int, octave: int, shift: Dictionary) -> String:
	var degree: int = 7 * octave + letter + shift.letters
	var to_letter := posmod(degree, 7)
	var to_octave := floori(degree / 7.0)
	var midi: int = 12 * (octave + 1) + LETTER_SEMI[letter] + alter + shift.semis
	var to_alter := midi - (12 * (to_octave + 1) + LETTER_SEMI[to_letter])
	if absi(to_alter) > 1:
		return NAMES[midi % 12] + str(floori(midi / 12.0) - 1)
	return LETTERS[to_letter] + ["b", "", "#"][to_alter + 1] + str(to_octave)


## A chord symbol's <kind> as a triad: "" major, "m", "dim" or "aug".
static func _quality(kind: String) -> String:
	if kind.begins_with("minor") or kind == "major-minor":
		return "m"
	if kind.begins_with("diminished") or kind == "half-diminished":
		return "dim"
	if kind.begins_with("augmented"):
		return "aug"
	return ""


static func _count(e: El, n: String) -> int:
	var hits := 1 if e.name == n else 0
	for c in e.children:
		hits += _count(c, n)
	return hits


## The score inside an .mxl, which is a zip: the file its container names, or failing that
## its first XML file.
static func _unzip(path: String) -> PackedByteArray:
	var zip := ZIPReader.new()
	if zip.open(path) != OK:
		return PackedByteArray()
	var files := zip.get_files()
	var inner := ""
	if "META-INF/container.xml" in files:
		var rootfile := _parse_xml(zip.read_file("META-INF/container.xml")).find("rootfile")
		if rootfile:
			inner = rootfile.attrs.get("full-path", "")
	if not inner in files:
		inner = ""
		for f in files:
			if not f.begins_with("META-INF") and f.get_extension().to_lower() in ["xml", "musicxml"]:
				inner = f
				break
	var bytes := zip.read_file(inner) if inner != "" else PackedByteArray()
	zip.close()
	return bytes


static func _parse_xml(bytes: PackedByteArray) -> El:
	var doc := El.new()
	var parser := XMLParser.new()
	if parser.open_buffer(bytes) != OK:
		return doc
	var stack: Array[El] = [doc]
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var e := El.new()
				e.name = parser.get_node_name()
				for i in parser.get_attribute_count():
					e.attrs[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
				stack[-1].children.append(e)
				if not parser.is_empty():
					stack.append(e)
			XMLParser.NODE_ELEMENT_END:
				if stack.size() > 1:
					stack.pop_back()
			XMLParser.NODE_TEXT:
				stack[-1].text += parser.get_node_data()
	return doc
