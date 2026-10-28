extends RefCounted
## The tune, parsed into branches. Same data as the spike.

enum Clef { TREBLE, BASS }

# [note, beats, chord]: 1 is a quarter note, 2 a half, 4 a whole, 0.5 an eighth. "r" is a rest.
# A trailing "*" hangs a banana on that branch. A chord ("C", "Am", "F#") starts on that note
# and lasts until the next one; only the treble clef with chords plays them.
const SONG := [
	["C4", 1, "C"], ["C4", 1], ["G4", 1], ["G4", 1], ["A4", 1, "F"], ["A4", 1], ["G4*", 2, "C"],
	["F4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["E4", 1], ["D4", 1, "G"], ["D4", 1], ["C4", 1, "C"], ["r", 1],
	["G4", 1], ["G4", 1], ["F4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["E4", 1], ["D4*", 2, "G"],
	["G4", 1, "C"], ["G4", 1], ["F4", 1, "F"], ["F4", 1], ["E4*", 1, "C"], ["E4", 1], ["D4", 1, "G"], ["r", 1],
	["C4", 1, "C"], ["C4", 1], ["G4", 1], ["G4", 1], ["A4", 1, "F"], ["A4", 1], ["G4*", 2, "C"],
	["F4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["E4", 1], ["D4", 1, "G"], ["D4", 1], ["C4", 2, "C"],
]

# The song is written in the treble clef. The bass clef plays it an octave down, which puts it
# inside the bass staff.
const OCTAVE_SHIFT := {Clef.TREBLE: 0, Clef.BASS: -1}
# The note on the ledger line just below each staff. That line is step 0.
const BELOW_STAFF := {Clef.TREBLE: "C4", Clef.BASS: "E2"}

const LETTER_SEMI := {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
const LETTER_STEP := {"C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6}
const LETTERS := "CDEFGAB"
const ACCIDENTALS := {"": 0, "#": 1, "b": -1}
const NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


## A triad for the left hand: "C", "Am", "F#", "Bbm".
class Chord:
	var name: String
	var minor := false
	var midi: Array[int] = []         # as the bass-clef hint writes it: root position, low in the staff
	var steps: Array[int] = []        # where those sit, in steps above the bass staff's bottom line (G2)
	var accidentals: Array[int] = []  # 1 sharp, -1 flat, 0 neither

	## Whether `held` is this chord: its three notes in any octave and any order, and nothing else.
	func is_played_by(held: Array) -> bool:
		var classes := {}
		for m: int in held:
			classes[m % 12] = true
		return classes.size() == 3 and midi.all(func(m: int) -> bool: return classes.has(m % 12))


class Note:
	var name: String
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


## `chords` reads the chords too, for the treble clef with chords.
static func parse(clef: Clef, chords := false) -> Array[Note]:
	var out: Array[Note] = []
	var beat := 0.0
	for entry in SONG:
		var raw: String = entry[0]
		var length := float(entry[1])
		if raw == "r":
			out[-1].rest_after += length
			beat += length
			continue
		var n := Note.new()
		n.banana = raw.ends_with("*")
		var letter := raw[0]
		var octave: int = int(raw.trim_suffix("*").right(1)) + OCTAVE_SHIFT[clef]
		n.name = letter + str(octave)
		n.midi = 12 * (octave + 1) + LETTER_SEMI[letter]
		n.step = _degree(n.name) - _degree(BELOW_STAFF[clef])
		n.beat = beat
		n.beats = length
		if chords and entry.size() > 2:
			n.chord = parse_chord(entry[2])
			n.log_up = true
		out.append(n)
		beat += length
	return out


## "C" becomes C3 E3 G3, "F" F2 A2 C3: the notes as the bass clef writes them, low in the staff.
static func parse_chord(name: String) -> Chord:
	var c := Chord.new()
	c.name = name
	c.minor = name.ends_with("m")
	var root := name.trim_suffix("m")
	var letter: int = LETTER_STEP[root[0]]
	var octave := 2 if letter >= LETTER_STEP["F"] else 3   # roots F2 to E3 keep the chord inside the bass staff
	var root_midi: int = 12 * (octave + 1) + LETTER_SEMI[root[0]] + ACCIDENTALS[root.substr(1)]
	for k in 3:
		var degree := 7 * octave + letter + 2 * k   # every other white key: a third up each time
		var natural: int = 12 * (floori(degree / 7.0) + 1) + LETTER_SEMI[LETTERS[degree % 7]]
		var m: int = root_midi + [0, 3 if c.minor else 4, 7][k]
		c.midi.append(m)
		c.accidentals.append(m - natural)
		c.steps.append(degree - _degree("G2"))
	return c


## White keys from C0 up to `name`, e.g. "C4" is 28.
static func _degree(name: String) -> int:
	return 7 * int(name.right(1)) + LETTER_STEP[name[0]]
