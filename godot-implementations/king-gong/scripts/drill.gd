extends RefCounted
## The chord drill: a made-up tune with a new chord every two beats, each drawn at random from
## the kinds of chord picked on the start screen. The gorilla climbs the tune by itself and
## waits at each chord's log until it is played.

const Song := preload("res://scripts/song.gd")

enum Kind { MAJOR, MINOR, SEVENTH, DIM_AUG }

const QUALITIES := {Kind.MAJOR: [""], Kind.MINOR: ["m"], Kind.SEVENTH: ["7", "maj7", "m7"], Kind.DIM_AUG: ["dim", "aug"]}
const CHORDS := 16
const BANANA_EVERY := 4     # chords
const RHYTHMS := [[1.0, 1.0], [2.0], [1.0, 0.5, 0.5], [0.5, 0.5, 1.0]]   # the tune under each chord, in beats
const LOWEST := 60          # the tune is the chord's own notes, from C4
const HIGHEST := 72         # to C5, below the signs on the logs


## Entries as in Song.SONGS: CHORDS chords on the roots C to B, of the `kinds` given (Kind),
## never the same twice running.
static func entries(kinds: Array) -> Array:
	var names: Array[String] = []
	for kind: Kind in kinds:
		for quality: String in QUALITIES[kind]:
			for root in Song.LETTERS:
				names.append(root + quality)
	names.erase("Baug")   # its fifth is F double sharp
	var out := []
	var last := ""
	for k in CHORDS:
		var name := last
		while name == last:
			name = names.pick_random()
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
