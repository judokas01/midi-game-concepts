extends RefCounted
## The song book's Czech classics: the tunes of song-ideas.md's section "Czech classics",
## written out in the format song.gd describes.

const CATEGORY := "Czech classics"
const SONGS := [
	# The river's theme, its first eight bars, in 6/8. A major third down from E minor so that
	# it sits on the computer keys, C4 to C5.
	{name = "Vltava (Smetana)", category = "Czech classics", difficulty = 2, key = "Cm", meter = 3, notes = [
		["C4", 1, "Cm"], ["D4", 0.5], ["Eb4", 1], ["F4", 0.5], ["G4", 1.5], ["G4*", 1.5],
		["Ab4", 1, "Fm"], ["Ab4", 0.5], ["C5", 1], ["Ab4", 0.5], ["G4*", 3, "Cm"],
		["F4", 1, "Bb"], ["F4", 0.5], ["Ab4", 1], ["F4", 0.5], ["Eb4*", 3, "Eb"],
		["D4", 1, "G"], ["D4", 0.5], ["F4", 1], ["D4", 0.5], ["C4", 3, "Cm"],
	]},
	# The cor anglais tune (Goin' Home), its two phrases, a semitone down from D-flat major.
	{name = "Largo from the New World Symphony (Dvořák)", category = "Czech classics", difficulty = 2, notes = [
		["E4", 1.5, "C"], ["G4", 0.5], ["G4", 2], ["E4", 1.5], ["D4", 0.5], ["C4*", 2],
		["D4", 1.5, "G"], ["E4", 0.5], ["G4", 1.5], ["E4", 0.5], ["D4*", 4],
		["E4", 1.5, "C"], ["G4", 0.5], ["G4", 2], ["E4", 1.5], ["D4", 0.5], ["C4*", 2],
		["D4", 1.5, "G"], ["E4", 0.5], ["D4", 1.5], ["C4", 0.5], ["C4", 4, "C"],
	]},
]
