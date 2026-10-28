extends RefCounted
## The tune, parsed into branches. Same data as the spike.

# [note, beats]. "r" is a rest. A trailing "*" hangs a banana on that branch.
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
	var beats: int
	var beat: int          # beat the note starts on
	var xu: float          # horizontal position, in beat units
	var rest_after := 0
	var rx0u := 0.0        # rest gap, for the liana
	var rx1u := 0.0
	var banana := false
	var taken := false


static func note_name(midi: int) -> String:
	return NAMES[midi % 12] + str(floori(midi / 12.0) - 1)


static func beats_word(n: int) -> String:
	return "1 beat" if n == 1 else "%d beats" % n


## Horizontal space, loosely proportional like engraved music.
static func gap_units(beats: int) -> float:
	return 0.6 + 0.4 * beats


static func parse() -> Array[Note]:
	var out: Array[Note] = []
	var beat := 0
	var xu := 0.0
	for entry in SONG:
		var raw: String = entry[0]
		var length: int = entry[1]
		if raw == "r":
			var p := out[-1]
			p.rest_after += length
			p.rx0u = xu
			xu += gap_units(length) + 0.4
			p.rx1u = xu
			beat += length
			continue
		var n := Note.new()
		n.banana = raw.ends_with("*")
		n.name = raw.trim_suffix("*")
		var letter := n.name[0]
		var octave := int(n.name.right(1))
		n.midi = 12 * (octave + 1) + LETTER_SEMI[letter]
		n.step = 7 * (octave - 4) + LETTER_STEP[letter]
		n.beats = length
		n.beat = beat
		n.xu = xu
		out.append(n)
		beat += length
		xu += gap_units(length)
	return out
