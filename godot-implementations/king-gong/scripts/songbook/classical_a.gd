extends RefCounted
## The song book's Classical: the tunes of song-ideas.md's section "Classical themes known worldwide, its first half",
## written out in the format song.gd describes.

const CATEGORY := "Classical"
const SONGS := [
	# The opening motto, bars 1-5, in 2/4: the first bar's eighth rest left out, so the three
	# Gs are a pickup. The fermatas are not held longer than written.
	{name = "Symphony No. 5 (Beethoven)", category = "Classical", difficulty = 2, key = "Cm", meter = 2, pickup = 1.5, notes = [
		["G4", 0.5], ["G4", 0.5], ["G4", 0.5],
		["Eb4*", 2, "Cm"],
		["r", 0.5], ["F4", 0.5, "G"], ["F4", 0.5], ["F4", 0.5],
		["D4*", 4],
	]},
	# The Andante's first half, played twice: the second time ends on the loud chord. A tone up
	# from C, so that the low G is in reach.
	{name = "Surprise Symphony (Haydn)", category = "Classical", difficulty = 2, key = "D", meter = 2, notes = [
		["D4", 0.5, "D"], ["D4", 0.5], ["F#4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["A4", 0.5], ["F#4*", 1],
		["G4", 0.5, "A"], ["G4", 0.5], ["E4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["C#4", 0.5], ["A3*", 1],
		["D4", 0.5, "D"], ["D4", 0.5], ["F#4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["A4", 0.5], ["D5*", 1],
		["B4", 0.5, "E"], ["B4", 0.5], ["G#4", 0.5], ["G#4", 0.5], ["A4*", 1, "A"], ["r", 1],
		["D4", 0.5, "D"], ["D4", 0.5], ["F#4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["A4", 0.5], ["F#4*", 1],
		["G4", 0.5, "A"], ["G4", 0.5], ["E4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["C#4", 0.5], ["A3*", 1],
		["D4", 0.5, "D"], ["D4", 0.5], ["F#4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["A4", 0.5], ["D5*", 1],
		["B4", 0.5, "E"], ["B4", 0.5], ["G#4", 0.5], ["G#4", 0.5], ["A4*", 1, "A"], ["r", 1],
	]},
	# The march's two opening phrases, a semitone down from B-flat minor so that it sits in
	# the computer keys.
	{name = "Funeral March (Chopin)", category = "Classical", difficulty = 2, key = "Am", notes = [
		["A4", 1, "Am"], ["A4", 0.75], ["A4", 0.25], ["A4", 1], ["C5", 0.75], ["B4", 0.25],
		["B4", 0.75, "E"], ["A4", 0.25], ["A4", 0.75], ["G#4", 0.25], ["A4*", 2, "Am"],
		["A4", 1], ["A4", 0.75], ["A4", 0.25], ["A4", 1], ["C5", 0.75], ["B4", 0.25],
		["B4", 0.75, "E"], ["A4", 0.25], ["A4", 0.75], ["G#4", 0.25], ["A4*", 2, "Am"],
	]},
	# The first movement's opening bars, as written.
	{name = "Eine kleine Nachtmusik (Mozart)", category = "Classical", difficulty = 3, key = "G", notes = [
		["G4", 1, "G"], ["r", 0.5], ["D4", 0.5], ["G4", 1], ["r", 0.5], ["D4", 0.5],
		["G4", 0.5], ["D4", 0.5], ["G4", 0.5], ["B4", 0.5], ["D5*", 1], ["r", 1],
		["C5", 1, "D"], ["r", 0.5], ["A4", 0.5], ["C5", 1], ["r", 0.5], ["A4", 0.5],
		["C5", 0.5], ["A4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["D4*", 1], ["r", 1],
	]},
	# The first movement's theme, its first eight bars, an octave and a tone below G minor so
	# that it fits the computer keys: G# for F#, F for E-flat.
	{name = "Symphony No. 40 (Mozart)", category = "Classical", difficulty = 3, key = "Am", pickup = 1, notes = [
		["F4", 0.5], ["E4", 0.5],
		["E4", 1, "Am"], ["F4", 0.5], ["E4", 0.5], ["E4", 1], ["F4", 0.5], ["E4", 0.5],
		["E4", 1], ["C5", 1], ["r", 1], ["C5", 0.5], ["B4", 0.5],
		["A4", 1, "Dm"], ["A4", 0.5], ["G4", 0.5], ["F4", 1], ["F4", 0.5], ["E4", 0.5],
		["D4", 1, "E"], ["D4*", 1], ["r", 1], ["E4", 0.5], ["D4", 0.5],
		["D4", 1], ["E4", 0.5], ["D4", 0.5], ["D4", 1], ["E4", 0.5], ["D4", 0.5],
		["D4", 1], ["B4", 1], ["r", 1], ["B4", 0.5], ["A4", 0.5],
		["G#4", 1], ["G#4", 0.5], ["F4", 0.5], ["E4", 1], ["E4", 0.5], ["D4", 0.5],
		["C4", 1, "Am"], ["C4*", 1], ["r", 1],
	]},
	# From Bach's notebook for Anna Magdalena (now thought to be Petzold's). In G it climbs to
	# G5, past the top of the range; a fifth down, in C, it fits the computer keys but for B3.
	{name = "Minuet in G", category = "Classical", difficulty = 3, meter = 3, notes = [
		["G4", 1, "C"], ["C4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5], ["G4", 1], ["C4", 1], ["C4*", 1],
		["A4", 1, "F"], ["F4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C5", 1, "C"], ["C4", 1], ["C4*", 1],
		["F4", 1, "F"], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 1, "C"], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["C4", 0.5],
		["B3", 1, "G"], ["C4", 0.5], ["D4", 0.5], ["E4", 0.5], ["C4", 0.5], ["D4*", 3],
		["G4", 1, "C"], ["C4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5], ["G4", 1], ["C4", 1], ["C4*", 1],
		["A4", 1, "F"], ["F4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C5", 1, "C"], ["C4", 1], ["C4*", 1],
		["F4", 1, "F"], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 1, "C"], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["C4", 0.5],
		["D4", 1, "G"], ["E4", 0.5], ["D4", 0.5], ["C4", 0.5], ["B3", 0.5], ["C4*", 3, "C"],
	]},
]
