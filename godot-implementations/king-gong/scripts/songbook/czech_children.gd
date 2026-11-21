extends RefCounted
## The song book's Czech children's songs: the tunes of song-ideas.md's section "Czech children's songs",
## written out in the format song.gd describes. Each names its source above it: a written
## score, or memory, with what is in doubt.

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
	# After the CC0 LilyPond score on Wikimedia Commons (in C, 2/4), its repeat written out:
	# https://commons.wikimedia.org/wiki/File:Kočka-leze-dírou.svg. "Nebude-li pršet,
	# nezmoknem" twice, ending on G, then on C. The chords are mine; the score has none. The
	# four Fs go under Dm, as in Ducklings.
	{name = "Kočka leze dírou", category = "Czech children's songs", difficulty = 2, meter = 2, notes = [
		["C4", 0.5, "C"], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5], ["G4", 1], ["G4", 1],
		["A4", 1, "F"], ["A4", 1], ["G4*", 2, "C"],
		["A4", 1, "F"], ["A4", 1], ["G4", 2, "C"],
		["F4", 0.5, "Dm"], ["F4", 0.5], ["F4", 0.5], ["F4", 0.5], ["E4", 1, "C"], ["E4", 1],
		["D4", 1, "G"], ["D4", 1], ["G4*", 2],
		["F4", 0.5, "Dm"], ["F4", 0.5], ["F4", 0.5], ["F4", 0.5], ["E4", 1, "C"], ["E4", 1],
		["D4", 1, "G"], ["D4", 1], ["C4*", 2, "C"],
	]},
	# After Erk & Irmer, Die deutschen Volkslieder mit ihren Singweisen 2 (1838), No. 22
	# "Musikantenlied" (Ich bin ein Musikante), the tune the Czech words go to:
	# https://digitale-sammlungen.de/view/bsb11160859?page=20,21. A whole step down from G, onto
	# C4 to C5. The chorus's echo of the first line is left out; one instrument, the trumpet's
	# "tengtereng". The Czech "Na co hrát?" middle may go otherwise.
	{name = "Já jsem muzikant", category = "Czech children's songs", difficulty = 3, key = "F", meter = 2, pickup = 0.5, notes = [
		["C4", 0.5],
		["F4", 0.75, "F"], ["F4", 0.25], ["A4", 0.75], ["A4", 0.25], ["C5", 1], ["A4", 0.5], ["A4", 0.5],
		["Bb4", 0.5, "C"], ["Bb4", 0.5], ["G4", 0.5], ["G4", 0.5], ["F4*", 1, "F"], ["r", 0.5], ["Bb4", 0.5],
		["Bb4", 1, "C"], ["G4", 1], ["A4", 1, "F"], ["F4", 0.5], ["A4", 0.5],
		["Bb4", 0.75, "C"], ["Bb4", 0.25], ["G4", 1], ["A4", 1, "F"], ["F4*", 0.5], ["r", 0.5],
		["Bb4", 1, "C"], ["G4", 1], ["A4", 1, "F"], ["F4", 0.5], ["r", 0.5],
		["Bb4", 1, "C"], ["G4", 1], ["A4", 1, "F"], ["F4*", 0.5], ["C4", 0.5],
		["F4", 0.75], ["F4", 0.25], ["F4", 0.5], ["A4", 0.5], ["C5", 0.75], ["C5", 0.25], ["C5", 0.5], ["A4", 0.5],
		["Bb4", 0.75, "C"], ["Bb4", 0.25], ["Bb4", 0.5], ["G4", 0.5], ["Bb4", 0.75], ["Bb4", 0.25], ["Bb4", 0.5], ["C4", 0.5],
		["F4", 0.75, "F"], ["F4", 0.25], ["F4", 0.5], ["A4", 0.5], ["C5", 0.75], ["C5", 0.25], ["C5", 0.5], ["A4", 0.5],
		["Bb4", 0.75, "C"], ["Bb4", 0.25], ["Bb4", 0.5], ["G4", 0.5], ["F4*", 1, "F"], ["r", 0.5],
	]},
	# After the CC0 LilyPond score on Wikimedia Commons (in D, 2/4):
	# https://commons.wikimedia.org/wiki/File:Cizecku-cizecku.svg. A fourth up, into G, so that
	# its low A3 lands on D4 and it sits on the computer keys. Both halves: the question and
	# "Aj tak, tak, sejou mák". The chords are mine; the score has none.
	{name = "Čížečku, čížečku", category = "Czech children's songs", difficulty = 2, key = "G", meter = 2, notes = [
		["G4", 0.5, "G"], ["D4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 1], ["G4", 1],
		["A4", 1, "D"], ["F#4", 0.5], ["F#4", 0.5], ["G4*", 1, "G"], ["D4", 1],
		["G4", 0.5], ["D4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 1], ["G4", 1],
		["A4", 1, "D"], ["F#4", 0.5], ["F#4", 0.5], ["G4*", 1, "G"], ["r", 1],
		["C5", 0.5, "C"], ["C5", 0.5], ["A4", 1], ["B4", 0.5, "G"], ["B4", 0.5], ["G4", 1],
		["A4", 0.5, "D"], ["A4", 0.5], ["F#4", 1], ["G4", 0.5, "G"], ["A4", 0.5], ["B4*", 1],
		["C5", 0.5, "C"], ["C5", 0.5], ["A4", 1], ["B4", 0.5, "G"], ["B4", 0.5], ["G4", 1],
		["A4", 1, "D"], ["F#4", 0.5], ["F#4", 0.5], ["G4*", 1, "G"], ["r", 1],
	]},
]
