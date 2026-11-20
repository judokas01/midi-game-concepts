extends RefCounted
## The song book's From films: the tunes of song-ideas.md's section "From films, cartoons and games",
## written out in the format song.gd describes.

const CATEGORY := "From films"
const SONGS := [
	# The chant's first line, "Dies irae, dies illa", twice: the part The Shining and the
	# concert pieces quote. In half notes, as slow as a chant.
	{name = "Dies irae", category = "From films", difficulty = 1, key = "Dm", notes = [
		["F4", 2, "Dm"], ["E4", 2, "C"], ["F4", 2, "Dm"], ["D4", 2],
		["E4", 2, "C"], ["C4", 2], ["D4", 2, "Dm"], ["D4*", 2],
		["F4", 2, "Dm"], ["E4", 2, "C"], ["F4", 2, "Dm"], ["D4", 2],
		["E4", 2, "C"], ["C4", 2], ["D4", 2, "Dm"], ["D4*", 2],
	]},
	# The trumpets' first two calls: C, G, C, then the major chord turning minor, and the
	# second time minor turning major. The timpani between them are left out.
	{name = "Also sprach Zarathustra (R. Strauss)", category = "From films", difficulty = 2, notes = [
		["C4", 4, "C"], ["G4", 4], ["C5", 3], ["E5", 1], ["Eb5*", 4, "Cm"],
		["C4", 4, "C"], ["G4", 4], ["C5", 3], ["Eb5", 1, "Cm"], ["E5*", 4, "C"],
	]},
	# 6/8, a major third down from E major: the flute's phrase, then the oboe's answer, the
	# same. All five notes of the pentatonic scale, over the tonic.
	{name = "Morning Mood (Grieg)", category = "From films", difficulty = 2, meter = 3, notes = [
		["G4", 1, "C"], ["E4", 0.5], ["D4", 1], ["C4", 0.5],
		["D4", 1], ["E4", 0.5], ["G4", 1], ["E4", 0.5],
		["D4", 1], ["C4", 0.5], ["D4", 1], ["E4", 0.5],
		["G4", 1], ["E4", 0.5], ["G4", 1], ["A4", 0.5],
		["E4", 1], ["A4", 0.5], ["G4", 1], ["E4", 0.5],
		["D4", 1, "G"], ["C4*", 2, "C"],
		["G4", 1], ["E4", 0.5], ["D4", 1], ["C4", 0.5],
		["D4", 1], ["E4", 0.5], ["G4", 1], ["E4", 0.5],
		["D4", 1], ["C4", 0.5], ["D4", 1], ["E4", 0.5],
		["G4", 1], ["E4", 0.5], ["G4", 1], ["A4", 0.5],
		["E4", 1], ["A4", 0.5], ["G4", 1], ["E4", 0.5],
		["D4", 1, "G"], ["C4*", 2, "C"],
	]},
	# A tone down from D: the first violin's first three entries, over the ground bass's
	# chords, one a beat. The canon goes on; the last bar closes it on the tonic.
	{name = "Canon (Pachelbel)", category = "From films", difficulty = 3, notes = [
		["E5", 1, "C"], ["D5", 1, "G"], ["C5", 1, "Am"], ["B4", 1, "Em"],
		["A4", 1, "F"], ["G4", 1, "C"], ["A4", 1, "F"], ["B4*", 1, "G"],
		["C5", 1, "C"], ["B4", 1, "G"], ["A4", 1, "Am"], ["G4", 1, "Em"],
		["F4", 1, "F"], ["E4", 1, "C"], ["F4", 1, "F"], ["D4*", 1, "G"],
		["C4", 0.5, "C"], ["E4", 0.5], ["G4", 0.5, "G"], ["F4", 0.5], ["E4", 0.5, "Am"], ["C4", 0.5], ["E4", 0.5, "Em"], ["D4", 0.5],
		["C4", 0.5, "F"], ["A3", 0.5], ["C4", 0.5, "C"], ["G4", 0.5], ["F4", 0.5, "F"], ["A4", 0.5], ["G4", 0.5, "G"], ["F4", 0.5],
		["E4*", 4, "C"],
	]},
	# The oboe's swan theme, a fifth down from B minor so that it sits in the computer keys,
	# played twice as the ballet repeats it.
	{name = "Swan Lake (Tchaikovsky)", category = "From films", difficulty = 3, key = "Em", notes = [
		["B4", 2, "Em"], ["E4", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["B4", 1.5], ["G4", 0.5], ["B4", 1.5], ["G4", 0.5],
		["B4", 1.5], ["E4", 0.5, "C"], ["G4", 0.5], ["E4", 0.5], ["C4", 0.5], ["G4", 0.5],
		["E4*", 4, "Em"],
		["B4", 2], ["E4", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["B4", 1.5], ["G4", 0.5], ["B4", 1.5], ["G4", 0.5],
		["B4", 1.5], ["E4", 0.5, "C"], ["G4", 0.5], ["E4", 0.5], ["C4", 0.5], ["G4", 0.5],
		["E4*", 4, "Em"],
	]},
	# The galop, 2/4: its sixteen bars, the second half ending on the tonic.
	{name = "Can-can (Offenbach)", category = "From films", difficulty = 4, meter = 2, notes = [
		["C4", 2, "C"],
		["D4", 0.5, "G"], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5],
		["G4", 1], ["G4", 1],
		["G4", 0.5, "C"], ["A4", 0.5], ["E4", 0.5], ["F4*", 0.5],
		["D4", 1, "G"], ["D4", 1],
		["D4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5],
		["C4", 0.5, "C"], ["C5", 0.5], ["B4", 0.5], ["A4", 0.5],
		["G4", 0.5, "G"], ["F4", 0.5], ["E4", 0.5], ["D4*", 0.5],
		["C4", 2, "C"],
		["D4", 0.5, "G"], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5],
		["G4", 1], ["G4", 1],
		["G4", 0.5, "C"], ["A4", 0.5], ["E4", 0.5], ["F4*", 0.5],
		["D4", 1, "G"], ["D4", 1],
		["D4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5],
		["C4", 0.5, "C"], ["G4", 0.5], ["D4", 0.5, "G"], ["E4", 0.5],
		["C4*", 2, "C"],
	]},
	# 2/4, the first strain's first twelve bars: the tune, the tune turning to the dominant,
	# the tune again. The syncopated long notes are held across the bar line; the D7 is a D.
	{name = "The Entertainer (Joplin)", category = "From films", difficulty = 4, meter = 2, pickup = 0.5, notes = [
		["D4", 0.25], ["D#4", 0.25],
		["E4", 0.25, "C"], ["C5", 0.5], ["E4", 0.25], ["C5", 0.5], ["E4", 0.25], ["C5", 1.5],
		["C5", 0.25], ["D5", 0.25], ["D#5", 0.25],
		["E5", 0.25], ["C5", 0.25], ["D5", 0.25], ["E5", 0.5], ["B4", 0.25, "G"], ["D5", 0.5],
		["C5*", 1.5, "C"], ["D4", 0.25], ["D#4", 0.25],
		["E4", 0.25], ["C5", 0.5], ["E4", 0.25], ["C5", 0.5], ["E4", 0.25], ["C5", 1.5],
		["A4", 0.25, "D"], ["G4", 0.25], ["F#4", 0.25],
		["A4", 0.25], ["C5", 0.25], ["E5", 0.5], ["D5", 0.25], ["C5", 0.25], ["A4", 0.25], ["D5*", 1.5, "G"],
		["r", 0.25], ["D4", 0.25], ["D#4", 0.25],
		["E4", 0.25, "C"], ["C5", 0.5], ["E4", 0.25], ["C5", 0.5], ["E4", 0.25], ["C5", 1.5],
		["C5", 0.25], ["D5", 0.25], ["D#5", 0.25],
		["E5", 0.25], ["C5", 0.25], ["D5", 0.25], ["E5", 0.5], ["B4", 0.25, "G"], ["D5", 0.5],
		["C5*", 1.5, "C"],
	]},
]
