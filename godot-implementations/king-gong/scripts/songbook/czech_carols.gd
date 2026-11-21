extends RefCounted
## The song book's Czech carols: the tunes of song-ideas.md's section "Czech Christmas carols",
## written out in the format song.gd describes. Each is taken from a written score, not memory:
## its source is named above it.

const CATEGORY := "Czech carols"
const SONGS := [
	# After Czech Wikipedia, "Narodil se Kristus Pán", its ABC score (in F); down a fourth to C.
	# The raised fourth of the first line (B natural there) is F# here, as the page says every
	# modern version sings it.
	{name = "Narodil se Kristus Pán", category = "Czech carols", difficulty = 2, notes = [
		["C4", 1, "C"], ["C4", 1], ["E4", 1], ["F#4", 1, "D"], ["G4", 1, "G"], ["G4", 1], ["G4", 2],
		["F#4", 1, "D"], ["G4", 1], ["A4", 2], ["G4*", 4, "G"],
		["G4", 1, "C"], ["G4", 1], ["F4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["E4", 1], ["D4", 2, "G"],
		["E4", 1, "C"], ["F4", 1], ["E4", 1], ["D4", 1, "G"], ["C4*", 4, "C"],
		["E4", 1], ["D4", 1], ["E4", 1], ["F4", 1], ["G4", 2, "G"], ["C4", 2, "C"],
		["E4", 1], ["D4", 1], ["E4", 1], ["F4", 1], ["G4", 2, "G"], ["C4*", 2, "C"],
		["C4", 2], ["A4", 2, "F"], ["G4", 1, "C"], ["F4", 1], ["E4", 1], ["D4", 1, "G"],
		["C4*", 4, "C"],
	]},
	# After German Wikipedia, "Kommet, ihr Hirten", its LilyPond score (in F, 3/4): the same
	# Czech tune. Its first four bars twice, "Slyšte je pilně" twice, "rozjímejte". Chords
	# simplified from its left hand.
	{name = "Nesem vám noviny", category = "Czech carols", difficulty = 3, key = "F", meter = 3, notes = [
		["C5", 1, "F"], ["C5", 0.5], ["A4", 0.5], ["D5", 0.5, "Bb"], ["Bb4", 0.5],
		["C5", 1, "F"], ["C5", 0.5], ["A4", 0.5], ["D5", 0.5, "Bb"], ["Bb4", 0.5],
		["C5", 1, "F"], ["A4", 0.5], ["C5", 0.5], ["G4", 0.5, "C"], ["A4", 0.5], ["F4*", 3, "F"],
		["C5", 1], ["C5", 0.5], ["A4", 0.5], ["D5", 0.5, "Bb"], ["Bb4", 0.5],
		["C5", 1, "F"], ["C5", 0.5], ["A4", 0.5], ["D5", 0.5, "Bb"], ["Bb4", 0.5],
		["C5", 1, "F"], ["A4", 0.5], ["C5", 0.5], ["G4", 0.5, "C"], ["A4", 0.5], ["F4*", 3, "F"],
		["F4", 1], ["A4", 0.5], ["F4", 0.5], ["A4", 0.5], ["C5", 0.5],
		["F4", 1], ["A4", 0.5], ["F4", 0.5], ["G4", 0.5, "C"], ["C4", 0.5],
		["F4", 1, "F"], ["A4", 0.5], ["F4", 0.5], ["A4", 0.5], ["C5", 0.5],
		["F4", 1], ["A4", 0.5], ["F4", 0.5], ["G4", 0.5, "C"], ["C4*", 0.5],
		["C5", 1, "F"], ["A4", 0.5], ["C5", 0.5], ["G4", 0.5, "C"], ["A4", 0.5], ["F4*", 3, "F"],
	]},
	# After the score the user sent (in E minor, 3/4, with its chords: the H7 as B).
	{name = "Den přeslavný", category = "Czech carols", difficulty = 2, key = "Em", meter = 3, notes = [
		["E4", 1, "Em"], ["E4", 1], ["E4", 1], ["F#4", 2, "B"], ["F#4", 1],
		["G4", 2, "Em"], ["A4", 1, "D"], ["B4*", 3, "G"],
		["E4", 1, "Em"], ["E4", 1], ["E4", 1], ["F#4", 2, "B"], ["F#4", 1],
		["G4", 2, "Em"], ["A4", 1, "D"], ["B4*", 2, "G"], ["A4", 1, "D"],
		["B4", 2, "G"], ["B4", 1], ["A4", 2, "D"], ["A4", 1],
		["G4", 2, "Em"], ["G4", 1], ["F#4*", 3, "B"],
		["E4", 2, "Em"], ["B4", 1], ["A4", 1, "Am"], ["G4", 2],
		["F#4", 3, "B"], ["E4*", 2, "Em"], ["A4", 1, "D"],
		["B4", 2, "G"], ["B4", 1], ["A4", 2, "D"], ["A4", 1],
		["G4", 2, "Em"], ["G4", 1], ["F#4*", 3, "B"],
		["E4", 2, "Em"], ["B4", 1, "G"], ["A4", 1, "D"], ["G4", 2, "Em"],
		["F#4", 3, "B"], ["E4*", 3, "Em"],
	]},
	# After English Wikipedia, "The Rocking Carol", its LilyPond score (Oxford Book of Carols;
	# in F, 2/4, which fits the Czech words): note values doubled, so 4/4. The B naturals are
	# the score's turns. Chords simplified from its four parts.
	{name = "Hajej, nynej, Ježíšku", category = "Czech carols", difficulty = 3, key = "F", notes = [
		["F4", 1, "F"], ["A4", 1], ["C5", 1], ["C5", 1], ["D5", 1, "G"], ["D5", 0.5], ["B4", 0.5], ["C5", 2, "C"],
		["D5", 1, "G"], ["D5", 0.5], ["B4", 0.5], ["C5*", 2, "C"],
		["Bb4", 1, "Bb"], ["Bb4", 0.5], ["G4", 0.5], ["A4", 1, "F"], ["A4", 0.5], ["F4", 0.5],
		["G4", 1, "C"], ["G4", 0.5], ["E4", 0.5], ["F4*", 2, "F"],
		["A4", 1], ["C5", 1], ["Bb4", 1], ["A4", 1], ["G4", 1, "C"], ["A4", 1], ["G4", 1], ["C4", 1],
		["A4", 1, "F"], ["C5", 1], ["Bb4", 1], ["A4", 1], ["G4", 1, "C"], ["A4", 1], ["G4", 1], ["C4*", 1],
		["F4", 1, "F"], ["A4", 1], ["C5", 1], ["C5", 1], ["D5", 1, "G"], ["D5", 0.5], ["B4", 0.5], ["C5", 2, "C"],
		["Bb4", 1, "Bb"], ["Bb4", 0.5], ["G4", 0.5], ["A4", 1, "F"], ["A4", 0.5], ["F4", 0.5],
		["G4", 1, "C"], ["G4", 0.5], ["E4", 0.5], ["F4*", 2, "F"],
	]},
	# After Czech Wikisource, "Malý koledníček/Chtíc, aby spal", its LilyPond score (Pazdírek,
	# 1939; in Ab, 3/4): down a semitone to G. Its first part twice, then the "Nynej" part.
	{name = "Chtíc, aby spal", category = "Czech carols", difficulty = 2, key = "G", meter = 3, notes = [
		["D4", 1, "G"], ["E4", 1], ["F#4", 1, "D"], ["G4", 2, "G"], ["G4", 1], ["A4", 2, "D"], ["A4", 1],
		["B4", 2, "G"], ["r", 1], ["C5", 1, "C"], ["B4", 1, "G"], ["A4", 1, "D"], ["G4*", 2, "G"], ["r", 1],
		["D4", 1], ["E4", 1], ["F#4", 1, "D"], ["G4", 2, "G"], ["G4", 1], ["A4", 2, "D"], ["A4", 1],
		["B4", 2, "G"], ["r", 1], ["C5", 1, "C"], ["B4", 1, "G"], ["A4", 1, "D"], ["G4*", 2, "G"], ["r", 1],
		["B4", 1], ["B4", 1], ["A4", 1, "D"], ["B4", 2, "G"], ["A4", 1, "D"], ["B4", 1, "G"], ["G4", 2, "Em"],
		["A4", 2, "D"], ["r", 1], ["G4", 1, "Em"], ["F#4", 1, "D"], ["E4", 1, "C"], ["D4*", 2, "D"], ["r", 1],
		["B4", 1, "G"], ["B4", 1], ["A4", 1, "D"], ["B4", 2, "G"], ["A4", 1, "D"], ["B4", 1, "G"], ["G4", 2, "Em"],
		["A4", 2, "D"], ["r", 1], ["C5", 1, "C"], ["B4", 1, "G"], ["A4", 1, "D"], ["G4*", 2, "G"], ["r", 1],
	]},
]
