extends RefCounted
## The chord drill: a made-up tune with a new chord every two beats, dealt from the chords
## picked in the chord menu. The gorilla climbs the tune by itself and waits at each chord's
## log until it is played.

const Song := preload("res://scripts/song.gd")

## The chord menu's difficulties, each with its kinds of chord.
const GROUPS := [["Major", [""]], ["Minor", ["m"]], ["Sevenths", ["7", "maj7", "m7"]], ["Dim & aug", ["dim", "aug"]]]
## The twelve roots, C to B, as each kind of chord on them is usually written: with a flat or
## a sharp, whichever never needs a double one. "" where both would: Baug, with F double sharp.
const ROOTS := {
	"": ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"],
	"m": ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"],
	"7": ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"],
	"maj7": ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"],
	"m7": ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"],
	"dim": ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"],
	"aug": ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", ""],
}
const START_CHORDS := ["C", "D", "E", "F", "G", "A", "B"]   # picked until the menu says otherwise
const COUNTS := [8, 16, 32, 64]   # how many chords a round can have
const COUNT := 16                 # until the menu says otherwise
const BANANA_EVERY := 4     # chords
const RHYTHMS := [[1.0, 1.0], [2.0], [1.0, 0.5, 0.5], [0.5, 0.5, 1.0]]   # the tune under each chord, in beats
const LOWEST := 60          # the tune is the chord's own notes, from C4
const HIGHEST := 72         # to C5, below the signs on the logs


## Every chord the menu offers, row by row.
static func all_chords() -> Array:
	var out := []
	for group: Array in GROUPS:
		for quality: String in group[1]:
			for root: String in ROOTS[quality]:
				if root != "":
					out.append(root + quality)
	return out


## "maj7" for "Ebmaj7", "" for "Bb".
static func quality_of(name: String) -> String:
	return name.substr(2 if name.length() > 1 and name[1] in "#b" else 1)


## Entries as in Song.SONGS: `count` chords dealt from `chords`, by name, like cards: each
## comes up as often as the others, in a shuffled order, never twice running unless it is
## the only one.
static func entries(chords: Array, count: int) -> Array:
	var out := []
	var deck := []
	var last := ""
	for k in count:
		if deck.is_empty():
			deck = chords.duplicate()
			deck.shuffle()
			if deck.size() > 1 and deck[-1] == last:   # dealt from the end
				deck.reverse()
		var name: String = deck.pop_back()
		last = name
		var tones := _tones(Song.parse_chord(name))
		var rhythm: Array = RHYTHMS.pick_random()
		for i in rhythm.size():
			var note: String = tones.pick_random()
			if i > 0:
				out.append([note, rhythm[i]])
			else:
				out.append([note + ("*" if k % BANANA_EVERY == BANANA_EVERY - 1 else ""), rhythm[i], name])
	return out


## The chord's notes between LOWEST and HIGHEST, by name: "C4", "E4", "G4", "C5".
static func _tones(chord: Song.Chord) -> Array[String]:
	var out: Array[String] = []
	for tone in chord.tones:
		for octave in [4, 5]:
			var m: int = 12 * (octave + 1) + Song.LETTER_SEMI[tone[0]] + Song.ACCIDENTALS[tone.substr(1)]
			if m >= LOWEST and m <= HIGHEST:
				out.append(tone + str(octave))
	return out
