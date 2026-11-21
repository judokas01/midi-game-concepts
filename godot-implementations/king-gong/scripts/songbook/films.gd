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
	# After James Kerr's "Merry Melodies" vol. 4 (19th century), https://abcnotation.com/tunePage?a=trillian.mit.edu/~jc/music/book/Kerr/MM4-V1/0781,
	# a minor third up from Kerr's G. The waltz's first two phrases, with their leaps up the octave, then its
	# closing phrase; the phrases between are left out (too wide for the range), so the pickup into the close is
	# C, not A. Kerr strikes each arpeggio's top note again on the next downbeat; here it is held. Rated 3, not 2:
	# octave leaps and a range of more than an octave and a half.
	{name = "The Blue Danube (Strauss)", category = "From films", difficulty = 3, key = "Bb", meter = 3, pickup = 1, notes = [
		["Bb3", 1, "Bb"],
		["Bb3", 1], ["D4", 1], ["F4", 2], ["r", 1], ["F5", 1],
		["F5", 1], ["r", 1], ["D5", 1],
		["D5*", 1], ["r", 1], ["Bb3", 1],
		["Bb3", 1], ["D4", 1], ["F4", 2], ["r", 1], ["F5", 1],
		["F5", 1], ["r", 1], ["Eb5", 1, "F"],
		["Eb5*", 1], ["r", 1], ["C4", 1, "Cm"],
		["C4", 1], ["Eb4", 1], ["G4", 1],
		["G4", 4], ["E4", 1, "C"], ["F4", 1, "F"],
		["D5*", 4, "Bb"], ["Bb4", 1], ["D4", 1],
		["D4", 2], ["C4", 1, "F"],
		["G4", 2, "Cm"], ["F4", 1, "F"],
		["Bb3", 1, "Bb"], ["r", 0.5], ["Bb3", 0.5], ["Bb3*", 1],
	]},
	# The tune of Colin Hume's ABC (not his parts), https://abcnotation.com/tunePage?a=colinhume.com/ABC.txt/1220:
	# the theme of Keyboard Suite HWV 437, eight bars and their varied repeat, in Handel's D minor. In the
	# sarabande's rhythm, quarter then dotted quarter; Hume's dance version rests where the dot is.
	{name = "Sarabande (Handel)", category = "From films", difficulty = 2, key = "Dm", meter = 3, notes = [
		["F4", 1, "Dm"], ["F4", 1.5], ["G4", 0.5],
		["E4", 1, "A"], ["E4*", 2],
		["A4", 1, "F"], ["A4", 1.5], ["Bb4", 0.5],
		["G4", 1, "C"], ["G4", 1.5], ["A4", 0.5],
		["Bb4", 1, "Gm"], ["Bb4", 1.5], ["C5", 0.5],
		["A4", 1, "Dm"], ["A4", 1.5], ["A4", 0.5],
		["D5", 1, "Bb"], ["D5", 1.5], ["E5", 0.5],
		["C#5", 1, "A"], ["C#5*", 2],
		["F4", 1, "Dm"], ["F4", 1.5], ["G4", 0.5],
		["E4", 1, "A"], ["E4*", 2],
		["A4", 1, "F"], ["A4", 1.5], ["Bb4", 0.5],
		["G4", 1, "C"], ["G4", 1.5], ["A4", 0.5],
		["Bb4", 1, "Gm"], ["Bb4", 1.5], ["C5", 0.5],
		["A4", 1, "F"], ["A4", 1], ["D5", 0.5, "Bb"], ["C#5", 0.5, "A"],
		["D5", 0.5, "Gm"], ["E5", 0.5], ["F5", 1, "A"], ["E5", 0.5], ["D5", 0.5],
		["D5*", 3, "Dm"],
	]},
	# After John Chambers's ABC of Lowell Mason's hymn tune Bethany (1856),
	# http://trillian.mit.edu/~jc/music/abc/song/Nearer_My_God_To_Thee_Bethany_F.abc: the soprano line of a
	# verse, in F as there; the chords follow its four parts.
	{name = "Nearer, My God, to Thee", category = "From films", difficulty = 2, key = "F", notes = [
		["A4", 2, "F"], ["G4", 1, "C"], ["F4", 1, "Dm"],
		["F4", 1.5, "Bb"], ["D4", 0.5], ["D4", 2],
		["C4", 2, "F"], ["F4", 1], ["A4", 1],
		["G4*", 4, "C"],
		["A4", 2, "F"], ["G4", 1, "C"], ["F4", 1, "Dm"],
		["F4", 1.5, "Bb"], ["D4", 0.5], ["D4", 2],
		["C4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["G4", 1],
		["F4*", 4, "F"],
		["C5", 2], ["D5", 1, "Bb"], ["C5", 1, "F"],
		["C5", 1.5], ["A4", 0.5], ["C5*", 2],
		["C5", 2], ["D5", 1, "Bb"], ["C5", 1, "F"],
		["C5", 1.5, "C"], ["A4", 0.5, "F"], ["G4*", 2, "C"],
		["A4", 2, "F"], ["G4", 1, "C"], ["F4", 1, "F"],
		["F4", 1.5, "Bb"], ["D4", 0.5], ["D4", 2],
		["C4", 1, "F"], ["F4", 1], ["E4", 1, "C"], ["G4", 1],
		["F4*", 4, "F"],
	]},
	# After the ABC at http://trillian.mit.edu/~jc/music/abc/mirror/homepages.inf.ed.ac.uk/s0570628/Barcarolle.abc,
	# a fourth down from its G, 6/8: "Belle nuit, ô nuit d'amour" twice, then the rising answer. The chords
	# are mine: tonic, a touch of dominant, the dominant under the answer.
	{name = "Barcarolle (Offenbach)", category = "From films", difficulty = 2, meter = 3, notes = [
		["E4", 1, "C"], ["F4", 0.5], ["F4", 1], ["E4", 0.5],
		["E4", 0.5], ["D4", 0.5], ["F4", 0.5], ["F4", 1], ["E4", 0.5],
		["E4", 0.5], ["D4", 0.5, "G"], ["F4", 0.5], ["F4", 1], ["E4", 0.5],
		["E4*", 3, "C"],
		["E4", 1], ["F4", 0.5], ["F4", 1], ["E4", 0.5],
		["E4", 0.5], ["D4", 0.5], ["F4", 0.5], ["F4", 1], ["E4", 0.5],
		["E4", 0.5], ["D4", 0.5, "G"], ["F4", 0.5], ["F4", 1], ["E4", 0.5],
		["E4*", 3, "C"],
		["G4", 1, "G"], ["A4", 0.5], ["A4", 1], ["B4", 0.5],
		["B4", 1], ["C5", 0.5], ["C5", 1], ["B4", 0.5],
		["B4", 1], ["A4", 0.5], ["A4", 1], ["G4", 0.5],
		["G4*", 3],
		["G4", 1], ["A4", 0.5], ["A4", 1], ["B4", 0.5],
		["B4", 1], ["C5", 0.5], ["C5", 1], ["B4", 0.5],
		["B4", 1], ["A4", 0.5], ["A4", 1], ["G4", 0.5],
		["C5*", 3, "C"],
	]},
	# After the flute part of Mutopia's edition from the Bach-Gesellschaft,
	# https://www.mutopiaproject.org/ftp/BachJS/BWV1068/bach_air_bmv_1068/bach_air_bmv_1068.ly: the first
	# section, twice as written, a major sixth down from D. Grace notes and 32nd-note pairs are left out; a note
	# tied over the bar line ends there, with a rest for the tie. Chords mine. Rated 4, not 3: runs of
	# sixteenths and several accidentals.
	{name = "Air on the G String (Bach)", category = "From films", difficulty = 4, key = "F", notes = [
		["A4", 4, "F"],
		["r", 0.5], ["D5", 0.25, "Dm"], ["Bb4", 0.25], ["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["F4", 0.25], ["E4", 1, "C"], ["C4", 1],
		["C5", 2, "F"], ["r", 0.25], ["A4", 0.25, "D"], ["Eb4", 0.25], ["D4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["C5", 0.25], ["Bb4", 0.25],
		["Bb4*", 2, "Gm"], ["r", 0.25], ["G4", 0.25, "C"], ["D4", 0.25], ["C4", 0.25], ["F4", 0.25], ["E4", 0.25], ["Bb4", 0.25], ["A4", 0.25],
		["A4", 1.5, "F"], ["B4", 0.25, "G"], ["C5", 0.25], ["F4", 0.5, "Dm"], ["G4", 0.25], ["A4", 0.5], ["G4", 0.25], ["G4", 0.25], ["F4", 0.25],
		["E4", 0.25, "C"], ["D4", 0.5, "G"], ["F4", 0.75], ["E4", 0.25], ["D4", 0.25], ["C4*", 2, "C"],
		["A4", 4, "F"],
		["r", 0.5], ["D5", 0.25, "Dm"], ["Bb4", 0.25], ["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["F4", 0.25], ["E4", 1, "C"], ["C4", 1],
		["C5", 2, "F"], ["r", 0.25], ["A4", 0.25, "D"], ["Eb4", 0.25], ["D4", 0.25], ["G4", 0.25], ["F#4", 0.25], ["C5", 0.25], ["Bb4", 0.25],
		["Bb4*", 2, "Gm"], ["r", 0.25], ["G4", 0.25, "C"], ["D4", 0.25], ["C4", 0.25], ["F4", 0.25], ["E4", 0.25], ["Bb4", 0.25], ["A4", 0.25],
		["A4", 1.5, "F"], ["B4", 0.25, "G"], ["C5", 0.25], ["F4", 0.5, "Dm"], ["G4", 0.25], ["A4", 0.5], ["G4", 0.25], ["G4", 0.25], ["F4", 0.25],
		["E4", 0.25, "C"], ["D4", 0.5, "G"], ["F4", 0.75], ["E4", 0.25], ["D4", 0.25], ["C4*", 2, "C"],
	]},
	# The tune of Colin Hume's ABC, taken from Puccini's vocal score, https://abcnotation.com/tunePage?a=colinhume.com/ABC.txt/1021:
	# the aria from "O mio babbino caro" to "O Dio, vorrei morir", back in 6/8 (Hume halves it into 3/4) and a
	# tone down from his G, a minor third below Puccini's A-flat. Chords mine.
	{name = "O mio babbino caro (Puccini)", category = "From films", difficulty = 3, key = "F", meter = 3, notes = [
		["F4", 0.5, "F"], ["F4", 0.5], ["F4", 0.5], ["A4", 1], ["E4", 0.5],
		["D4", 1.5, "Dm"], ["C4", 1.5, "F"],
		["F4", 0.5], ["G4", 0.5], ["A4", 0.5], ["F4", 1, "Dm"], ["F5", 0.5],
		["C5", 1.5, "F"], ["C5", 1], ["A4", 0.5],
		["C5", 1, "C"], ["G4", 0.5], ["Bb4", 1, "Gm"], ["A4", 0.5],
		["F4*", 1.5, "Dm"], ["F4", 1.5],
		["F4", 0.5, "G"], ["G4", 0.5], ["A4", 0.5], ["F4", 1], ["E4", 0.5],
		["G4", 1.5, "C"], ["G4", 1], ["C4", 0.5],
		["F4", 1.5, "F"], ["A4", 0.5], ["F4", 0.5], ["E4", 0.5],
		["D4", 1.5, "Dm"], ["C4", 1.5, "F"],
		["F4", 0.5], ["G4", 0.5], ["A4", 0.5], ["F4", 1, "Dm"], ["F5", 0.5],
		["C5*", 1.5, "F"], ["C5", 1], ["D5", 0.5],
		["F5", 1, "Bb"], ["D5", 0.5], ["C5", 1, "C"], ["Bb4", 0.5],
		["C5", 1.5, "Am"], ["A4", 1.5, "Dm"],
		["F4", 0.5, "Bb"], ["G4", 0.5], ["A4", 0.5], ["F4", 1, "Gm"], ["D4", 0.5],
		["F4*", 1.5, "Dm"], ["F4", 1], ["D5", 0.5],
		["F5", 1, "Gm"], ["D5", 0.5], ["C5", 1, "C"], ["Bb4", 0.5],
		["F5", 1, "F"], ["C5", 0.5], ["Bb4", 1, "Bb"], ["A4", 0.5],
		["D5", 1, "Gm"], ["Bb4", 0.5], ["A4", 1, "C"], ["G4", 0.5],
		["F4*", 3, "F"],
	]},
	# After the ABC at http://trillian.mit.edu/~jc/music/abc/mirror/code.google.com/Liberty_Bell_1.abc: the
	# march's first strain, the Monty Python tune, in 6/8 and a fifth down from G. It ends on the dominant, as
	# the strain does before it repeats.
	{name = "The Liberty Bell (Sousa)", category = "From films", difficulty = 3, meter = 3, pickup = 0.5, notes = [
		["G4", 0.25], ["F4", 0.25],
		["E4", 1, "C"], ["E4", 0.5], ["E4", 0.5], ["Eb4", 0.5], ["E4", 0.5],
		["C5", 1], ["G4", 0.5], ["G4", 1], ["E4", 0.5],
		["F4", 1, "Dm"], ["F4", 0.5], ["F4", 1], ["G4", 0.5],
		["A4", 1.5], ["A4", 1], ["F4", 0.5],
		["D4", 1, "G"], ["D4", 0.5], ["D4", 0.5], ["C#4", 0.5], ["D4", 0.5],
		["B4", 1], ["A4", 0.5], ["A4", 1], ["F4", 0.5],
		["E4", 1, "C"], ["E4", 0.5], ["E4", 1, "G"], ["F4", 0.5],
		["G4*", 1.5, "C"], ["G4", 1, "G"], ["F4", 0.5],
		["E4", 1, "C"], ["E4", 0.5], ["E4", 0.5], ["Eb4", 0.5], ["E4", 0.5],
		["C5", 1], ["G4", 0.5], ["G4", 1], ["E4", 0.5],
		["F#4", 1, "D"], ["D5", 0.5], ["D5", 1], ["D5", 0.5],
		["D5*", 1.5], ["D5", 1], ["C5", 0.5],
		["B4", 1, "G"], ["D5", 0.5], ["D5", 0.5], ["C#5", 0.5], ["D5", 0.5],
		["A4", 1, "D"], ["D5", 0.5], ["D5", 0.5], ["C#5", 0.5], ["D5", 0.5],
		["G4", 1, "G"], ["F#4", 0.5], ["G4", 1], ["F4", 0.5],
		["G4*", 1.5], ["G4", 1],
	]},
	# From memory: the finale's galop, 2/4, in C rather than E. The rhythm (two sixteenths and an eighth,
	# three times, then the climb) and bars 1-2 are sure; check bars 4 and 8, how each phrase ends.
	{name = "William Tell Overture (Rossini)", category = "From films", difficulty = 4, meter = 2, notes = [
		["G4", 0.25, "C"], ["G4", 0.25], ["G4", 0.5], ["G4", 0.25], ["G4", 0.25], ["G4", 0.5],
		["G4", 0.25], ["G4", 0.25], ["C5", 0.5], ["D5", 0.5], ["E5*", 0.5],
		["G4", 0.25], ["G4", 0.25], ["G4", 0.5], ["G4", 0.25], ["G4", 0.25], ["G4", 0.5],
		["G4", 0.25], ["G4", 0.25], ["E5", 0.5], ["C5", 0.5], ["D5*", 0.5, "G"],
		["G4", 0.25, "C"], ["G4", 0.25], ["G4", 0.5], ["G4", 0.25], ["G4", 0.25], ["G4", 0.5],
		["G4", 0.25], ["G4", 0.25], ["C5", 0.5], ["D5", 0.5], ["E5", 0.5],
		["G4", 0.25], ["G4", 0.25], ["G4", 0.5], ["G4", 0.25], ["G4", 0.25], ["G4", 0.5],
		["G4", 0.25], ["G4", 0.25], ["E5", 0.5], ["D5", 0.5, "G"], ["C5*", 0.5, "C"],
	]},
	# From memory, unsure: the Valkyries' call, a minor third up from B minor, its 9/8 written in 6/8 (same
	# notes and lengths, bar lines elsewhere). The rhythm (dotted eighth, sixteenth, eighth, then a long note)
	# and the first call, D-A-D-F, are what I recall; the next two climbing the chord are less sure, and
	# bars 4 and 8, coming back down, are the least.
	{name = "Ride of the Valkyries (Wagner)", category = "From films", difficulty = 4, key = "Dm", meter = 3, notes = [
		["D4", 0.75, "Dm"], ["A3", 0.25], ["D4", 0.5], ["F4", 1.5],
		["F4", 0.75], ["D4", 0.25], ["F4", 0.5], ["A4", 1.5],
		["A4", 0.75, "F"], ["F4", 0.25], ["A4", 0.5], ["C5", 1.5],
		["A4", 1.5, "Dm"], ["F4*", 1.5],
		["D4", 0.75], ["A3", 0.25], ["D4", 0.5], ["F4", 1.5],
		["F4", 0.75], ["D4", 0.25], ["F4", 0.5], ["A4", 1.5],
		["A4", 0.75, "F"], ["F4", 0.25], ["A4", 0.5], ["C5", 1.5],
		["A4", 1.5, "Dm"], ["D4*", 1.5],
	]},
	# After Mutopia's edition from Fromont's 1905 print, https://www.mutopiaproject.org/ftp/DebussyC/L75/debussy_Ste_Bergamesq_Clair/debussy_Ste_Bergamesq_Clair.ly:
	# the top of the right hand's thirds, bars 1-8, a minor third down from D-flat so that it fits A3 to F5.
	# The 9/8 is written in eighths, so these 3/4 bar lines fall elsewhere than Debussy's; the opening eighth
	# rest is left out (hence the pickup), the duplets of bar 3 are evened out, two notes tied over a bar line
	# are struck again, and a closing B-flat is added.
	{name = "Clair de Lune (Debussy)", category = "From films", difficulty = 4, key = "Bb", meter = 3, pickup = 2, notes = [
		["F5", 2, "Bb"],
		["D5", 2], ["C5", 0.5, "Cdim"], ["D5", 0.5], ["C5", 3],
		["C5", 0.5, "Gm"], ["Bb4", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["D5", 1.5], ["Bb4", 1.5],
		["A4", 0.5, "Cm"], ["Bb4", 0.5], ["A4*", 3],
		["A4", 0.5], ["G4", 0.5], ["A4", 0.5], ["G4", 0.5], ["C5", 0.5], ["G4", 0.5], ["F4", 0.5, "F"], ["G4", 0.5], ["F4", 1],
		["Eb4", 0.5, "Cm"], ["F4", 0.5], ["Eb4", 1.5], ["D4*", 2, "Gm"],
		["D4", 0.5], ["Eb4", 0.5], ["D4", 0.5], ["G4", 0.5], ["D4", 0.5], ["C4", 0.5], ["D4", 0.5], ["C4", 1],
		["Bb3", 0.5], ["C4", 0.5], ["Bb3", 1.5], ["A3", 1.5, "F"],
		["Bb3*", 3, "Bb"],
	]},
	# The theme as Wikipedia's score gives it, https://en.wikipedia.org/wiki/The_Sorcerer%27s_Apprentice_(Dukas):
	# F, C, then C-D-E back up to F, its 9/8 written in 6/8 with the same notes and lengths. Four times over, as
	# the bassoons keep at it; what the piece builds from it is left out. Rated 3, not 4: one figure, even eighths.
	{name = "The Sorcerer's Apprentice (Dukas)", category = "From films", difficulty = 3, key = "Fm", meter = 3, notes = [
		["F4", 1.5, "Fm"], ["C5", 1.5],
		["C4", 0.5, "C"], ["D4", 0.5], ["E4", 0.5], ["F4*", 1.5, "Fm"],
		["F4", 1.5], ["C5", 1.5],
		["C4", 0.5, "C"], ["D4", 0.5], ["E4", 0.5], ["F4", 1.5, "Fm"],
		["F4", 1.5], ["C5", 1.5],
		["C4", 0.5, "C"], ["D4", 0.5], ["E4", 0.5], ["F4*", 1.5, "Fm"],
		["F4", 1.5], ["C5", 1.5],
		["C4", 0.5, "C"], ["D4", 0.5], ["E4", 0.5], ["F4*", 1.5, "Fm"],
	]},
	# After Wikipedia's score of the opening, https://en.wikipedia.org/wiki/Toccata_and_Fugue_in_D_minor,_BWV_565:
	# three calls, A with its mordent and the run down to D (the second answered E-F-C#-D), then the rolled
	# diminished chord, its top voice falling to D. The fermatas are held three beats; the calls an octave lower
	# there are at the first's pitch, and the 64th-note runs are sixteenths.
	{name = "Toccata and Fugue in D minor (Bach)", category = "From films", difficulty = 4, key = "Dm", notes = [
		["A4", 0.25, "Dm"], ["G4", 0.25], ["A4", 3], ["r", 0.5],
		["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["D4", 0.25], ["C#4", 0.5, "A"], ["D4*", 2, "Dm"], ["r", 0.5],
		["A4", 0.25], ["G4", 0.25], ["A4", 3], ["r", 0.5],
		["E4", 0.25], ["F4", 0.25], ["C#4", 0.5, "A"], ["D4*", 3, "Dm"],
		["A4", 0.25], ["G4", 0.25], ["A4", 3], ["r", 0.5],
		["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["D4", 0.25], ["C#4", 0.5, "A"], ["D4", 2, "Dm"], ["r", 0.5],
		["Bb3", 0.25, "C#dim"], ["C#4", 0.25], ["E4", 3], ["r", 0.5],
		["D4*", 4, "Dm"],
	]},
	# After the ABC of a Carl Fischer piccolo part, https://abcnotation.com/tunePage?a=trillian.mit.edu/~jc/music/abc/classical/Rossini/Barber_of_Seville-Overture-Db_piccolo/0000:
	# the Allegro's first theme (the Rabbit of Seville's "Welcome to my shop") and its answer, in E minor, an
	# octave below the ABC. Grace notes are left out, each 32nd-note turn is a sixteenth and a dotted eighth,
	# and a bar and a half of rest before the answer is cut. Chords mine.
	{name = "The Barber of Seville (Rossini)", category = "From films", difficulty = 4, key = "Em", pickup = 1.5, notes = [
		["B4", 0.5, "Em"], ["B4", 0.5], ["B4", 0.5],
		["C5", 0.5], ["B4", 0.5], ["r", 1.5], ["B4", 0.5], ["B4", 0.5], ["B4", 0.5],
		["C5", 0.5], ["B4", 0.5], ["r", 1.5], ["B4", 0.5], ["B4", 0.5], ["B4", 0.5],
		["C5", 0.5], ["B4", 0.5], ["r", 0.5], ["A4", 0.5, "Am"], ["A4", 0.5], ["G4", 0.5, "Em"], ["r", 0.5], ["F#4", 0.5, "B"],
		["F#4", 0.5], ["E4", 0.25, "Em"], ["r", 0.25], ["E4", 1.5], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5],
		["F#4", 0.5, "B"], ["E4", 0.5, "Em"], ["r", 0.5], ["G4", 0.5], ["F#4", 0.5, "B"], ["E4", 0.5, "Em"], ["r", 0.5], ["G4", 0.5],
		["B4", 0.5, "B"], ["F#4", 0.25], ["r", 0.25], ["F#4", 1], ["r", 0.5], ["F#4", 0.5], ["G4", 0.5], ["A4", 0.5],
		["A4", 0.5], ["G4", 0.5, "Em"], ["F#4", 0.25], ["E4", 0.75], ["D4", 0.25], ["C4", 0.75, "Am"], ["B3", 0.25], ["A#3", 0.75, "F#"],
		["B3*", 2, "B"], ["r", 0.5], ["E5", 0.5, "Am"], ["D5", 0.5], ["C5", 0.5],
		["C5", 0.25], ["B4", 0.75, "Em"], ["B4", 0.25], ["A4", 0.75, "Am"], ["A4", 0.25], ["G4", 0.75, "Em"], ["G4", 0.25], ["F#4", 0.75, "B"],
		["E4*", 4, "Em"],
	]},
	# After Mutopia's piano edition, https://www.mutopiaproject.org/ftp/MussorgskyM/nobm/nobm.ly: the brass
	# theme, twice, in D minor as there. The sixteenth-note flourishes are evened to sixteenths, the second
	# line is folded down an octave, the run that peaks on A is turned back at F, and the last bar closes on D.
	# Rated 4, not 5: no chromatics, about an octave and a third.
	{name = "Night on Bald Mountain (Mussorgsky)", category = "From films", difficulty = 4, key = "Dm", notes = [
		["A4", 0.5, "A"], ["E4", 1], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5],
		["G4", 1], ["A4", 1], ["E4", 0.5], ["F4", 0.25], ["G4", 0.25], ["A4", 0.5], ["G4", 0.25], ["F4", 0.25],
		["D4", 0.5, "Dm"], ["A4", 1], ["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5], ["A4", 0.5], ["Bb4", 0.5],
		["C5", 1, "C"], ["D5", 1, "Dm"], ["A4", 0.5], ["D5", 0.25], ["E5", 0.25], ["F5*", 0.5], ["E5", 0.25], ["D5", 0.25],
		["E5", 0.5, "A"], ["E4", 1], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5],
		["G4", 1], ["A4", 1], ["E4", 0.5], ["F4", 0.25], ["G4", 0.25], ["A4", 0.5], ["G4", 0.25], ["F4", 0.25],
		["D4", 0.5, "Dm"], ["A4", 1], ["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5], ["A4", 0.5], ["Bb4", 0.5],
		["C5", 1, "C"], ["D5", 1, "Dm"], ["A4", 1], ["D4*", 1],
	]},
	# After Wikipedia's score of the friska, https://en.wikipedia.org/wiki/Hungarian_Rhapsody_No._2: its first
	# eight bars, played twice, in 2/4 and down a tritone from F-sharp major. Each bar starts on the leading
	# note under the dominant's or the tonic's chord, so its downbeats are rarely chord notes. Rated 3, not 5:
	# this theme stays within a sixth.
	{name = "Hungarian Rhapsody No. 2 (Liszt)", category = "From films", difficulty = 3, meter = 2, notes = [
		["F#4", 0.5, "G"], ["G4", 0.5], ["F4", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["F4", 0.75], ["G4", 0.25],
		["F#4", 0.5, "C"], ["G4", 0.5], ["E4", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["E4*", 0.75], ["G4", 0.25],
		["F#4", 0.5, "G"], ["G4", 0.5], ["A4", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["A4", 0.75], ["G4", 0.25],
		["F#4", 0.5, "C"], ["G4", 0.5], ["C5", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["C5*", 1],
		["F#4", 0.5, "G"], ["G4", 0.5], ["F4", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["F4", 0.75], ["G4", 0.25],
		["F#4", 0.5, "C"], ["G4", 0.5], ["E4", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["E4*", 0.75], ["G4", 0.25],
		["F#4", 0.5, "G"], ["G4", 0.5], ["A4", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["A4", 0.75], ["G4", 0.25],
		["F#4", 0.5, "C"], ["G4", 0.5], ["C5", 0.75], ["G4", 0.25],
		["F#4", 0.5], ["G4", 0.5], ["C5*", 1],
	]},
	# Bars 1-4 after Wikipedia's score, https://en.wikipedia.org/wiki/Largo_al_factotum: "Largo al factotum
	# della città. Largo!", 6/8, with the low E of "largo" folded up an octave and held. Bars 5-8, "Presto a
	# bottega che l'alba è già. Presto!", are from memory as the same notes: check by ear. Rated 2, not 5: the
	# patter ("Figaro qua, Figaro là") is not in it.
	{name = "Largo al factotum (Rossini)", category = "From films", difficulty = 2, meter = 3, notes = [
		["C4", 2, "C"], ["D4", 0.5], ["B3", 0.5],
		["C4", 0.5], ["D4", 0.5, "G"], ["B3", 0.5], ["C4", 0.5], ["D4", 0.5], ["B3", 0.5],
		["C4", 0.5, "C"], ["r", 1], ["E4", 1.5],
		["E4*", 3],
		["C4", 2], ["D4", 0.5], ["B3", 0.5],
		["C4", 0.5], ["D4", 0.5, "G"], ["B3", 0.5], ["C4", 0.5], ["D4", 0.5], ["B3", 0.5],
		["C4", 0.5, "C"], ["r", 1], ["E4", 1.5],
		["E4*", 3],
	]},
	# After Italian Wikipedia's score of the Andante's opening, first violins,
	# https://it.wikipedia.org/wiki/Concerto_per_pianoforte_e_orchestra_n._21_(Mozart): the theme, bars 2-7, an
	# octave down, played twice as the orchestra and then the piano do. Each double-dotted quarter is a dotted
	# quarter and a sixteenth's rest, so the sixteenth after it keeps its place; the B-flat tied into an eighth
	# is a half and an eighth's rest. Chords from the bass line.
	{name = "Piano Concerto No. 21 (Mozart)", category = "From films", difficulty = 3, key = "F", notes = [
		["F4", 1.5, "F"], ["r", 0.25], ["C4", 0.25], ["A4", 1.5], ["r", 0.25], ["F4", 0.25],
		["C5", 3], ["Bb4", 0.25], ["A4", 0.25], ["G4", 0.25], ["F4", 0.25],
		["F#4", 1, "C"], ["G4*", 1], ["r", 2],
		["C4", 2], ["E4", 1], ["G4", 1],
		["Bb4", 2], ["r", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5],
		["G#4", 0.5, "F"], ["A4", 0.5], ["A4*", 1], ["r", 2],
		["F4", 1.5], ["r", 0.25], ["C4", 0.25], ["A4", 1.5], ["r", 0.25], ["F4", 0.25],
		["C5", 3], ["Bb4", 0.25], ["A4", 0.25], ["G4", 0.25], ["F4", 0.25],
		["F#4", 1, "C"], ["G4*", 1], ["r", 2],
		["C4", 2], ["E4", 1], ["G4", 1],
		["Bb4", 2], ["r", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5],
		["G#4", 0.5, "F"], ["A4", 0.5], ["A4*", 3],
	]},
	# After the public-domain image of its opening, https://commons.wikimedia.org/wiki/File:Boccherini_Minuet_anacrusis.png:
	# the minuet from the String Quintet Op. 11 No. 5, the four bars after the sixteenth-note pickup that the
	# image gives, played twice, a fifth down from A major. The grace notes are left out; what follows the
	# phrase is not in the source. Chords mine.
	{name = "Minuet (Boccherini)", category = "From films", difficulty = 3, key = "D", meter = 3, pickup = 1, notes = [
		["D5", 0.25, "D"], ["C#5", 0.25], ["D5", 0.25], ["E5", 0.25],
		["D5", 0.5], ["D4", 1], ["F#4", 1], ["A4", 0.5],
		["A4", 0.5, "A"], ["G4", 0.5], ["G4", 1], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25],
		["G4", 0.5], ["A3", 1], ["E4", 1], ["G4", 0.5],
		["G4", 0.5], ["F#4", 0.5, "D"], ["F#4*", 1], ["D5", 0.25], ["C#5", 0.25], ["D5", 0.25], ["E5", 0.25],
		["D5", 0.5], ["D4", 1], ["F#4", 1], ["A4", 0.5],
		["A4", 0.5, "A"], ["G4", 0.5], ["G4", 1], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25],
		["G4", 0.5], ["A3", 1], ["E4", 1], ["G4", 0.5],
		["G4", 0.5], ["F#4", 0.5, "D"], ["F#4*", 2],
	]},
	# After the public-domain image of the first movement's theme, https://commons.wikimedia.org/wiki/File:Rachmaninov_concerto_piano_2_theme_1mvt.png:
	# its eight bars, a major sixth up from C minor so that it sits in the computer keys. The tied B-flat is
	# one note; the closing eighth and rests are a held half note. Chords mine. Rated 2, not 4: steps within a
	# sixth, plain rhythm.
	{name = "Piano Concerto No. 2 (Rachmaninoff)", category = "From films", difficulty = 2, key = "Am", notes = [
		["A4", 3, "Am"], ["B4", 1],
		["A4", 3], ["B4", 1],
		["A4", 3], ["G4", 1],
		["F4", 1, "F"], ["G4", 1], ["E4*", 2, "E"],
		["A4", 1, "Am"], ["B4", 1], ["C5", 1], ["B4", 1],
		["C5", 3, "F"], ["B4", 1],
		["A4", 2, "Am"], ["G4", 3, "G"], ["F4", 1, "F"], ["E4*", 2, "E"],
	]},
	# After a theme summary, https://commons.wikimedia.org/wiki/File:Rhapsody_in_Blue_Themes.pdf (CC BY-SA 4.0
	# scan; the notes are Gershwin's): "main theme 2", the Andantino love theme, a semitone up from E major. Its
	# held notes are written whole there, over a chromatic inner line that is left out; F-double-sharp is
	# written G-sharp here. The two tied bars are a note of six beats and a rest. Chords mine, the augmented
	# one following that line. Rated 2, not 5: the love theme alone, slow.
	{name = "Rhapsody in Blue (Gershwin)", category = "From films", difficulty = 2, key = "F", notes = [
		["A4", 1, "F"], ["Bb4", 1], ["C5", 1], ["C4", 2],
		["D4", 1, "C"], ["E4", 1], ["F4", 1],
		["G4*", 6], ["r", 2],
		["G#4", 4, "Caug"],
		["G4", 4, "C"],
		["A4", 4, "F"],
		["F4*", 4],
	]},
	# After a theme chart, https://commons.wikimedia.org/wiki/File:Symphony_No._3_in_C_minor_(%22Organ%22)_by_Camille_Saint-Sa%C3%ABns_-_Main_Theme.png
	# (CC BY-SA 4.0; the notes are Saint-Saëns's): the finale's Maestoso theme, an octave down, its 9/4 written
	# as 3/4. The chart gives only its first phrase, so it is played twice; the opening quarter rest is left
	# out (hence the pickup). Chords mine.
	{name = "Organ Symphony (Saint-Saëns)", category = "From films", difficulty = 2, meter = 3, pickup = 2, notes = [
		["E4", 1, "C"], ["D4", 1],
		["E4", 1], ["C4", 1], ["D4", 1],
		["E4", 1], ["G4", 1], ["A4", 1, "F"],
		["G4*", 6, "C"], ["r", 4],
		["E4", 1], ["D4", 1],
		["E4", 1], ["C4", 1], ["D4", 1],
		["E4", 1], ["G4", 1], ["A4", 1, "F"],
		["G4*", 6, "C"],
	]},
	# After Imbault's Paris edition with piano or harp (Gallica), https://commons.wikimedia.org/wiki/File:Duetto_du_Mariage_de_Figaro..._Avec_accompagnement_de_piano_ou_harpe_-_bpt6k316474n_(1_of_4).jpg:
	# the Countess's lines, "Che soave zeffiretto", "Questa sera spirerà", "Sotto i pini del boschetto", then
	# the first again as it returns, in B-flat, 6/8. Susanna's echoes and the grace notes are left out. Read
	# from a worn print: check bar 9, read as six even eighths. Chords mine.
	{name = "Sull'aria (Mozart)", category = "From films", difficulty = 3, key = "Bb", meter = 3, notes = [
		["Bb4", 1.5, "Bb"], ["C5", 1.5],
		["D5", 0.5], ["Bb4", 0.5], ["F5", 0.5], ["Eb5", 0.5, "F"], ["C5", 0.5], ["A4", 0.5],
		["Bb4", 0.5, "Bb"], ["D5", 0.5], ["Bb4", 0.5], ["F4*", 1.5],
		["C5", 1.5, "F"], ["C5", 1], ["F5", 0.5],
		["F5", 0.5], ["E5", 0.5, "C"], ["D5", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5],
		["A4*", 1, "F"], ["r", 2],
		["Bb4", 1.5, "Bb"], ["Bb4", 0.5], ["C5", 0.5], ["D5", 0.5],
		["Eb5", 1.5, "Eb"], ["Eb5", 0.5], ["D5", 0.5], ["C5", 0.5],
		["Bb4", 0.5, "Bb"], ["A4", 0.5], ["Bb4", 0.5], ["C5", 0.5], ["F5", 0.5], ["Eb5", 0.5],
		["C#5", 1, "A"], ["D5*", 0.5], ["r", 1.5],
		["Bb4", 1.5, "Bb"], ["C5", 1.5],
		["D5", 0.5], ["Bb4", 0.5], ["F5", 0.5], ["Eb5", 0.5, "F"], ["C5", 0.5], ["A4", 0.5],
		["Bb4", 0.5, "Bb"], ["D5", 0.5], ["Bb4", 0.5], ["F4*", 1.5],
	]},
	# After the clarinet solo in the orchestral score (Gallica), page 4, https://commons.wikimedia.org/wiki/File:Marche_fun%C3%A8bre_d%27une_marionnette_(pour_orchestre)_-_Gounod_Ch._-_bpt6k314257x_(10_of_32).jpg:
	# the march tune, the Alfred Hitchcock theme, eight bars in 6/8 at sounding pitch, D minor (the part is
	# written in F minor; I take it for clarinet in A). Its first quarter rest is left out (hence the pickup),
	# grace notes too, and a closing D is added where the score starts the tune again. Chords mine.
	{name = "Funeral March of a Marionette (Gounod)", category = "From films", difficulty = 3, key = "Dm", meter = 3, pickup = 2, notes = [
		["D4", 0.5, "Dm"], ["D4", 0.5], ["C#4", 0.5, "A"], ["B3", 0.5],
		["C#4", 0.5], ["r", 0.5], ["D4", 0.5, "Dm"], ["E4", 0.5, "A"], ["r", 2],
		["D4", 0.5, "Dm"], ["D4", 0.5], ["C#4", 0.5, "A"], ["B3", 0.5],
		["C#4", 0.5], ["r", 0.5], ["D4", 0.5, "Dm"], ["E4*", 0.5, "A"], ["r", 2],
		["F4", 0.5, "Dm"], ["A4", 1], ["G4", 0.5],
		["F4", 0.5], ["r", 0.5], ["A4", 0.5], ["C5", 1, "F"], ["Bb4*", 0.5, "Gm"],
		["A4", 0.5, "F"], ["r", 0.5], ["C5", 0.5], ["E5", 1, "E"], ["D5", 0.5],
		["C#5", 0.5, "A"], ["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5],
		["D4*", 3, "Dm"],
	]},
]
