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
	# After the first violins' part at https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=301:
	# the opening ritornello, bars 1-9, and its closing E. A major seventh down from E major,
	# in F, so that it fits the keyboard; the trill before the end is left out.
	{name = "Spring (Vivaldi)", category = "Classical", difficulty = 3, key = "F", pickup = 0.5, notes = [
		["F4", 0.5],
		["A4", 0.5, "F"], ["A4", 0.5], ["A4", 0.5], ["G4", 0.25], ["F4", 0.25], ["C5", 1.5], ["C5", 0.25], ["Bb4", 0.25],
		["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G4", 0.25], ["F4", 0.25], ["C5*", 1.5], ["C5", 0.25], ["Bb4", 0.25],
		["A4", 0.5], ["Bb4", 0.25], ["C5", 0.25], ["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5, "C"], ["E4", 0.5], ["C4", 0.5], ["F4", 0.5, "F"],
		["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G4", 0.25], ["F4", 0.25], ["C5", 1.5], ["C5", 0.25], ["Bb4", 0.25],
		["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G4", 0.25], ["F4", 0.25], ["C5", 1.5], ["C5", 0.25], ["Bb4", 0.25],
		["A4", 0.5], ["Bb4", 0.25], ["C5", 0.25], ["Bb4", 0.5], ["A4", 0.5], ["G4*", 1, "C"], ["r", 0.5], ["F4", 0.5, "F"],
		["C5", 0.5], ["Bb4", 0.25], ["A4", 0.25], ["Bb4", 0.5], ["C5", 0.5], ["D5", 0.5], ["C5", 1], ["F4", 0.5],
		["C5", 0.5], ["Bb4", 0.25], ["A4", 0.25], ["Bb4", 0.5], ["C5", 0.5], ["D5", 0.5], ["C5*", 1], ["F4", 0.5],
		["D5", 0.5, "Bb"], ["C5", 1], ["Bb4", 0.5], ["A4", 0.5, "F"], ["G4", 0.25, "C"], ["F4", 0.25], ["G4", 1],
		["F4*", 4, "F"],
	]},
	# After the voice part at https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=1054: the
	# whole verse, bars 3-14, a fourth down from B-flat, in F, chords after the piano. Its
	# ornaments made to fit: each sixteenth-note triplet is two sixteenths, the dotted
	# sixteenth-and-thirty-second pairs even sixteenths, the double-dotted quarter of "Ma-" a
	# dotted one, the sextuplet after bar 6's G four sixteenths, grace notes left out.
	{name = "Ave Maria (Schubert)", category = "Classical", difficulty = 3, key = "F", notes = [
		["F4", 1.5, "F"], ["E4", 0.25], ["F4", 0.25], ["A4", 1.5], ["G4", 0.5, "C"],
		["F4", 1, "Dm"], ["r", 1], ["G4", 1, "Gm"], ["F4", 0.25, "C"], ["E4", 0.25], ["D4", 0.25], ["E4", 0.25],
		["F4*", 1, "F"], ["r", 0.5], ["A4", 0.5], ["A4", 0.75, "A"], ["G4", 0.25], ["E4", 0.25, "Dm"], ["D4", 0.25], ["A4", 0.25], ["B4", 0.25],
		["A4", 1, "Dm"], ["G#4", 0.75, "E"], ["E4", 0.25], ["G4", 0.75, "C"], ["F4", 0.25], ["G4", 0.25], ["A4", 0.25], ["Bb4", 0.25], ["G4", 0.25],
		["F4", 1.5, "Dm"], ["A4", 0.25, "G"], ["G4", 0.25], ["G4", 0.75, "C"], ["E4", 0.25], ["F#4", 0.25, "D"], ["A4", 0.25], ["C5", 0.25], ["A4", 0.25],
		["G4", 1, "C"], ["E4", 0.25, "G"], ["F4", 0.25], ["E4", 0.25], ["D4", 0.25], ["C4*", 1, "C"], ["r", 0.5], ["C4", 0.5],
		["G4", 0.75, "C"], ["G4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25], ["G4", 0.25], ["A4", 0.25], ["F4", 0.5, "F"], ["r", 0.5], ["F4", 0.5],
		["G4", 0.75, "C"], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["F4*", 1, "Dm"], ["r", 0.5], ["F4", 0.5],
		["G4", 0.75, "C"], ["G4", 0.25], ["A4", 0.25, "A"], ["A4", 0.25], ["G4", 0.25], ["A4", 0.25], ["Bb4", 0.5, "Gm"], ["Bb4", 0.5], ["r", 0.75], ["D4", 0.25],
		["G4", 0.75, "Gm"], ["G4", 0.25], ["E4", 0.25, "G"], ["F4", 0.25], ["Ab4", 0.25], ["F4", 0.25], ["G4*", 1.5, "C"], ["r", 0.5],
		["F4", 1.5, "F"], ["E4", 0.25], ["F4", 0.25], ["A4", 1.5], ["G4", 0.5, "C"],
		["F4*", 4, "F"],
	]},
	# Ständchen ("Leise flehen meine Lieder"), the tune's first half, after Liszt's
	# transcription at https://archive.org/details/b10237185, page 4, where the tune comes back
	# "quasi violoncello": an octave up here, in D minor. Each triplet is written as a
	# sixteenth, an eighth and a sixteenth. The piano's two-bar echo between the halves is left
	# out. Bar 2's chord and the second half's are mine; the scan doesn't show them clearly.
	{name = "Serenade (Schubert)", category = "Classical", difficulty = 3, key = "Dm", meter = 3, notes = [
		["A4", 0.25, "Dm"], ["Bb4", 0.5], ["A4", 0.25], ["D5", 1.5], ["A4", 0.5],
		["G4", 0.25, "Gm"], ["A4", 0.5], ["G4", 0.25], ["D5", 1.5], ["G4", 0.5],
		["A4", 1.5, "A"], ["G4", 0.5], ["G4", 0.25], ["F4", 0.5], ["E4", 0.25],
		["F4*", 2, "Dm"], ["r", 1],
		["A4", 0.25], ["Bb4", 0.5], ["A4", 0.25], ["F5", 1.5], ["A4", 0.5],
		["G4", 0.25, "C"], ["A4", 0.5], ["G4", 0.25], ["E5", 1.5], ["D5", 0.5],
		["C5", 1.5, "F"], ["Bb4", 0.5], ["Bb4", 0.25], ["A4", 0.5], ["G4", 0.25],
		["A4*", 3, "A"],
	]},
	# After the primo part at https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=1545,
	# bars 7-22, without the six bars of fanfare before them: the tune an octave down, and from
	# bar 9 here, where Schubert's run reaches the high E, two octaves down, so the run's top D
	# falls to the E below it. The first ending, in A.
	{name = "Marche militaire (Schubert)", category = "Classical", difficulty = 3, key = "D", meter = 2, notes = [
		["A4", 1, "D"], ["G4", 0.5], ["F#4", 0.5],
		["E4", 1, "A"], ["F#4", 0.5], ["E4", 0.5],
		["D4", 1, "D"], ["E4", 0.5], ["F#4", 0.5],
		["A3*", 0.75, "A"], ["B3", 0.25], ["A3", 0.5], ["r", 0.5],
		["A4", 1, "D"], ["G4", 0.5], ["F#4", 0.5],
		["B4", 1, "B"], ["A4", 0.5], ["F#4", 0.5],
		["G4", 0.5, "Em"], ["A4", 0.25], ["G4", 0.25], ["F#4", 0.5, "B"], ["G4", 0.25], ["F#4", 0.25],
		["E4", 0.25, "Em"], ["E4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25], ["B4", 0.25], ["C#5", 0.25], ["D5*", 0.25],
		["E4", 0.5, "A"], ["E4", 0.25], ["E4", 0.25], ["D4", 0.5], ["E4", 0.5],
		["F#4", 0.5, "D"], ["G4", 0.5], ["A4", 1],
		["E4", 0.5, "A"], ["F#4", 0.5], ["G4", 1],
		["F#4", 0.5, "D"], ["E4", 0.5], ["D4*", 1],
		["E4", 0.5, "A"], ["E4", 0.25], ["E4", 0.25], ["D4", 0.5], ["E4", 0.5],
		["F#4", 0.5, "D"], ["G4", 0.5], ["A4", 1],
		["G#4", 0.5, "E"], ["A4", 0.5], ["B4", 0.75], ["C#5", 0.25],
		["A4*", 2, "A"],
	]},
	# After https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=504, bars 1-8 in F. The
	# second phrase climbs to A5, above the range: from its second note to the end it is an
	# octave down here. The F held for two and a half beats is two beats and an eighth's rest.
	{name = "Träumerei (Schumann)", category = "Classical", difficulty = 3, key = "F", pickup = 1, notes = [
		["C4", 1],
		["F4", 2, "F"], ["r", 0.5], ["E4", 0.5], ["F4", 0.5], ["A4", 0.5],
		["C5", 0.5], ["F5", 0.5], ["F5", 2, "Dm"], ["E5", 0.5], ["D5", 0.5],
		["C5", 0.5, "F"], ["F5", 0.5], ["G4", 0.5, "C"], ["A4", 0.5], ["Bb4", 0.5], ["D5", 0.5], ["F4", 0.5, "F"], ["G4", 0.5],
		["A4", 0.5], ["C5", 0.5], ["G4*", 2, "C"], ["C4", 1],
		["F4", 2, "F"], ["r", 0.5], ["E4", 0.5], ["F4", 0.5], ["A4", 0.5],
		["C5", 0.5], ["A4", 0.5], ["A4", 1.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5],
		["F4", 0.5, "Dm"], ["A4", 0.5], ["D4", 0.5], ["F4", 0.5], ["E4", 1.5, "C"], ["Eb4", 0.5],
		["D4", 1, "G"], ["E4", 1], ["C4*", 2, "C"],
	]},
	# The verse ("Kanske vil der gå både Vinter og Vår"), bars 9-24 of the engraving at
	# https://commons.wikimedia.org/wiki/File:Grieg._Solveig%60s_Song_with_Ukr_translation.pdf,
	# in its A minor, chords after its piano part. The held E that ends each first line is
	# three beats here, a quarter longer than written. The "Ah" refrain is left out.
	{name = "Solveig's Song (Grieg)", category = "Classical", difficulty = 3, key = "Am", pickup = 1, notes = [
		["E4", 1, "Am"],
		["A4", 1], ["B4", 0.5], ["C5", 0.5], ["D5", 1], ["E5", 0.5, "E"], ["F5", 0.5],
		["F5", 0.5, "Am"], ["E5", 0.5], ["E5", 0.5], ["C5", 0.5], ["A4", 1], ["A4", 0.5], ["C5", 0.5],
		["C5", 0.5, "E"], ["B4", 0.5], ["B4", 0.5], ["G#4", 0.5], ["G#4", 0.25], ["E4*", 3],
		["r", 0.75], ["r", 1], ["E4", 1, "Am"],
		["A4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C5", 0.5], ["D5", 1, "G"], ["E5", 0.5], ["F5", 0.5],
		["F5", 0.5, "C"], ["E5", 0.5], ["E5", 0.5], ["C5", 0.5], ["A4", 1, "F"], ["A4", 0.5], ["C5", 0.5],
		["C5", 0.5, "G"], ["B4", 0.5], ["B4", 0.5], ["G4", 0.5], ["G4", 0.25], ["E4*", 3, "C"],
		["r", 0.75], ["r", 1], ["r", 0.5], ["E4", 0.5, "E"],
		["E4", 0.5], ["G#4", 0.5], ["B4", 0.5], ["C5", 0.5], ["A4", 1, "Am"], ["E5", 0.5], ["D#5", 0.5],
		["B4", 0.5, "E"], ["B4", 0.5], ["D5", 0.5], ["C#5", 0.5, "A"], ["A4", 1.5], ["A4", 0.5],
		["C5", 0.5, "Dm"], ["B4", 0.5], ["B4", 0.5], ["A4", 0.5], ["E5*", 1, "E"], ["r", 0.5], ["E4", 0.5],
		["E4", 0.5, "E"], ["G#4", 0.5], ["B4", 0.5], ["C5", 0.5], ["A4", 0.5, "Am"], ["E5", 0.5], ["E5", 0.5], ["D#5", 0.5],
		["B4", 0.5, "E"], ["B4", 0.5], ["D5", 0.5], ["C#5", 0.5, "A"], ["A4", 1.5], ["A4", 0.5],
		["C5", 1.5, "Am"], ["B4", 0.5, "E"], ["B4", 1.5], ["A4", 0.5],
		["A4*", 3, "Am"],
	]},
	# After the first violins' part at https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=281,
	# a fourth down from A minor, in E minor: bars 1-8, then bars 13, 15 and 16 (the second
	# ending), ending on the dominant as the section does. Left out: the grace notes, the
	# empty bar 14, and the chromatic run of bars 9-12, which would go below A3.
	{name = "Anitra's Dance (Grieg)", category = "Classical", difficulty = 3, key = "Em", meter = 3, pickup = 1, notes = [
		["B3", 1],
		["E4", 0.5, "Em"], ["D#4", 0.5], ["E4", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["B4", 0.5], ["E5", 0.5], ["B4", 1], ["A4", 0.25], ["B4", 0.25], ["A4", 0.25], ["B4", 0.25],
		["G4", 0.5], ["E5", 0.5], ["G4", 1], ["F#4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25],
		["E4*", 2], ["r", 1],
		["E4", 0.5], ["G4", 0.5], ["E4", 1], ["D4", 0.25], ["E4", 0.25], ["D4", 0.25], ["E4", 0.25],
		["C#4", 0.5, "C#dim"], ["G4", 0.5], ["C#4", 2],
		["C4", 0.5, "C"], ["G4", 0.5], ["C4", 1], ["B3", 0.25], ["C4", 0.25], ["B3", 0.25], ["C4", 0.25],
		["A#3", 0.5, "F#"], ["F#4", 0.5], ["A#3*", 2],
		["B3", 1, "B"], ["r", 2],
		["B3", 0.5], ["C#4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F#4", 1],
		["B4*", 2],
	]},
	# The violin's tune, bars 3-18 with the second ending, read from the Schott edition at
	# https://commons.wikimedia.org/wiki/File:Salut_d%27amour_-_op._12_-_E._Elgar_;_(Violine_und_Klavier)_-_bpt6k323436f_(3_of_8).jpg,
	# a sixth down from E major, in G. Check by ear: bar 9's low note (E, or D as in bar 1)
	# and bar 13's dotted rhythm are read from a blurred scan; the double sharp of bar 8 is
	# written A#. Chords after the piano, the less clear ones mine.
	{name = "Salut d'amour (Elgar)", category = "Classical", difficulty = 3, key = "G", meter = 2, notes = [
		["B4", 1.5, "G"], ["D4", 0.25], ["B4", 0.25],
		["A4", 0.5], ["G4", 0.5], ["F#4", 0.5], ["G4", 0.5],
		["C5", 1, "C"], ["C5", 1],
		["C5", 1, "D"], ["D4*", 0.5], ["r", 0.5],
		["B4", 1, "G"], ["D#4", 0.5], ["B4", 0.5],
		["A4", 0.5, "Em"], ["G4", 0.5], ["F#4", 0.5], ["G4", 0.5],
		["A4", 1, "A"], ["A4*", 1],
		["A4", 1.5, "D"], ["A#4", 0.5],
		["B4", 1, "G"], ["E4", 0.5], ["B4", 0.5],
		["A4", 0.5, "Em"], ["G4", 0.5], ["F#4", 0.5], ["G4", 0.5],
		["E5", 1, "C"], ["E5*", 1],
		["E5", 1.5], ["D5", 0.25], ["C5", 0.25],
		["B4", 1.5, "G"], ["A4", 0.25], ["G4", 0.25],
		["E4", 1, "D"], ["F#4", 1],
		["G4*", 4, "G"],
	]},
	# The hymn tune Thaxted (I Vow to Thee, My Country), its whole verse, after Holst's own
	# setting at https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=527, chords after its
	# bass.
	{name = "Jupiter (Holst)", category = "Classical", difficulty = 3, meter = 3, pickup = 1, notes = [
		["E4", 0.5, "C"], ["G4", 0.5],
		["A4", 1.5, "F"], ["C5", 0.5], ["B4", 0.75, "G"], ["G4", 0.25],
		["C5", 0.5, "C"], ["D5", 0.5], ["C5", 1], ["B4", 1],
		["A4", 0.5, "F"], ["B4", 0.5], ["A4", 1], ["G4", 1, "G"],
		["E4*", 2, "Am"], ["E4", 0.5], ["G4", 0.5],
		["A4", 1.5, "F"], ["C5", 0.5], ["B4", 0.75, "G"], ["G4", 0.25],
		["C5", 0.5, "C"], ["D5", 0.5], ["E5", 1], ["E5", 1],
		["E5", 0.5, "F"], ["D5", 0.5], ["C5", 1], ["D5", 1],
		["C5*", 2, "C"], ["G4", 0.5], ["E4", 0.5],
		["D4", 1.5, "G"], ["D4", 0.5], ["C4", 0.5, "Am"], ["E4", 0.5],
		["D4", 1, "G"], ["G4", 1], ["G4", 0.5, "C"], ["E4", 0.5],
		["D4", 1.5, "G"], ["D4", 0.5], ["E4", 0.5, "C"], ["G4", 0.5],
		["A4*", 2, "F"], ["A4", 0.5, "Dm"], ["B4", 0.5],
		["C5", 0.75, "Am"], ["C5", 0.25], ["B4", 1, "G"], ["A4", 1, "F"],
		["G4", 1, "C"], ["C5", 1, "F"], ["E4", 1, "C"],
		["D4", 0.5, "Dm"], ["C4", 0.5], ["D4", 1], ["E4", 1, "Am"],
		["G4*", 2, "G"], ["E4", 0.5, "Am"], ["G4", 0.5],
		["A4", 1.5, "F"], ["C5", 0.5], ["B4", 0.75, "G"], ["G4", 0.25],
		["C5", 0.5, "C"], ["D5", 0.5], ["C5", 1], ["B4", 1],
		["A4", 0.5, "F"], ["B4", 0.5], ["A4", 1], ["G4", 1, "G"],
		["E4*", 2, "Am"], ["E4", 0.5], ["G4", 0.5],
		["A4", 1.5, "F"], ["C5", 0.5], ["B4", 0.75, "G"], ["G4", 0.25],
		["C5", 0.5, "C"], ["D5", 0.5], ["E5", 1], ["E5", 1],
		["E5", 0.5, "F"], ["D5", 0.5], ["C5", 1], ["D5", 1],
		["C5*", 2, "C"],
	]},
	# After https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=475, the first Promenade's
	# bars 1-6, the top line, in its own B-flat. Its bars alternate 5/4 and 6/4: "bars" places
	# them, and meter = 11, a 5/4 and a 6/4 bar together, only lets the check count whole pairs.
	{name = "Promenade (Mussorgsky)", category = "Classical", difficulty = 3, key = "Bb", meter = 11, bars = [5, 11, 16, 22, 27], notes = [
		["G4", 1, "Gm"], ["F4", 1, "F"], ["Bb4", 1, "Bb"], ["C5", 0.5], ["F5", 0.5], ["D5", 1],
		["C5", 0.5], ["F5", 0.5], ["D5", 1], ["Bb4", 1, "Gm"], ["C5", 1, "C"], ["G4", 1], ["F4*", 1, "F"],
		["G4", 1, "Gm"], ["F4", 1, "F"], ["Bb4", 1, "Bb"], ["C5", 0.5], ["F5", 0.5], ["D5", 1],
		["C5", 0.5], ["F5", 0.5], ["D5", 1], ["Bb4", 1, "Gm"], ["C5", 1, "C"], ["G4", 1], ["F4*", 1, "F"],
		["F4", 1, "Bb"], ["G4", 1, "Gm"], ["D4", 1], ["F4", 0.5, "F"], ["G4", 0.5], ["C4", 1],
		["G4", 0.5], ["A4", 0.5], ["F4", 1], ["F5", 1, "Bb"], ["D5", 1], ["C5", 0.5, "F"], ["Bb4", 0.5], ["F4*", 1],
	]},
	# The unaccompanied opening, bars 1-4, after Durand's 1910 edition at
	# https://archive.org/details/lafilleauxcheveu00debu, a semitone down from G-flat, in F.
	# Only these four bars: from bar 5 the tune is in chords I couldn't read surely. The chord
	# is mine.
	{name = "The Girl with the Flaxen Hair (Debussy)", category = "Classical", difficulty = 3, key = "F", meter = 3, notes = [
		["C5", 1.5, "F"], ["A4", 0.25], ["F4", 0.25], ["D4", 0.5], ["F4", 0.25], ["A4", 0.25],
		["C5", 0.5], ["A4", 0.25], ["F4", 0.25], ["D4", 0.5], ["F4", 0.25], ["A4", 0.25], ["F4", 0.5], ["F4", 0.25], ["D4", 0.25],
		["F4", 0.5], ["E4", 0.25], ["D4", 0.25], ["C4*", 4],
		["D4", 0.5], ["F4*", 0.5],
	]},
	# After the score in https://en.wikipedia.org/wiki/D%C3%B4me_%C3%A9pais_le_jasmin: Mallika's
	# line "Sous le dôme épais où le blanc jasmin à la rose s'assemble", its four bars of 6/8,
	# a major third down from B major, in G. Only the bars the score gives: short.
	{name = "Flower Duet (Delibes)", category = "Classical", difficulty = 3, key = "G", meter = 3, pickup = 2.5, notes = [
		["G4", 0.25, "G"], ["F#4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["E4", 0.5], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.5],
		["r", 0.5], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["E4", 0.5], ["F#4", 0.25], ["G4", 0.25], ["A4*", 0.5],
		["r", 0.5], ["G4", 0.25, "C"], ["A4", 0.25], ["G4", 0.25], ["A4", 0.25], ["B4", 0.25], ["C5", 0.25], ["B4", 0.25], ["A4", 0.25], ["G4", 0.25], ["F#4", 0.25],
		["E4", 0.25, "Em"], ["F#4", 0.25], ["E4", 0.25], ["F#4", 0.25], ["E4", 0.25], ["F#4", 0.25], ["D4*", 1.5, "D"],
	]},
	# The cello's whole theme, after the CC0 LilyPond score at
	# https://commons.wikimedia.org/wiki/File:Cygne_saint_saens_fa_majeur.svg, its F major taken
	# a fifth down, to B-flat, the only key it fits: from A3 to F5, so the computer keys reach
	# little of it. Its 6/4 bars are two bars of 3 here. The low G that starts bar 3's run is
	# folded up an octave; a note held into an eighth is held to the beat, an eighth's rest
	# after it. Chords mine.
	{name = "The Swan (Saint-Saëns)", category = "Classical", difficulty = 4, key = "Bb", meter = 3, notes = [
		["Bb4", 1, "Bb"], ["A4", 1], ["D4", 1],
		["G4", 1, "Gm"], ["F4", 1], ["Bb3", 1],
		["C4", 2, "Cm"], ["r", 0.5], ["D4", 0.5],
		["Eb4", 2], ["r", 1],
		["G4", 2, "Eb"], ["A3", 0.5], ["Bb3", 0.5],
		["C4", 0.5, "F"], ["D4", 0.5], ["Eb4", 0.5], ["F4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["D5*", 3, "Bb"],
		["r", 3],
		["Bb4", 1], ["A4", 1], ["D4", 1],
		["G4", 1, "Gm"], ["F4", 1], ["Bb3", 1],
		["C#4", 2, "A"], ["r", 0.5], ["D4", 0.5],
		["E4", 2], ["r", 1],
		["A3", 1.5], ["B3", 0.5], ["C#4", 0.5], ["D4", 0.5],
		["E4", 0.5], ["F4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C#5", 0.5],
		["F5*", 3, "Dm"],
		["r", 3],
		["F5", 1, "Bb"], ["D5", 1], ["Bb4", 1],
		["G4", 1, "Gm"], ["A4", 1], ["Bb4", 1],
		["F4", 2, "F"], ["r", 0.5], ["G4", 0.5],
		["A4", 2], ["r", 1],
		["Eb5", 1, "Ab"], ["C5", 1], ["Ab4", 1],
		["F4", 1, "Fm"], ["G4", 1], ["Ab4", 1],
		["Eb4", 2, "Eb"], ["r", 0.5], ["F4", 0.5],
		["G4*", 2], ["r", 1],
		["G4", 1, "Cm"], ["C4", 1], ["D4", 1],
		["Eb4", 2, "Eb"], ["F4", 0.5], ["G4", 0.5],
		["A4", 3, "F"],
		["G4", 2, "C"], ["r", 1],
		["G4", 1], ["C4", 1], ["D4", 1],
		["E4", 2], ["F4", 0.5], ["G4", 0.5],
		["Ab4", 3, "Fm"],
		["A4", 3, "F"],
		["Bb4*", 3, "Bb"],
	]},
	# From memory, checked against the piano arrangement at
	# https://commons.wikimedia.org/wiki/File:Bach_sheet_for_beginners_jesu_joy.pdf (its fourth
	# bar, its chords, and the eighth's rest the tune starts after). The obbligato's first
	# phrase, four bars of 9/8 to the B it ends on, a tone down from G, in F, written in 6/8,
	# two of its three-note groups a bar, after a pickup.
	{name = "Jesu, Joy of Man's Desiring (Bach)", category = "Classical", difficulty = 4, key = "F", meter = 3, pickup = 2.5, notes = [
		["F4", 0.5, "F"], ["G4", 0.5], ["A4", 0.5], ["C5", 0.5], ["Bb4", 0.5],
		["Bb4", 0.5, "Bb"], ["D5", 0.5], ["C5", 0.5], ["C5", 0.5, "F"], ["F5", 0.5], ["E5", 0.5],
		["F5", 0.5, "Dm"], ["C5", 0.5], ["A4", 0.5], ["F4", 0.5], ["G4", 0.5], ["A4*", 0.5],
		["Bb4", 0.5, "Gm"], ["C5", 0.5], ["D5", 0.5], ["C5", 0.5, "F"], ["Bb4", 0.5], ["A4", 0.5],
		["G4", 0.5, "Gm"], ["A4", 0.5], ["F4", 0.5], ["E4", 0.5, "C"], ["F4", 0.5], ["G4", 0.5],
		["C4", 0.5], ["E4", 0.5], ["G4", 0.5], ["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5],
		["A4*", 3, "F"],
	]},
	# The trio's tune ("Be kind to your web-footed friends"), after
	# https://abcnotation.com/tunePage?a=trillian.mit.edu/~jc/music/abc/Contra/march/Stars_and_Stripes_Forever-D-32-3/0000,
	# in D. A note tied over a bar and the rest after it are one long note here. My chords, not
	# the ABC's: its F#7-Bm and B7 don't fit the tune's E and D natural.
	{name = "The Stars and Stripes Forever (Sousa)", category = "Classical", difficulty = 3, key = "D", pickup = 2, notes = [
		["A4", 2, "A"],
		["A4", 2, "D"], ["G4", 1], ["F#4", 1],
		["F#4", 2], ["E#4", 1], ["F#4", 1],
		["F#4*", 6], ["E#4", 1], ["F#4", 1],
		["F#4", 2], ["E#4", 1], ["F#4", 1],
		["A4", 2], ["F#4", 1], ["A4", 1],
		["G4*", 4, "A"],
		["E4", 2], ["E4", 2],
		["E4", 2], ["D#4", 1], ["E4", 1],
		["E4", 2], ["D#4", 1], ["E4", 1],
		["G4*", 6], ["F#4", 1], ["E4", 1],
		["F#4", 1, "D"], ["A4", 3],
		["B4", 2, "G"], ["B4", 2],
		["E4*", 6, "A"], ["A4", 2],
		["A4", 2, "D"], ["G4", 1], ["F#4", 1],
		["F#4", 2], ["E#4", 1], ["F#4", 1],
		["F#4*", 6], ["E#4", 1], ["F#4", 1],
		["F#4", 2], ["E#4", 1], ["F#4", 1],
		["G4", 1.5, "A"], ["F#4", 0.5], ["E4", 1], ["C#4", 1],
		["E4*", 4],
		["D4", 3, "D"], ["D4", 1],
		["D4", 2], ["C#4", 1], ["D4", 1],
		["F4", 2, "Gm"], ["E4", 1], ["D4", 1],
		["D5*", 4, "D"],
		["r", 1], ["D4", 1], ["E4", 1], ["F#4", 1],
		["A4", 1.5], ["D4", 0.5], ["E4", 1], ["F#4", 1],
		["A4", 1.5], ["A3", 0.5], ["B3", 1], ["F#4", 1],
		["E4", 4, "A"],
		["D4*", 2, "D"],
	]},
	# The third movement's theme, The Young Prince and the Young Princess, after the score in
	# https://en.wikipedia.org/wiki/Scheherazade_(Rimsky-Korsakov), its eight bars of 6/8 in G.
	# Not the solo violin's theme: its runs are sixteenth-note triplets, which the game can't
	# lay out. The grace notes are left out.
	{name = "Scheherazade (Rimsky-Korsakov)", category = "Classical", difficulty = 4, key = "G", meter = 3, pickup = 1, notes = [
		["B4", 0.5, "G"], ["C5", 0.5],
		["D5", 0.75], ["E5", 0.25], ["D5", 0.5], ["B4", 0.75], ["A4", 0.25], ["G4", 0.5],
		["B4", 2, "Em"], ["B4", 0.5], ["C5", 0.5],
		["D5", 0.5, "G"], ["E5", 0.25], ["D5", 0.25], ["E5", 0.25], ["D5", 0.25], ["C5", 0.25, "C"], ["B4", 0.25], ["C5", 0.25], ["B4", 0.25], ["A4", 0.25], ["G4", 0.25],
		["B4*", 1.5, "Em"], ["E4", 0.5], ["E4", 0.5], ["G4", 0.5],
		["A4", 0.75, "Am"], ["B4", 0.25], ["A4", 0.5], ["G4", 0.5], ["F#4", 0.5], ["G4", 0.5],
		["E4*", 1.5, "Em"], ["G4", 1], ["F#4", 0.5],
		["E4", 0.5, "C"], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5, "D"], ["G4", 0.75], ["F#4", 0.25],
		["G4*", 2, "G"],
	]},
	# After https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=1590, bars 1-8 of 12/8 as
	# sixteen bars of 6/8, a minor seventh down from E-flat, in F, chords after the left hand.
	# Left out: the trills and grace notes, and the tied sixteenth that starts the turn in bar
	# 10 here, a sixteenth's rest instead.
	{name = "Nocturne Op. 9 No. 2 (Chopin)", category = "Classical", difficulty = 4, key = "F", meter = 3, pickup = 0.5, notes = [
		["C4", 0.5],
		["A4", 2, "F"], ["G4", 0.5], ["A4", 0.5],
		["G4", 1.5], ["F4", 1], ["C4", 0.5],
		["A4", 1, "D"], ["D4", 0.5], ["D5", 1], ["A4", 0.5],
		["C5", 1.5, "Cm"], ["Bb4", 1, "Gm"], ["A4*", 0.5],
		["G4", 1.5, "C"], ["A4", 1, "A"], ["E4", 0.5],
		["F4", 1.5, "Dm"], ["D4", 1.5, "Bdim"],
		["C4", 0.5, "C"], ["E5", 0.5], ["D5", 0.5], ["C5", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["Bb4", 0.25], ["D4", 0.25], ["E4", 0.25],
		["F4*", 1.5, "F"], ["r", 1], ["C4", 0.5],
		["A4", 1.5, "F"], ["G4", 0.25], ["A4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25],
		["G4", 0.5], ["F4", 1], ["r", 0.25], ["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["F4", 0.25], ["G4", 0.25],
		["A4", 0.25, "D"], ["C#4", 0.25], ["D4", 0.25], ["Eb4", 0.25], ["D4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["Eb5", 0.25], ["D5", 0.25], ["A4", 0.25],
		["C5", 1.5, "Cm"], ["Bb4", 1, "Gm"], ["A4*", 0.5],
		["G4", 1.5, "C"], ["A4", 0.5, "A"], ["A4", 0.5], ["E4", 0.5],
		["F4", 1.5, "Dm"], ["D4", 1.5, "Bdim"],
		["C4", 0.5, "C"], ["E5", 0.5], ["D5", 0.5], ["C5", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["Bb4", 0.25], ["D4", 0.25], ["E4", 0.25],
		["F4*", 2, "F"], ["E4", 0.5], ["F4", 0.5],
	]},
	# Der Hölle Rache, its first coloratura (the staccato Cs and the arpeggios up to the high
	# F), after the Queen's part at https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=266,
	# bars 23-35 of the aria, an octave down, which fits the range exactly. Grace notes left
	# out; the chords are mine.
	{name = "Queen of the Night Aria (Mozart)", category = "Classical", difficulty = 5, key = "F", notes = [
		["F4", 1.5, "F"], ["F4", 0.5], ["G4", 1.5, "C"], ["G4", 0.5],
		["A4*", 2, "F"], ["r", 1], ["A4", 0.25], ["G4", 0.25], ["A4", 0.25], ["Bb4", 0.25],
		["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5],
		["F4*", 2, "Dm"], ["r", 1], ["F4", 0.25], ["E4", 0.25], ["F4", 0.25], ["G4", 0.25],
		["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5], ["A4", 0.5],
		["D4*", 2, "Bb"], ["r", 1], ["D4", 0.25], ["C4", 0.25], ["D4", 0.25], ["E4", 0.25],
		["F4", 0.5, "F"], ["F4", 0.5], ["F4", 0.5], ["C4", 0.5], ["G4", 0.5, "C"], ["G4", 0.5], ["G4", 0.5], ["C4", 0.5],
		["A4", 0.5, "F"], ["F4", 0.5], ["A4", 0.5], ["C5", 0.5], ["F5", 0.5], ["C5", 0.5], ["D5", 0.5, "Bb"], ["Bb4", 0.5],
		["A4", 0.5, "F"], ["F4", 0.5], ["A4", 0.5], ["C5", 0.5], ["F5", 0.5], ["C5", 0.5], ["D5", 0.5, "Bb"], ["Bb4", 0.5],
		["C5*", 1, "C"], ["r", 1], ["F4", 1.5, "F"], ["F4", 0.5],
		["G4", 2, "Gm"], ["Bb4", 2],
		["C4", 3, "C"], ["D4", 0.5], ["E4", 0.5],
		["F4*", 4, "F"],
	]},
	# The Largo's first strain, bars 5-13, after the violin part at
	# https://archive.org/details/imslp-monti-vittorio (the violin line of a 2009 arrangement
	# for violin, guitar and bass; the tune is Monti's), a tone up from D minor, in E minor.
	# Grace notes left out; a half note tied into an eighth is a half and an eighth's rest.
	# Chords mine. The fast Allegro vivace is left out: it climbs far above the range.
	{name = "Csárdás (Monti)", category = "Classical", difficulty = 3, key = "Em", pickup = 1.5, notes = [
		["B3", 0.5], ["C4", 0.5], ["B3", 0.5],
		["B4", 2, "Em"], ["r", 0.5], ["G4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["F#4", 0.5], ["C5", 2], ["r", 0.5], ["C4", 0.5],
		["C4", 0.5, "B"], ["B3", 0.5], ["D#4", 0.5], ["F#4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G4", 0.5], ["D#4", 0.5],
		["F#4", 0.5, "Em"], ["E4", 0.5], ["E4", 0.25], ["D#4", 0.25], ["E4", 0.25], ["F#4", 0.25], ["G4", 0.5], ["B3", 0.5], ["C4", 0.5], ["B3*", 0.5],
		["B4", 2, "Em"], ["r", 0.5], ["G4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["F#4", 0.5], ["C5", 2], ["r", 0.5], ["C4", 0.5],
		["C4", 0.5, "B"], ["B3", 0.5], ["E4", 0.5], ["D#4", 0.5], ["A4", 1.5], ["F#4", 0.5],
		["F#4", 0.5, "Em"], ["E4", 0.5], ["E4", 0.5], ["D#4", 0.5], ["E4*", 2],
	]},
	# From memory, check by ear: the opening chromatic descent's last two bars, then the
	# bee's theme on E and its answer a fourth up, in A minor, sixteenths in 2/4. Bars 6 and 9
	# less sure; the last A, closing it, is mine.
	{name = "Flight of the Bumblebee (Rimsky-Korsakov)", category = "Classical", difficulty = 5, key = "Am", meter = 2, notes = [
		["E5", 0.25, "E"], ["D#5", 0.25], ["D5", 0.25], ["C#5", 0.25], ["D5", 0.25], ["C#5", 0.25], ["C5", 0.25], ["B4", 0.25],
		["C5", 0.25], ["B4", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["G#4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["F4", 0.25],
		["E4", 0.25, "Am"], ["D#4", 0.25], ["D4", 0.25], ["C#4", 0.25], ["C4", 0.25], ["F4", 0.25], ["E4", 0.25], ["D#4", 0.25],
		["E4", 0.25], ["D#4", 0.25], ["D4", 0.25], ["C#4", 0.25], ["C4", 0.25], ["C#4", 0.25], ["D4", 0.25], ["D#4*", 0.25],
		["E4", 0.25], ["D#4", 0.25], ["D4", 0.25], ["C#4", 0.25], ["C4", 0.25], ["F4", 0.25], ["E4", 0.25], ["D#4", 0.25],
		["E4", 0.25, "E"], ["F4", 0.25], ["E4", 0.25], ["D#4", 0.25], ["E4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["G#4*", 0.25],
		["A4", 0.25, "Dm"], ["G#4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["F4", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["G#4", 0.25],
		["A4", 0.25], ["G#4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["F4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["G#4*", 0.25],
		["A4", 0.25], ["G#4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["F4", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["G#4", 0.25],
		["A4*", 2, "Am"],
	]},
	# After https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=483, bars 1-20 and the
	# first note of bar 21, which they lead to, a tritone down from D-flat, in G, chords after
	# the left hand. Its downbeats are mostly the tune's neighbour notes.
	{name = "Minute Waltz (Chopin)", category = "Classical", difficulty = 5, key = "G", meter = 3, notes = [
		["D4", 1, "G"], ["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5],
		["C#4", 0.5], ["D4", 0.5], ["E4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5],
		["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5],
		["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4*", 0.5],
		["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5],
		["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5],
		["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5],
		["E4", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C5", 0.5],
		["E5", 1.5, "D"], ["D5", 0.5], ["C5", 0.5], ["B4", 0.5],
		["B4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4*", 1],
		["E5", 1.5], ["D5", 0.5], ["C5", 0.5], ["B4", 0.5],
		["B4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4", 0.5], ["B4", 0.5], ["E4", 0.5],
		["C#4", 0.5, "G"], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5],
		["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5],
		["C#4", 0.5], ["D4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["C#4", 0.5], ["D4", 0.5],
		["E4", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C5", 0.5],
		["E5", 1.5, "D"], ["D5", 0.5], ["C5", 0.5], ["B4", 0.5],
		["B4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4*", 1],
		["E5", 1.5], ["D5", 0.5], ["C5", 0.5], ["B4", 0.5],
		["A4", 0.5], ["B4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4", 0.5], ["A#4", 0.5],
		["B4*", 3, "G"],
	]},
	# The first strain, after https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=23, the
	# top line of the right hand, a major third down from A-flat, in F, chords after the left
	# hand. The opening sixteenth's rest is left out, and the rest after the tie into bar 3.
	# The arpeggio of bars 7-8 climbs four octaves; here it stays in one. Bars 9-12, an
	# octave above bars 13-16 in the score, are at the height of 13-16 here.
	{name = "Maple Leaf Rag (Joplin)", category = "Classical", difficulty = 5, key = "F", meter = 2, notes = [
		["F4", 0.5, "F"], ["C5", 0.25], ["F4", 0.25], ["A4", 0.25], ["C5", 0.5], ["E4", 0.25],
		["C5", 0.25, "C"], ["E4", 0.25], ["G4", 0.25], ["C5*", 1.5],
		["F4", 0.25, "F"], ["C5", 0.25], ["F4", 0.25], ["A4", 0.25], ["C5", 0.5], ["E4", 0.25],
		["C5", 0.25, "C"], ["E4", 0.25], ["G4", 0.25], ["C5", 0.75], ["r", 0.25], ["C5", 0.25],
		["r", 0.25], ["F4", 0.25, "Db"], ["Ab4", 0.25], ["Db5", 0.25], ["r", 0.25], ["C5", 0.25, "C"], ["r", 0.25], ["C5", 0.25],
		["r", 0.25], ["F4", 0.25, "Db"], ["Ab4", 0.25], ["Db5", 0.25], ["r", 0.25], ["C5", 0.25, "C"], ["r", 0.5],
		["r", 0.25], ["F4", 0.25, "Fm"], ["Ab4", 0.25], ["F5", 0.25], ["r", 0.25], ["F4", 0.25], ["Ab4", 0.25], ["F5", 0.25],
		["r", 0.25], ["F4", 0.25], ["Ab4", 0.25], ["F5", 0.25], ["r", 0.25], ["F4", 0.25], ["Ab4", 0.25], ["F5", 0.25],
		["F5", 0.5, "Bdim"], ["F5", 0.5], ["F5", 0.5], ["F5", 0.25], ["F5", 0.5],
		["C5", 0.25, "F"], ["D5", 0.25], ["A4", 0.25], ["C5", 0.25], ["D5", 0.5], ["F4", 0.5],
		["G4", 0.25, "Db"], ["Ab4", 0.25], ["F4", 0.25], ["G4", 0.25], ["A4", 0.5, "F"], ["F4", 0.25],
		["A4", 0.25], ["F4", 0.25], ["G4", 0.5, "C"], ["F4*", 0.5, "F"], ["r", 0.25], ["F5", 0.75, "Bdim"],
		["F5", 0.5], ["F5", 0.5], ["F5", 0.25], ["F5", 0.5],
		["C5", 0.25, "F"], ["D5", 0.25], ["A4", 0.25], ["C5", 0.25], ["D5", 0.5], ["F4", 0.5],
		["G4", 0.25, "Db"], ["Ab4", 0.25], ["F4", 0.25], ["G4", 0.25], ["A4", 0.5, "F"], ["F4", 0.25],
		["A4", 0.25], ["F4", 0.25], ["G4", 0.5, "C"], ["F4*", 1, "F"],
	]},
]
