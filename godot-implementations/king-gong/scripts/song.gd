extends RefCounted
## The songs, parsed into branches. The first is the spike's; scores put in songs/ come
## after the built-in ones.

const ScoreImport := preload("res://scripts/score_import.gd")

enum Clef { TREBLE, BASS }

# [note, beats, chord]: 1 is a quarter note, 2 a half, 4 a whole, 0.5 an eighth. "r" is a rest.
# A trailing "*" hangs a banana on that branch. A chord ("C", "Am", "F#") starts on that note
# and lasts until the next one; only the treble clef with chords plays them.
# Every song here is in C, one note at a time between C4 and A4: the keyboard fallback stops
# at C5, and an octave down A3 is the bass staff's top line. All are in 4/4 and start on the
# beat, which is where bar_lines() puts the bar lines without a score's. Two bars a line.
const SONGS := [
	{name = "Twinkle Twinkle", notes = [
		["C4", 1, "C"], ["C4", 1], ["G4", 1], ["G4", 1], ["A4", 1, "F"], ["A4", 1], ["G4*", 2, "C"],
		["F4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["E4", 1], ["D4", 1, "G"], ["D4", 1], ["C4", 1, "C"], ["r", 1],
		["G4", 1], ["G4", 1], ["F4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["E4", 1], ["D4*", 2, "G"],
		["G4", 1, "C"], ["G4", 1], ["F4", 1, "F"], ["F4", 1], ["E4*", 1, "C"], ["E4", 1], ["D4", 1, "G"], ["r", 1],
		["C4", 1, "C"], ["C4", 1], ["G4", 1], ["G4", 1], ["A4", 1, "F"], ["A4", 1], ["G4*", 2, "C"],
		["F4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["E4", 1], ["D4", 1, "G"], ["D4", 1], ["C4", 2, "C"],
	]},
	{name = "Mary's Lamb", notes = [
		["E4", 1, "C"], ["D4", 1], ["C4", 1], ["D4", 1], ["E4", 1], ["E4", 1], ["E4*", 2],
		["D4", 1, "G"], ["D4", 1], ["D4", 2], ["E4", 1, "C"], ["G4", 1], ["G4*", 2],
		["E4", 1], ["D4", 1], ["C4", 1], ["D4", 1], ["E4", 1], ["E4", 1], ["E4", 1], ["E4*", 1],
		["D4", 1, "G"], ["D4", 1], ["E4", 1], ["D4", 1], ["C4", 4, "C"],
	]},
	# Alle meine Entchen. Songbooks put G7 under the four Fs; Dm keeps them inside the triad.
	{name = "Ducklings", notes = [
		["C4", 1, "C"], ["D4", 1], ["E4", 1], ["F4", 1], ["G4", 2], ["G4*", 2],
		["A4", 1, "F"], ["A4", 1], ["A4", 1], ["A4", 1], ["G4*", 4, "C"],
		["A4", 1, "F"], ["A4", 1], ["A4", 1], ["A4", 1], ["G4", 4, "C"],
		["F4", 1, "Dm"], ["F4", 1], ["F4", 1], ["F4", 1], ["E4", 2, "C"], ["E4*", 2],
		["D4", 1, "G"], ["D4", 1], ["D4", 1], ["D4", 1], ["C4", 4, "C"],
	]},
	# Hänschen klein
	{name = "Lightly Row", notes = [
		["G4", 1, "C"], ["E4", 1], ["E4", 2], ["F4", 1, "G"], ["D4", 1], ["D4", 2],
		["C4", 1, "C"], ["D4", 1], ["E4", 1], ["F4", 1], ["G4", 1], ["G4", 1], ["G4*", 2],
		["G4", 1], ["E4", 1], ["E4", 2], ["F4", 1, "G"], ["D4", 1], ["D4", 2],
		["C4", 1, "C"], ["E4", 1], ["G4", 1, "G"], ["G4", 1], ["C4*", 4, "C"],
		["D4", 1, "G"], ["D4", 1], ["D4", 1], ["D4", 1], ["D4", 1], ["E4", 1], ["F4", 2],
		["E4", 1, "C"], ["E4", 1], ["E4", 1], ["E4", 1], ["E4", 1], ["F4", 1], ["G4*", 2],
		["G4", 1], ["E4", 1], ["E4", 2], ["F4", 1, "G"], ["D4", 1], ["D4", 2],
		["C4", 1, "C"], ["E4", 1], ["G4", 1, "G"], ["G4", 1], ["C4", 4, "C"],
	]},
	{name = "Ode to Joy", notes = [
		["E4", 1, "C"], ["E4", 1], ["F4", 1], ["G4", 1], ["G4", 1, "G"], ["F4", 1], ["E4", 1], ["D4*", 1],
		["C4", 1, "C"], ["C4", 1], ["D4", 1], ["E4", 1], ["E4", 1.5, "G"], ["D4", 0.5], ["D4*", 2],
		["E4", 1, "C"], ["E4", 1], ["F4", 1], ["G4", 1], ["G4", 1, "G"], ["F4", 1], ["E4", 1], ["D4*", 1],
		["C4", 1, "C"], ["C4", 1], ["D4", 1], ["E4", 1], ["D4", 1.5, "G"], ["C4", 0.5], ["C4", 2, "C"],
	]},
	# The chorus. The songbooks' D7 is played as a D triad.
	{name = "Jingle Bells", notes = [
		["E4", 1, "C"], ["E4", 1], ["E4", 2], ["E4", 1], ["E4", 1], ["E4", 2],
		["E4", 1], ["G4", 1], ["C4", 1.5], ["D4", 0.5], ["E4*", 4],
		["F4", 1, "F"], ["F4", 1], ["F4", 1.5], ["F4", 0.5], ["F4", 1, "C"], ["E4", 1], ["E4", 1], ["E4", 0.5], ["E4", 0.5],
		["E4", 1, "D"], ["D4", 1], ["D4", 1], ["E4", 1], ["D4", 2, "G"], ["G4*", 2],
		["E4", 1, "C"], ["E4", 1], ["E4", 2], ["E4", 1], ["E4", 1], ["E4", 2],
		["E4", 1], ["G4", 1], ["C4", 1.5], ["D4", 0.5], ["E4*", 4],
		["F4", 1, "F"], ["F4", 1], ["F4", 1], ["F4", 1], ["F4", 1, "C"], ["E4", 1], ["E4", 1], ["E4", 0.5], ["E4", 0.5],
		["G4", 1, "G"], ["G4", 1], ["F4", 1], ["D4", 1], ["C4", 4, "C"],
	]},
]

# Scores read at start-up, as songs after SONGS (see score_import.gd).
const SONGS_DIR := "res://songs"
# The note on the ledger line just below each staff. That line is step 0.
const BELOW_STAFF := {Clef.TREBLE: "C4", Clef.BASS: "E2"}
# A song moves by whole octaves to sit on the staff: the lowest move that keeps every note
# between the ledger line below it and its top line, or failing that from two steps lower.
# Notes still outside fold in by octaves. Above the top line a branch's label would run
# into the top bar. SONGS stay put in the treble clef and go an octave down in the bass.
const TOP_STEP := 10
const LOWEST_STEP := -2

const LETTER_SEMI := {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
const LETTER_STEP := {"C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6}
const LETTERS := "CDEFGAB"
const ACCIDENTALS := {"": 0, "#": 1, "b": -1}
const NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
const QUALITIES := {"": [0, 4, 7], "m": [0, 3, 7], "dim": [0, 3, 6], "aug": [0, 4, 8],
	"7": [0, 4, 7, 10], "maj7": [0, 4, 7, 11], "m7": [0, 3, 7, 10]}   # semitones above the root
const SPELLED := {-2: "bb", -1: "b", 0: "", 1: "#", 2: "##"}   # how far off the white key, as written

static var _library: Array = []


## A chord for the left hand: a triad, "C", "Am", "F#", "Bbm", "Bdim", "Caug", or with its
## seventh, "G7", "Cmaj7", "Am7". The songs have triads only; the chord drill has the rest.
class Chord:
	var name: String
	var minor := false                # minor, minor seventh or diminished: drawn darker
	var midi: Array[int] = []         # as the bass-clef hint writes it: root position, low in the staff
	var steps: Array[int] = []        # where those sit, in steps above the bass staff's bottom line (G2)
	var accidentals: Array[int] = []  # 1 sharp, -1 flat, 0 neither
	var tones: Array[String] = []     # the notes' names, without octave: "C", "Eb", "G"

	## Whether `held` is this chord: its notes in any octave and any order, and nothing else.
	func is_played_by(held: Array) -> bool:
		var classes := {}
		for m: int in held:
			classes[m % 12] = true
		return classes.size() == midi.size() and midi.all(func(m: int) -> bool: return classes.has(m % 12))


class Note:
	var name: String       # "C4", "F#4", "Bb3"
	var midi: int
	var step: int          # staff steps above the ledger line below the staff
	var beat: float        # beat the note starts on
	var beats: float       # how long it is held
	var rest_after := 0.0  # beats of rest before the next note
	var banana := false
	var taken := false
	var chord: Chord       # the chord that starts on this note, null if the last one carries on
	var log_up := false    # the log before this branch, there for a new chord, still stands


static func note_name(midi: int) -> String:
	return NAMES[midi % 12] + str(floori(midi / 12.0) - 1)


static func beats_word(beats: float) -> String:
	return "1 beat" if beats == 1.0 else "%s beats" % String.num(beats)


## SONGS, then the scores in SONGS_DIR: the songs on the start screen, in its order.
static func library() -> Array:
	if _library.is_empty():
		_library = SONGS + ScoreImport.load_dir(SONGS_DIR)
	return _library


## Song `song` of library(). `chords` reads the chords too, for the treble clef with chords.
static func parse(song: int, clef: Clef, chords := false) -> Array[Note]:
	return parse_entries(library()[song].notes, clef, chords)


## A song's `entries`, as in SONGS, into branches.
static func parse_entries(entries: Array, clef: Clef, chords := false) -> Array[Note]:
	var below := _degree(BELOW_STAFF[clef])
	var shift := 7 * _octave_shift(entries, below)
	var out: Array[Note] = []
	var beat := 0.0
	for entry in entries:
		var raw: String = entry[0]
		var length := float(entry[1])
		if raw == "r":
			out[-1].rest_after += length
			beat += length
			continue
		var n := Note.new()
		n.banana = raw.ends_with("*")
		raw = raw.trim_suffix("*")
		var accidental := raw.substr(1, raw.length() - 2)   # "", "#" or "b"
		n.step = _degree(raw) + shift - below
		while n.step > TOP_STEP:
			n.step -= 7
		while n.step < LOWEST_STEP:
			n.step += 7
		var octave := floori((n.step + below) / 7.0)
		n.name = raw[0] + accidental + str(octave)
		n.midi = 12 * (octave + 1) + LETTER_SEMI[raw[0]] + ACCIDENTALS[accidental]
		n.beat = beat
		n.beats = length
		if chords and entry.size() > 2:
			n.chord = parse_chord(entry[2])
			n.log_up = true
		out.append(n)
		beat += length
	return out


## Where the bar lines go, in beats: the score's, or every four beats.
static func bar_lines(song: int, notes: Array[Note]) -> Array:
	var end := notes[-1].beat + notes[-1].beats
	var bars: Array = library()[song].get("bars", range(4, ceili(end), 4))
	return bars.filter(func(b) -> bool: return b < end)


## Octaves to move the song by: see TOP_STEP. `below` is the ledger line below the staff.
static func _octave_shift(entries: Array, below: int) -> int:
	var steps := entries.filter(func(e: Array) -> bool: return e[0] != "r") \
		.map(func(e: Array) -> int: return _degree(e[0].trim_suffix("*")) - below)
	var lo: int = steps.min()
	var hi: int = steps.max()
	for bottom in [0, LOWEST_STEP]:
		for k in range(-6, 7):
			if lo + 7 * k >= bottom and hi + 7 * k <= TOP_STEP:
				return k
	return ceili((LOWEST_STEP - lo) / 7.0)   # too wide: the lowest note at the bottom, the top folds down


## "C" becomes C3 E3 G3, "F" F2 A2 C3: the notes as the bass clef writes them, low in the staff.
static func parse_chord(name: String) -> Chord:
	var c := Chord.new()
	c.name = name
	var root := name.left(2) if name.length() > 1 and name[1] in "#b" else name.left(1)
	var quality := name.substr(root.length())
	c.minor = quality in ["m", "m7", "dim"]
	var letter: int = LETTER_STEP[root[0]]
	var octave := 2 if letter >= LETTER_STEP["F"] else 3   # roots F2 to E3 keep the chord inside the bass staff
	var root_midi: int = 12 * (octave + 1) + LETTER_SEMI[root[0]] + ACCIDENTALS[root.substr(1)]
	for k: int in QUALITIES[quality].size():
		var degree := 7 * octave + letter + 2 * k   # every other white key: a third up each time
		var natural: int = 12 * (floori(degree / 7.0) + 1) + LETTER_SEMI[LETTERS[degree % 7]]
		var m: int = root_midi + QUALITIES[quality][k]
		c.midi.append(m)
		c.accidentals.append(m - natural)
		c.steps.append(degree - _degree("G2"))
		c.tones.append(LETTERS[degree % 7] + SPELLED[m - natural])
	return c


## White keys from C0 up to `name`, e.g. "C4" is 28.
static func _degree(name: String) -> int:
	return 7 * int(name.right(1)) + LETTER_STEP[name[0]]
