extends RefCounted
## The song book's Czech folk songs: the tunes of song-ideas.md's section "Czech folk songs everyone knows",
## written out in the format song.gd describes. Each is taken from a written score, not memory:
## its source is named above it.

const CATEGORY := "Czech folk songs"
const SONGS := [
	# After https://cs.wikisource.org/wiki/Naše_písně/Ovčáci,_pasáci (Vorel), the same tune as
	# Erben's "Ovčáci"; down a fifth from G. Sung twice, for the second verse.
	{name = "Ovčáci, čtveráci", category = "Czech folk songs", difficulty = 2, meter = 2, notes = [
		["C4", 1, "C"], ["E4", 1], ["G4", 1], ["r", 1], ["C4", 1], ["E4", 1], ["G4*", 1], ["r", 1],
		["E4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 1, "G"], ["D4", 1],
		["E4", 0.5, "C"], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 1, "G"], ["D4", 1],
		["E4", 1, "C"], ["D4", 1, "G"], ["C4*", 1, "C"], ["r", 1],
		["C4", 1], ["E4", 1], ["G4", 1], ["r", 1], ["C4", 1], ["E4", 1], ["G4*", 1], ["r", 1],
		["E4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 1, "G"], ["D4", 1],
		["E4", 0.5, "C"], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 1, "G"], ["D4", 1],
		["E4", 1, "C"], ["D4", 1, "G"], ["C4*", 2, "C"],
	]},
	# After https://cs.wikisource.org/wiki/Prostonárodní_české_písně_a_říkadla/Mysliveček_(Na_tý_louce)
	# (Erben); down a fifth from G. Its second half twice, as written. Erben's tune ends on E,
	# the third: the version sung today may end differently.
	{name = "Na tý louce zelený", category = "Czech folk songs", difficulty = 2, meter = 3, notes = [
		["E4", 2, "C"], ["D4", 1], ["E4", 2], ["G4", 1], ["G4", 2, "G"], ["F4", 1], ["D4*", 2], ["r", 1],
		["F4", 2, "F"], ["E4", 1], ["F4", 2], ["A4", 1], ["A4", 2], ["G4", 1], ["E4*", 2, "C"], ["r", 1],
		["C5", 2], ["B4", 1], ["C5", 2, "F"], ["A4", 1], ["G4", 2, "C"], ["C5", 1], ["E4", 2], ["G4", 1],
		["F4", 2, "F"], ["E4", 1], ["F4", 2, "G"], ["D4", 1], ["E4", 1, "C"], ["F4", 1], ["G4", 1], ["E4*", 2], ["r", 1],
		["C5", 2], ["B4", 1], ["C5", 2, "F"], ["A4", 1], ["G4", 2, "C"], ["C5", 1], ["E4", 2], ["G4", 1],
		["F4", 2, "F"], ["E4", 1], ["F4", 2, "G"], ["D4", 1], ["E4", 1, "C"], ["F4", 1], ["G4", 1], ["E4*", 3],
	]},
	# After the score the user sent (in C, 4/4, with its chords: the G7 as G). Its lower staff,
	# a second voice, is left out.
	{name = "Vyletěla holubička", category = "Czech folk songs", difficulty = 2, notes = [
		["C4", 1, "C"], ["D4", 1], ["E4", 1], ["F4", 1], ["G4", 1, "G"], ["A4", 1], ["B4", 1], ["G4", 1],
		["C5", 2, "Am"], ["C5", 2], ["B4*", 4, "Em"],
		["A4", 2, "F"], ["A4", 2], ["G4*", 4, "C"],
		["F4", 1, "Dm"], ["A4", 1], ["F4", 1], ["D4", 1], ["E4", 1, "C"], ["G4", 1], ["E4", 1], ["C4", 1],
		["D4", 2, "G"], ["D4", 2], ["G4*", 4, "C"],
		["F4", 1, "Dm"], ["A4", 1], ["F4", 1], ["D4", 1], ["E4", 1, "C"], ["G4", 1], ["E4", 1], ["C4", 1],
		["D4", 2, "G"], ["D4", 2], ["C4*", 4, "C"],
	]},
	# After https://cs.wikisource.org/wiki/Prácheňský_zpěvník/Zafoukej,_větříčku: the tune of
	# "Zafoukej, větříčku", whose third verse is "Kdyby byl Bavorov, co jsou Vodňany". A South
	# Bohemian version, which may not be the polka sung most today. Down a major third from E;
	# its phrases end on E, as the score's do on G sharp. Its first line twice, as written.
	{name = "Kdyby byl Bavorov", category = "Czech folk songs", difficulty = 2, meter = 2, notes = [
		["C4", 0.5, "C"], ["E4", 0.5], ["E4", 1], ["G4", 0.5], ["A4", 0.5], ["G4", 1],
		["G4", 0.5, "G"], ["F4", 0.5], ["D4", 0.5], ["F4", 0.5], ["E4*", 1, "C"], ["r", 1],
		["C4", 0.5], ["E4", 0.5], ["E4", 1], ["G4", 0.5], ["A4", 0.5], ["G4", 1],
		["G4", 0.5, "G"], ["F4", 0.5], ["D4", 0.5], ["F4", 0.5], ["E4*", 1, "C"], ["r", 1],
		["F4", 0.5, "F"], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G4", 0.5, "C"], ["G4", 1],
		["G4", 0.5, "G"], ["F4", 0.5], ["F4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5, "C"], ["C4*", 1],
		["C4", 0.5], ["E4", 0.5], ["E4", 1], ["G4", 0.5], ["A4", 0.5], ["G4", 1],
		["G4", 0.5, "G"], ["F4", 0.5], ["D4", 0.5], ["F4", 0.5], ["E4*", 2, "C"],
	]},
	# After https://cs.wikisource.org/wiki/Naše_písně/Pásla_ovečky_v_zeleném_háječku (Vorel),
	# the same tune as Kuba's and Náš poklad's; in C. The "dupy, dupy, dup" line twice.
	{name = "Pásla ovečky v zeleném háječku", category = "Czech folk songs", difficulty = 2, meter = 3, notes = [
		["G4", 2, "C"], ["F4", 1], ["E4", 1], ["G4", 1], ["C5", 1], ["B4", 1, "G"], ["A4", 1], ["B4", 1], ["C5", 1, "C"], ["G4", 1], ["G4*", 1],
		["G4", 2], ["F4", 1], ["E4", 1], ["G4", 1], ["C5", 1], ["B4", 1, "G"], ["A4", 1], ["B4", 1], ["C5*", 1, "C"], ["r", 2],
		["D5", 1, "G"], ["G4", 1], ["G4", 1], ["G4", 0.5, "C"], ["A4", 0.5], ["G4", 0.5], ["A4", 0.5], ["G4*", 1],
		["D5", 1, "G"], ["G4", 1], ["G4", 1], ["G4", 0.5, "C"], ["A4", 0.5], ["G4", 0.5], ["A4", 0.5], ["G4", 1],
		["G4", 2], ["F4", 1], ["E4", 1], ["G4", 1], ["C5", 1], ["B4", 1, "G"], ["A4", 1], ["B4", 1], ["C5*", 3, "C"],
	]},
	# After https://cs.wikisource.org/wiki/Prostonárodní_české_písně_a_říkadla/Vyvolená_milá
	# (Erben), whose words are "Šly panenky silnicí"; down a fifth from D.
	{name = "Šly panenky silnicí", category = "Czech folk songs", difficulty = 2, key = "G", meter = 2, notes = [
		["G4", 0.5, "G"], ["G4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["E4", 0.5, "C"], ["D4", 0.5], ["G4", 1, "G"],
		["G4", 0.5], ["F#4", 0.5, "D"], ["A4", 1], ["A4", 0.5], ["G4", 0.5], ["B4*", 1, "G"],
		["G4", 0.5], ["G4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["E4", 0.5, "C"], ["D4", 0.5], ["G4", 1, "G"],
		["G4", 0.5], ["F#4", 0.5, "D"], ["A4", 1], ["G4*", 1, "G"], ["r", 1],
		["D4", 0.5, "D"], ["D4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["C5", 0.5], ["B4", 0.5], ["G4", 1, "G"],
		["B4", 0.5], ["A4", 0.5, "D"], ["F#4", 1], ["C5", 0.5], ["B4", 0.5], ["G4*", 1, "G"],
		["D4", 0.5, "D"], ["D4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["C5", 0.5], ["B4", 0.5], ["G4", 1, "G"],
		["B4", 0.5], ["A4", 0.5, "D"], ["D4", 0.5], ["F#4", 0.5], ["G4*", 1, "G"], ["r", 1],
	]},
	# After https://cs.wikisource.org/wiki/Náš_poklad/Andulko_šafářova; down a tone from D. The
	# singer's empty bars between phrases are left out. Rated 3, not 2: an octave, with leaps
	# of a sixth and an octave.
	{name = "Andulka Šafářova", category = "Czech folk songs", difficulty = 3, meter = 3, notes = [
		["E4", 1, "C"], ["E4", 1], ["E4", 1], ["F4", 1, "G"], ["E4", 1], ["F4", 1], ["G4", 2, "C"], ["E5", 1], ["C5", 2], ["G4", 1],
		["A4", 1, "G"], ["G4", 1], ["F4", 1], ["E4*", 2, "C"], ["r", 1],
		["E4", 1], ["E4", 1], ["E4", 1], ["F4", 1, "G"], ["E4", 1], ["F4", 1], ["G4", 2, "C"], ["E5", 1], ["C5", 2], ["G4", 1],
		["A4", 1, "G"], ["G4", 1], ["F4", 1], ["E4*", 2, "C"], ["r", 1],
		["C5", 2, "G"], ["B4", 1], ["F4", 3], ["A4", 2], ["G4", 1], ["E4*", 3, "C"],
		["C5", 2, "G"], ["B4", 1], ["F4", 3], ["A4", 2], ["G4", 1], ["E4*", 3, "C"],
		["E4", 1], ["E4", 1], ["E4", 1], ["F4", 1, "G"], ["E4", 1], ["F4", 1], ["E4", 2, "C"], ["E5", 1], ["C5", 2], ["G4", 1],
		["A4", 1, "G"], ["G4", 1], ["F4", 1], ["E4*", 3, "C"],
	]},
	# After https://cs.wikisource.org/wiki/České_nápěvy (Wünsch, 1922), "Kdybys měla"; down a
	# fourth from G, so that it sits between C#4 and B4.
	{name = "Kdybys měla, má panenko", category = "Czech folk songs", difficulty = 2, key = "D", meter = 2, notes = [
		["A4", 0.5, "D"], ["A4", 0.5], ["A4", 0.5], ["G4", 0.5], ["F#4", 0.5], ["F#4", 0.5], ["F#4", 0.5], ["E4", 0.5],
		["D4", 0.5], ["D4", 0.5], ["D4", 0.5], ["r", 0.5], ["D4", 0.5], ["D4", 0.5], ["D4*", 0.5], ["r", 0.5],
		["B4", 0.5, "G"], ["B4", 0.5], ["B4", 0.5], ["A4", 0.5], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5], ["F#4", 0.5],
		["E4", 0.5, "A"], ["E4", 0.5], ["E4", 0.5], ["r", 0.5], ["E4", 0.5], ["E4", 0.5], ["E4*", 0.5], ["r", 0.5],
		["F#4", 0.5, "D"], ["E4", 0.5], ["F#4", 1], ["D4", 2], ["G4", 0.5, "G"], ["F#4", 0.5], ["G4", 1], ["E4*", 2, "A"],
		["F#4", 0.5, "D"], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["B4", 0.5, "Em"], ["G4", 0.5], ["E4", 0.5, "A"], ["C#4", 0.5], ["D4*", 2, "D"],
	]},
	# After the score the user sent (in D, 6/8, three beats a bar): its treble clef and chords,
	# the A7 as A, the H7 as B. The repeat written out, its second ending's last bar filled with
	# a rest. The two A3 pickups ("Te-", "od") are below the computer keys.
	{name = "Teče voda, teče", category = "Czech folk songs", difficulty = 3, key = "D", meter = 3, pickup = 0.5, notes = [
		["A3", 0.5],
		["F#4", 1, "D"], ["F#4", 0.5], ["E4", 0.5, "A"], ["D4", 0.5], ["E4", 0.5],
		["D4*", 2, "D"], ["r", 0.5], ["A3", 0.5],
		["G4", 1, "G"], ["G4", 0.5], ["F#4", 0.5, "D"], ["E4", 0.5], ["F#4", 0.5],
		["E4*", 2, "A"], ["r", 1],
		["F#4", 0.5, "D"], ["G4", 0.5], ["A4", 0.5], ["A4", 0.5, "B"], ["B4", 0.5], ["A4", 0.5],
		["A4", 0.5, "Em"], ["G4", 0.5], ["F#4", 0.5], ["E4", 1, "A"], ["A4", 0.25], ["G4", 0.25],
		["F#4", 1, "D"], ["F#4", 0.5], ["E4", 0.5, "A"], ["D4", 0.5], ["E4", 0.5],
		["D4*", 3, "D"],
		["F#4", 0.5], ["G4", 0.5], ["A4", 0.5], ["A4", 0.5, "B"], ["B4", 0.5], ["A4", 0.5],
		["A4", 0.5, "Em"], ["G4", 0.5], ["F#4", 0.5], ["E4", 1, "A"], ["A4", 0.25], ["G4", 0.25],
		["F#4", 1, "D"], ["F#4", 0.5], ["E4", 0.5, "A"], ["D4", 0.5], ["E4", 0.5],
		["D4*", 2, "D"], ["r", 1],
	]},
	# After https://cs.wikisource.org/wiki/Náš_poklad/Já_mám_koně,_vrany_koně (the same tune in
	# Naše písně); down a tone from G.
	{name = "Já mám koně, vraný koně", category = "Czech folk songs", difficulty = 3, key = "F", meter = 2, notes = [
		["F4", 0.5, "F"], ["F4", 0.5], ["E4", 0.5], ["C4", 0.5], ["F4", 0.5], ["F4", 0.5], ["E4", 0.5], ["C4", 0.5],
		["D4", 0.5, "Bb"], ["D4", 0.5], ["E4", 0.5, "C"], ["E4", 0.5], ["F4*", 1, "F"], ["r", 1],
		["F4", 0.5], ["F4", 0.5], ["E4", 0.5], ["C4", 0.5], ["F4", 0.5], ["F4", 0.5], ["E4", 0.5], ["C4", 0.5],
		["D4", 0.5, "Bb"], ["D4", 0.5], ["E4", 0.5, "C"], ["E4", 0.5], ["F4*", 1, "F"], ["r", 1],
		["F4", 0.5], ["A4", 0.5], ["A4", 0.5], ["C5", 0.5], ["C5", 0.5, "C"], ["Bb4", 0.5], ["G4", 1],
		["F4", 0.5, "F"], ["A4", 0.5], ["A4", 0.5], ["C5", 0.5], ["C5", 0.5, "C"], ["Bb4", 0.5], ["G4*", 1],
		["F4", 0.5, "F"], ["F4", 0.5], ["E4", 0.5], ["C4", 0.5], ["F4", 0.5], ["F4", 0.5], ["E4", 0.5], ["C4", 0.5],
		["D4", 0.5, "Bb"], ["D4", 0.5], ["E4", 0.5, "C"], ["E4", 0.5], ["F4*", 2, "F"],
	]},
	# After https://cs.wikisource.org/wiki/České_nápěvy (Wünsch, 1922), "Černé oči"; down a major
	# third from A. Sung twice, for the second verse ("Ráno, ráno, raníčko").
	{name = "Černé oči, jděte spát", category = "Czech folk songs", difficulty = 3, key = "F", meter = 2, notes = [
		["F4", 0.5, "F"], ["C4", 0.5], ["F4", 0.5], ["G4", 0.5], ["A4", 1], ["G4", 1, "C"], ["F4*", 1, "F"], ["r", 1],
		["A4", 0.5], ["G4", 0.5], ["A4", 0.5], ["Bb4", 0.5], ["C5", 1], ["Bb4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5], ["Bb4", 1], ["A4", 0.5], ["G4*", 0.5],
		["F4", 0.5, "F"], ["C4", 0.5], ["F4", 0.5], ["G4", 0.5], ["A4", 1], ["G4", 1, "C"], ["F4*", 1, "F"], ["r", 1],
		["F4", 0.5], ["C4", 0.5], ["F4", 0.5], ["G4", 0.5], ["A4", 1], ["G4", 1, "C"], ["F4", 1, "F"], ["r", 1],
		["A4", 0.5], ["G4", 0.5], ["A4", 0.5], ["Bb4", 0.5], ["C5", 1], ["Bb4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5], ["Bb4", 1], ["A4", 0.5], ["G4*", 0.5],
		["F4", 0.5, "F"], ["C4", 0.5], ["F4", 0.5], ["G4", 0.5], ["A4", 1], ["G4", 1, "C"], ["F4*", 2, "F"],
	]},
	# After https://cs.wikisource.org/wiki/Moravské_nápěvy (Wünsch, 1922), "Zahučaly hory"; a
	# minor third down from C minor. The fermatas are not held longer; the last bar, in 3/2,
	# is written as two bars of 4/4 and a held A.
	{name = "Zahučaly hory", category = "Czech folk songs", difficulty = 3, key = "Am", notes = [
		["A4", 2, "Am"], ["E4", 2], ["A4", 1], ["G#4", 1], ["A4", 1], ["B4", 1],
		["C5", 1], ["C5", 1], ["B4", 1], ["A4", 1], ["G#4", 2, "E"], ["E4*", 2],
		["E4", 1, "C"], ["F4", 1], ["G4", 2], ["G4", 1], ["A4", 1], ["G4", 2],
		["G4", 1, "G"], ["F4", 1], ["E4", 1], ["D4", 1], ["E4", 2, "C"], ["C4*", 2],
		["C5", 1, "Am"], ["C5", 0.5], ["B4", 0.5], ["A4", 2], ["B4", 2, "E"], ["G#4", 2], ["A4*", 4, "Am"],
	]},
	# After https://cs.wikisource.org/wiki/Prácheňský_zpěvník/Pade,_pade,_pade_rosička: a South
	# Bohemian version, without the "ej", which may not be the Moravian one sung most today. A
	# minor third down from G minor; one B3. The last two lines twice, as written.
	{name = "Ej, padá, padá rosička", category = "Czech folk songs", difficulty = 3, key = "Em", notes = [
		["E4", 0.5, "Em"], ["E4", 0.5], ["E4", 0.5], ["F#4", 0.5], ["G4", 1], ["A4", 1],
		["G4", 1], ["F#4", 1, "B"], ["E4*", 1, "Em"], ["r", 1],
		["G4", 1, "G"], ["G4", 0.5], ["A4", 0.5], ["B4", 1], ["C5", 1],
		["B4", 1], ["A4", 1, "D"], ["G4*", 1, "G"], ["r", 1],
		["B4", 1], ["B4", 0.5], ["C5", 0.5], ["B4", 1], ["A4", 1],
		["B4", 1, "Em"], ["G4", 0.5], ["F#4", 0.5], ["E4", 1], ["B3", 1],
		["E4", 1], ["E4", 0.5], ["F#4", 0.5], ["G4", 1], ["A4", 1],
		["G4", 1], ["F#4", 1, "B"], ["E4*", 1, "Em"], ["r", 1],
		["B4", 1, "G"], ["B4", 0.5], ["C5", 0.5], ["B4", 1], ["A4", 1],
		["B4", 1, "Em"], ["G4", 0.5], ["F#4", 0.5], ["E4", 1], ["B3", 1],
		["E4", 1], ["E4", 0.5], ["F#4", 0.5], ["G4", 1], ["A4", 1],
		["G4", 1], ["F#4", 1, "B"], ["E4*", 2, "Em"],
	]},
	# After https://cs.wikisource.org/wiki/Náš_poklad/Ach,_synku! (the same tune in Kuba's
	# Slovanstvo ve svých zpěvech); in C, a major third up from A-flat. Rated 2, not 3: steps
	# within six notes.
	{name = "Ach synku, synku", category = "Czech folk songs", difficulty = 2, meter = 3, notes = [
		["C4", 1, "C"], ["C4", 1], ["C4", 1], ["C4", 0.5], ["D4", 0.5], ["E4", 2],
		["F4", 0.5, "G"], ["E4", 0.5], ["D4", 2], ["C4*", 1, "C"], ["r", 2],
		["E4", 1], ["E4", 1], ["E4", 1], ["E4", 0.5], ["F4", 0.5], ["G4", 2],
		["A4", 0.5, "F"], ["G4", 0.5], ["F4", 1], ["E4*", 1, "C"],
		["D4", 1, "G"], ["D4", 1], ["D4", 1], ["D4", 0.5], ["E4", 0.5], ["F4", 2],
		["G4", 0.5], ["F4", 0.5], ["E4", 1], ["D4*", 1],
		["C4", 1, "C"], ["C4", 1], ["C4", 1], ["C4", 0.5], ["D4", 0.5], ["E4", 2],
		["F4", 0.5, "G"], ["E4", 0.5], ["D4", 2], ["C4*", 3, "C"],
	]},
	# After https://cs.wikisource.org/wiki/České_nápěvy (Wünsch, 1922), "Hořela lípa"; down a
	# fifth from G. One B3. Sung twice, for the second verse.
	{name = "Hořela lípa, hořela", category = "Czech folk songs", difficulty = 3, meter = 3, notes = [
		["G4", 1, "C"], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["F4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 1], ["r", 1],
		["F4", 1, "G"], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4*", 1], ["r", 1],
		["D4", 0.5], ["C4", 0.5], ["B3", 0.5], ["C4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5, "F"], ["G4", 0.5], ["A4", 1], ["r", 1],
		["G4", 0.5, "C"], ["C5", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["D4", 0.5, "G"], ["C4*", 1, "C"], ["r", 1],
		["G4", 1], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["F4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 1], ["r", 1],
		["F4", 1, "G"], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4*", 1], ["r", 1],
		["D4", 0.5], ["C4", 0.5], ["B3", 0.5], ["C4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5, "F"], ["G4", 0.5], ["A4", 1], ["r", 1],
		["G4", 0.5, "C"], ["C5", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["D4", 0.5, "G"], ["C4*", 2, "C"],
	]},
	# After https://sk.wikipedia.org/wiki/Nad_Tatrou_sa_blýska: the Slovak anthem took this folk
	# song's tune, and its words fit it line for line. Down a fourth from G minor. The folk song
	# is sung slower and freer: the rhythm here is the anthem's. Rated 2, not 3: steps within
	# six notes.
	{name = "Kopala studienku", category = "Czech folk songs", difficulty = 2, key = "Dm", meter = 2, notes = [
		["D4", 0.5, "Dm"], ["E4", 0.5], ["F4", 1], ["F4", 1], ["F4", 0.5], ["F4", 0.5],
		["E4", 0.5, "A"], ["F4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 1], ["D4*", 1, "Dm"],
		["F4", 0.5, "F"], ["G4", 0.5], ["A4", 1], ["A4", 1], ["A4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["A4", 0.5], ["Bb4", 0.5], ["A4", 0.5], ["G4", 1], ["F4*", 1, "F"],
		["A4", 0.5], ["A4", 0.5], ["A4", 1], ["G4", 1, "C"], ["G4", 0.5], ["G4", 0.5],
		["G4", 0.5], ["A4", 0.5], ["G4", 1], ["F4", 1, "F"], ["F4", 0.5], ["F4", 0.5],
		["E4", 0.5, "A"], ["F4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 1], ["D4*", 1, "Dm"],
		["A4", 0.5, "F"], ["A4", 0.5], ["A4", 1], ["G4", 1, "C"], ["G4", 0.5], ["G4", 0.5],
		["G4", 0.5], ["A4", 0.5], ["G4", 1], ["F4", 1, "F"], ["F4", 0.5], ["F4", 0.5],
		["E4", 0.5, "A"], ["F4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 1], ["D4*", 1, "Dm"],
	]},
	# A harvest song, not a carol: on song-ideas.md's carol list, moved here.
	# After Czech Wikisource, "Prácheňský zpěvník/Daleko široko", its LilyPond score (in E,
	# 2/4): down a third to C, the repeats written out. It is a harvest song, not a carol: no
	# carol of this name turned up.
	{name = "Daleko, široko", category = "Czech folk songs", difficulty = 2, meter = 2, notes = [
		["C4", 0.5, "C"], ["E4", 0.5], ["G4", 1], ["G4", 0.5], ["G4", 0.5], ["E4", 1],
		["A4", 0.5, "F"], ["A4", 0.5], ["G4", 1, "C"], ["F4", 0.5, "G"], ["E4", 0.5], ["D4*", 1],
		["C4", 0.5, "C"], ["E4", 0.5], ["G4", 1], ["G4", 0.5], ["G4", 0.5], ["E4", 1],
		["A4", 0.5, "F"], ["A4", 0.5], ["G4", 1, "C"], ["F4", 0.5, "G"], ["E4", 0.5], ["D4*", 1],
		["A4", 1, "F"], ["A4", 0.5], ["A4", 0.5], ["G4", 0.5, "C"], ["G4", 0.5], ["E4", 1],
		["D4", 1, "G"], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5, "C"], ["F4", 0.5], ["G4*", 1],
		["A4", 1, "F"], ["A4", 0.5], ["A4", 0.5], ["G4", 0.5, "C"], ["G4", 0.5], ["E4", 1],
		["D4", 1, "G"], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4*", 1, "C"],
	]},
]
