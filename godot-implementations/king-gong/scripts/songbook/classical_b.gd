extends RefCounted
## The song book's Classical: the tunes of song-ideas.md's section "Classical themes known worldwide, its second half",
## written out in the format song.gd describes.

const CATEGORY := "Classical"
const SONGS := [
	# The first two phrases, a fifth down from D so that they fit the keyboard. The score's
	# Gmaj7 and Dmaj7 are C and G here; the F# held over four bars is B3 and three bars' rest.
	{name = "Gymnopédie No. 1 (Satie)", category = "Classical", difficulty = 3, key = "G", meter = 3, pickup = 2, notes = [
		["B4", 1], ["D5", 1],
		["C5", 1, "G"], ["B4", 1], ["F#4", 1], ["E4", 1, "C"], ["F#4", 1], ["G4", 1],
		["D4", 3, "G"], ["B3*", 3, "C"], ["r", 3], ["r", 3], ["r", 3],
		["r", 1], ["B4", 1], ["D5", 1],
		["C5", 1, "G"], ["B4", 1], ["F#4", 1], ["E4", 1, "C"], ["F#4", 1], ["G4", 1],
		["D4*", 3, "G"], ["F#4", 3, "Bm"], ["B4", 3, "Em"], ["A4*", 3, "Am"],
	]},
	# The opening eight bars, played twice as the repeat sign asks, a sixth down from A minor
	# so that they fit the keyboard (A minor an octave down would need G#3): B natural for G#,
	# F# for D#. The trill on the D before the last C is left out.
	{name = "Rondo alla Turca (Mozart)", category = "Classical", difficulty = 5, key = "Cm", meter = 2, pickup = 1, notes = [
		["D4", 0.25], ["C4", 0.25], ["B3", 0.25], ["C4", 0.25],
		["Eb4", 0.5, "Cm"], ["r", 0.5], ["F4", 0.25], ["Eb4", 0.25], ["D4", 0.25], ["Eb4", 0.25],
		["G4", 0.5], ["r", 0.5], ["Ab4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["G4*", 0.25],
		["D5", 0.25], ["C5", 0.25], ["B4", 0.25], ["C5", 0.25], ["D5", 0.25], ["C5", 0.25], ["B4", 0.25], ["C5", 0.25],
		["Eb5", 1], ["C5", 0.5], ["D5*", 0.5],
		["Eb5", 0.5], ["D5", 0.5], ["C5", 0.5, "G"], ["B4", 0.5],
		["C5", 0.5, "Cm"], ["G4", 0.5], ["Ab4", 0.5, "Fm"], ["F4", 0.5],
		["Eb4", 1, "Cm"], ["D4", 1, "G"],
		["C4*", 1, "Cm"], ["D4", 0.25], ["C4", 0.25], ["B3", 0.25], ["C4", 0.25],
		["Eb4", 0.5], ["r", 0.5], ["F4", 0.25], ["Eb4", 0.25], ["D4", 0.25], ["Eb4", 0.25],
		["G4", 0.5], ["r", 0.5], ["Ab4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["G4*", 0.25],
		["D5", 0.25], ["C5", 0.25], ["B4", 0.25], ["C5", 0.25], ["D5", 0.25], ["C5", 0.25], ["B4", 0.25], ["C5", 0.25],
		["Eb5", 1], ["C5", 0.5], ["D5*", 0.5],
		["Eb5", 0.5], ["D5", 0.5], ["C5", 0.5, "G"], ["B4", 0.5],
		["C5", 0.5, "Cm"], ["G4", 0.5], ["Ab4", 0.5, "Fm"], ["F4", 0.5],
		["Eb4", 1, "Cm"], ["D4", 1, "G"],
		["C4*", 1, "Cm"],
	]},
]
