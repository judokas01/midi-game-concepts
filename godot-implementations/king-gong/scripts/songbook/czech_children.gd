extends RefCounted
## The song book's Czech children's songs: the tunes of song-ideas.md's section "Czech children's songs",
## written out in the format song.gd describes. Each is taken from a written score, not memory:
## its source is named above it.

const CATEGORY := "Czech children's songs"
const SONGS := [
	# Czech Wikipedia, "Skákal pes", its ABC score (in C, 4/4).
	{name = "Skákal pes přes oves", category = "Czech children's songs", difficulty = 1, notes = [
		["G4", 1, "C"], ["G4", 1], ["E4*", 2], ["G4", 1], ["G4", 1], ["E4", 2],
		["G4", 1], ["G4", 1], ["A4", 1], ["G4", 1], ["G4", 2, "G"], ["F4*", 2],
		["F4", 1], ["F4", 1], ["D4", 2], ["F4", 1], ["F4", 1], ["D4", 2],
		["F4", 1], ["F4", 1], ["G4", 1], ["F4", 1], ["F4", 2], ["E4*", 2, "C"],
	]},
	# German Wikipedia, "Häschen in der Grube", its LilyPond score (in D, 2/4): the same tune.
	{name = "Zajíček ve své jamce", category = "Czech children's songs", difficulty = 2, key = "D", meter = 2, notes = [
		["D4", 0.5, "D"], ["E4", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 1], ["A4", 1],
		["B4", 0.5, "G"], ["G4", 0.5], ["D5", 0.5], ["B4", 0.5], ["A4*", 1, "D"], ["r", 1],
		["B4", 0.5, "G"], ["G4", 0.5], ["D5", 0.5], ["B4", 0.5], ["A4*", 1, "D"], ["r", 1],
		["A4", 0.5, "A"], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5, "D"], ["F#4", 0.5], ["F#4", 1],
		["F#4", 0.5, "A"], ["E4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["D4", 0.5, "D"], ["F#4", 0.5], ["A4*", 1],
		["A4", 0.5], ["A4", 0.5], ["D5", 1], ["A4", 0.5], ["A4", 0.5], ["D5", 1],
		["A4", 1, "A"], ["A4", 1], ["D4*", 1, "D"], ["r", 1],
	]},
]
