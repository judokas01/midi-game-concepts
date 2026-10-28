extends RefCounted
## The tune, parsed into branches. Same data as the spike.

enum Clef { TREBLE, BASS }

# [note, beats]: 1 is a quarter note, 2 a half, 4 a whole, 0.5 an eighth. "r" is a rest.
# A trailing "*" hangs a banana on that branch.
const SONG := [
	["C4", 1], ["C4", 1], ["G4", 1], ["G4", 1], ["A4", 1], ["A4", 1], ["G4*", 2],
	["F4", 1], ["F4", 1], ["E4", 1], ["E4", 1], ["D4", 1], ["D4", 1], ["C4", 1], ["r", 1],
	["G4", 1], ["G4", 1], ["F4", 1], ["F4", 1], ["E4", 1], ["E4", 1], ["D4*", 2],
	["G4", 1], ["G4", 1], ["F4", 1], ["F4", 1], ["E4*", 1], ["E4", 1], ["D4", 1], ["r", 1],
	["C4", 1], ["C4", 1], ["G4", 1], ["G4", 1], ["A4", 1], ["A4", 1], ["G4*", 2],
	["F4", 1], ["F4", 1], ["E4", 1], ["E4", 1], ["D4", 1], ["D4", 1], ["C4", 2],
]

# The song is written in the treble clef. The bass clef plays it an octave down, which puts it
# inside the bass staff.
const OCTAVE_SHIFT := {Clef.TREBLE: 0, Clef.BASS: -1}
# The note on the ledger line just below each staff. That line is step 0.
const BELOW_STAFF := {Clef.TREBLE: "C4", Clef.BASS: "E2"}

const LETTER_SEMI := {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
const LETTER_STEP := {"C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6}
const NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


class Note:
	var name: String
	var midi: int
	var step: int          # staff steps above the ledger line below the staff
	var beat: float        # beat the note starts on
	var beats: float       # how long it is held
	var rest_after := 0.0  # beats of rest before the next note
	var banana := false
	var taken := false


static func note_name(midi: int) -> String:
	return NAMES[midi % 12] + str(floori(midi / 12.0) - 1)


static func beats_word(beats: float) -> String:
	return "1 beat" if beats == 1.0 else "%s beats" % String.num(beats)


static func parse(clef: Clef) -> Array[Note]:
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
		out.append(n)
		beat += length
	return out


## White keys from C0 up to `name`, e.g. "C4" is 28.
static func _degree(name: String) -> int:
	return 7 * int(name.right(1)) + LETTER_STEP[name[0]]
