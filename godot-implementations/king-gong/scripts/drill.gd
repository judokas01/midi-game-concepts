extends RefCounted
## The chord drill: a made-up tune with a new chord every few beats, dealt from the chords
## picked on the drill board and in its chord grid. Each log stands on its chord's root, and
## the branches up to the next log are the next chord's notes, low to high: an arpeggio that
## leads into it. The gorilla climbs the tune by itself and waits at each chord's log until it
## is played.

const Song := preload("res://scripts/song.gd")

## The chord grid's difficulties, each with its kinds of chord.
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
const BEATS := 4                  # a new chord this many beats after the last, until the menu says otherwise
const BEATS_MIN := 1
const BEATS_MAX := 8
const BANANA_EVERY := 4     # chords
const LENGTHS := [2.0, 1.0, 0.5]   # an arpeggio's notes, in beats: the longest that fits
const LOWEST := 60          # the tune is the chords' own notes, from C4
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
## the only one. A chord every `beats` beats: its log's branch, on its root, then the next
## chord's arpeggio(); the last log holds all its beats.
static func entries(chords: Array, count: int, beats: int = BEATS) -> Array:
	var names := []
	var deck := []
	for k in count:
		if deck.is_empty():
			deck = chords.duplicate()
			deck.shuffle()
			if deck.size() > 1 and not names.is_empty() and deck[-1] == names[-1]:   # dealt from the end
				deck.reverse()
		names.append(deck.pop_back())
	var out := []
	for k in count:
		var run := [] if k + 1 == count else arpeggio(Song.parse_chord(names[k + 1]), beats)
		var held := float(beats)
		for note: Array in run:
			held -= note[1]
		var root: String = Song.parse_chord(names[k]).tones[0]
		out.append([root + "4" + ("*" if k % BANANA_EVERY == BANANA_EVERY - 1 else ""), held, names[k]])
		out.append_array(run)
	return out


## The branches before `chord`'s log, a chord every `beats` beats, as [name, beats]: its notes
## from C4 to C5, low to high, all as long, the longest of LENGTHS that leaves the branch of
## the log before them at least as long. Where even an eighth is too long, the lowest notes
## drop out; fewer than two, there are none.
static func arpeggio(chord: Song.Chord, beats: int) -> Array:
	var tones := _tones(chord)
	var length := 0.0
	for each: float in LENGTHS:
		if (tones.size() + 1) * each <= beats:
			length = each
			break
	if length == 0.0:
		length = LENGTHS[-1]
		var fit := floori(beats / length) - 1   # the log's own branch takes one
		if fit < 2:
			return []
		tones = tones.slice(tones.size() - fit)
	return tones.map(func(tone: String) -> Array: return [tone, length])


## The chord's notes between LOWEST and HIGHEST, low to high, by name: "C4", "E4", "G4", "C5".
static func _tones(chord: Song.Chord) -> Array[String]:
	var by_pitch := {}
	for tone in chord.tones:
		for octave in [4, 5]:
			var m: int = 12 * (octave + 1) + Song.LETTER_SEMI[tone[0]] + Song.ACCIDENTALS[tone.substr(1)]
			if m >= LOWEST and m <= HIGHEST:
				by_pitch[m] = tone + str(octave)
	var pitches := by_pitch.keys()
	pitches.sort()
	var out: Array[String] = []
	for m: int in pitches:
		out.append(by_pitch[m])
	return out
