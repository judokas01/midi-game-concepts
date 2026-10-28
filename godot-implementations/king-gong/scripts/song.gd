extends RefCounted
## The tune, parsed into branches. Same data as the spike.

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

const LETTER_SEMI := {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
const LETTER_STEP := {"C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6}
const NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]


class Note:
	var name: String
	var midi: int
	var step: int          # staff steps above C4
	var beat: float        # beat the note starts on
	var beats: float       # how long it is held
	var rest_after := 0.0  # beats of rest before the next note
	var banana := false
	var taken := false


static func note_name(midi: int) -> String:
	return NAMES[midi % 12] + str(floori(midi / 12.0) - 1)


static func beats_word(beats: float) -> String:
	return "1 beat" if beats == 1.0 else "%s beats" % String.num(beats)


static func parse() -> Array[Note]:
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
		n.name = raw.trim_suffix("*")
		var letter := n.name[0]
		var octave := int(n.name.right(1))
		n.midi = 12 * (octave + 1) + LETTER_SEMI[letter]
		n.step = 7 * (octave - 4) + LETTER_STEP[letter]
		n.beat = beat
		n.beats = length
		out.append(n)
		beat += length
	return out
