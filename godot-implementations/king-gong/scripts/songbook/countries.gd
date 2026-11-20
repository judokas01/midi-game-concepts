extends RefCounted
## The song book's From other countries: the tunes of song-ideas.md's section "From other countries, known worldwide",
## written out in the format song.gd describes.

const CATEGORY := "From other countries"
const SONGS := [
	# The Japanese "in" scale on E, written in A minor's notes (no sharps or flats). The
	# songbooks' Am, Dm and E; the E chord comes in on the low B.
	{name = "Sakura Sakura", category = "From other countries", difficulty = 2, key = "Am", notes = [
		["A4", 1, "Am"], ["A4", 1], ["B4", 2], ["A4", 1], ["A4", 1], ["B4*", 2],
		["A4", 1], ["B4", 1], ["C5", 1], ["B4", 1], ["A4", 1, "Dm"], ["B4", 0.5], ["A4", 0.5], ["F4*", 2],
		["E4", 1, "Am"], ["C4", 1], ["E4", 1], ["F4", 1], ["E4", 1], ["E4", 0.5], ["C4", 0.5], ["B3*", 2, "E"],
		["A4", 1, "Am"], ["B4", 1], ["C5", 1], ["B4", 1], ["A4", 1, "Dm"], ["B4", 0.5], ["A4", 0.5], ["F4*", 2],
		["E4", 1, "Am"], ["C4", 1], ["E4", 1], ["F4", 1], ["E4", 1], ["E4", 0.5], ["C4", 0.5], ["B3*", 2, "E"],
		["A4", 1, "Am"], ["A4", 1], ["B4", 2], ["A4", 1], ["A4", 1], ["B4*", 2],
		["E4", 1], ["F4", 1], ["B4", 0.5], ["A4", 0.5], ["F4", 1], ["E4*", 4, "E"],
	]},
	# The Russian folk tune, one verse: its two halves, without Tetris's own middle part. A fifth
	# down from the usual A minor, so that its top note, A5 there, fits.
	{name = "Korobeiniki", category = "From other countries", difficulty = 3, key = "Dm", notes = [
		["A4", 1, "Dm"], ["E4", 0.5], ["F4", 0.5], ["G4", 1], ["F4", 0.5], ["E4", 0.5],
		["D4", 1], ["D4", 0.5], ["F4", 0.5], ["A4", 1], ["G4", 0.5], ["F4*", 0.5],
		["E4", 1.5, "A"], ["F4", 0.5], ["G4", 1], ["A4", 1], ["F4", 1, "Dm"], ["D4", 1], ["D4*", 2],
		["G4", 1.5, "Gm"], ["Bb4", 0.5], ["D5", 1], ["C5", 0.5], ["Bb4", 0.5],
		["A4", 1.5, "Dm"], ["F4", 0.5], ["A4", 1], ["G4", 0.5], ["F4*", 0.5],
		["E4", 1, "A"], ["E4", 0.5], ["F4", 0.5], ["G4", 1], ["A4", 1], ["F4", 1, "Dm"], ["D4", 1], ["D4*", 2],
	]},
	# The chorus. "La cu-ca" is a quick pickup to the long "ra".
	{name = "La Cucaracha", category = "From other countries", difficulty = 3, key = "F", pickup = 1.5, notes = [
		["C4", 0.5], ["C4", 0.5], ["C4", 0.5],
		["F4", 1.5, "F"], ["A4", 1], ["C4", 0.5], ["C4", 0.5], ["C4", 0.5],
		["F4", 1.5], ["A4*", 1.5], ["F4", 0.5], ["F4", 0.5],
		["E4", 0.5, "C"], ["E4", 0.5], ["D4", 0.5], ["D4", 0.5], ["C4*", 2],
		["r", 2], ["r", 0.5], ["C4", 0.5], ["C4", 0.5], ["C4", 0.5],
		["E4", 1.5], ["G4", 1], ["C4", 0.5], ["C4", 0.5], ["C4", 0.5],
		["E4", 1.5], ["G4*", 1.5], ["C5", 0.5], ["D5", 0.5],
		["C5", 0.5], ["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5], ["F4*", 2, "F"],
	]},
]
