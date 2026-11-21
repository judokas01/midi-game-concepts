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
	# After https://www.mutopiaproject.org/ftp/BeethovenLv/O27/moonlight-guitar-duo/moonlight-guitar-duo.ly
	# (its melody part), bars 5-22: the tune from its first note to the low cadence before it
	# starts again high. A major third down from C-sharp minor, so that it sits in the computer
	# keys; the alla breve counted in quarters. Chords read off the triplets.
	{name = "Moonlight Sonata (Beethoven)", category = "Classical", difficulty = 3, key = "Am", pickup = 1, notes = [
		["E4", 0.75, "Am"], ["E4", 0.25],
		["E4", 3, "E"], ["E4", 0.75], ["E4", 0.25],
		["E4", 2, "Am"], ["F4", 2, "Dm"],
		["E4", 2, "C"], ["D4", 1, "G"], ["G4", 1],
		["C4*", 4, "C"],
		["r", 3], ["Eb4", 0.75, "Cm"], ["Eb4", 0.25],
		["Eb4", 3, "Eb"], ["Eb4", 0.75], ["Eb4", 0.25],
		["Eb4", 1, "Ab"], ["Eb4", 1], ["Eb4", 1, "Adim"], ["D4", 1, "D"],
		["D4", 2, "Gm"], ["Eb4", 1, "Adim"], ["C4", 1],
		["D4", 2, "Gm"], ["D4*", 2, "D"],
		["G4", 3, "Gm"], ["G4", 1, "G"],
		["Ab4", 3, "Ab"], ["F#4", 1, "F#dim"],
		["G4", 3, "G"], ["G4", 1],
		["Ab4", 3, "Ab"], ["F#4", 1, "F#dim"],
		["G4", 2, "G"], ["G4*", 2, "Gdim"],
		["G4", 2, "C"], ["F4", 2, "Dm"],
		["Eb4", 2, "Eb"], ["D4", 2, "Bdim"],
		["A3", 2, "Dm"], ["A3*", 2, "A"],
	]},
	# After the score in https://en.wikipedia.org/wiki/Gott_erhalte_Franz_den_Kaiser, a tone
	# down from G so that the top G is in reach. The appoggiatura in the last bar left out.
	{name = "Emperor Hymn (Haydn)", category = "Classical", difficulty = 2, key = "F", pickup = 2, notes = [
		["F4", 1.5, "F"], ["G4", 0.5],
		["A4", 1], ["G4", 1], ["Bb4", 1, "Bb"], ["A4", 1, "F"],
		["G4", 0.5, "C"], ["E4", 0.5], ["F4", 1, "F"], ["D5", 1, "Bb"], ["C5", 1, "F"],
		["Bb4", 1, "Bb"], ["A4", 1, "F"], ["G4", 1, "C"], ["A4", 0.5, "F"], ["F4", 0.5],
		["C5*", 2], ["F4", 1.5], ["G4", 0.5],
		["A4", 1], ["G4", 1], ["Bb4", 1, "Bb"], ["A4", 1, "F"],
		["G4", 0.5, "C"], ["E4", 0.5], ["F4", 1, "F"], ["D5", 1, "Bb"], ["C5", 1, "F"],
		["Bb4", 1, "Bb"], ["A4", 1, "F"], ["G4", 1, "C"], ["A4", 0.5, "F"], ["F4", 0.5],
		["C5*", 2], ["G4", 1, "C"], ["A4", 1],
		["G4", 0.5], ["E4", 0.5], ["C4", 1], ["Bb4", 1], ["A4", 1, "F"],
		["G4", 0.5, "C"], ["E4", 0.5], ["C4", 1], ["C5", 1], ["Bb4", 1],
		["A4", 1.5, "F"], ["A4", 0.5], ["B4", 1, "G"], ["B4", 0.5], ["C5", 0.5],
		["C5*", 2, "C"], ["F5", 1.5, "F"], ["E5", 0.5],
		["E5", 0.5, "C"], ["D5", 0.5], ["C5", 1, "F"], ["D5", 1.5, "Bb"], ["C5", 0.5],
		["C5", 0.5, "F"], ["Bb4", 0.5], ["A4", 1], ["G4", 1.5, "C"], ["A4", 0.25], ["Bb4", 0.25],
		["C5", 0.5, "F"], ["D5", 0.5], ["Bb4", 0.5, "C"], ["G4", 0.5], ["F4", 1, "F"], ["G4", 0.5, "C"], ["F4", 0.5],
		["F4*", 2, "F"],
	]},
	# The trio's big tune (Land of Hope and Glory), after
	# https://abcnotation.com/tunePage?a=trillian.mit.edu/~jc/music/abc/classical/Elgar_Edward/PompAndCircumstance2ndTheme_G/0000
	# with its first ending. That version plays the second half an octave up; here it stays in
	# the first half's octave. Chords from its slash chords, as triads.
	{name = "Pomp and Circumstance (Elgar)", category = "Classical", difficulty = 2, key = "G", notes = [
		["G4", 2, "G"], ["F#4", 0.5, "D"], ["G4", 0.5], ["A4", 1],
		["E4", 2, "G"], ["D4", 2],
		["C4", 2, "C"], ["B3", 0.5, "G"], ["C4", 0.5], ["D4", 1],
		["A3*", 4, "D"],
		["B3", 2, "G"], ["C#4", 0.5, "A"], ["D4", 1], ["E4", 0.5],
		["A4", 2, "D"], ["D4", 2, "Bm"],
		["G4", 2, "Em"], ["G4", 0.5, "A"], ["F#4", 1], ["E4", 0.5],
		["D4*", 4, "D"],
		["G4", 2, "G"], ["F#4", 0.5, "D"], ["G4", 0.5], ["A4", 1],
		["E4", 2, "G"], ["D4", 2],
		["C4", 2, "C"], ["B3", 0.5, "G"], ["C4", 0.5], ["D4", 1],
		["A3*", 4, "D"],
		["B3", 2, "G"], ["C#4", 0.5, "A"], ["D4", 1], ["E4", 0.5],
		["A4", 2, "D"], ["D4", 2, "G"],
		["C5", 2, "C"], ["C5", 0.5, "D"], ["B4", 1], ["A4", 0.5],
		["B4*", 4, "G"],
		["E4", 2, "C"], ["F#4", 0.5, "D"], ["G4", 1], ["A4", 0.5],
		["D4", 2, "G"], ["G4", 2, "Em"],
		["G4", 2, "Am"], ["C5", 0.5, "D"], ["B4", 1], ["A4", 0.5],
		["G4*", 4, "G"],
	]},
	# After https://www.mutopiaproject.org/ftp/ChopinFF/O28/Chop-28-4/Chop-28-4.ly: the first
	# half, bars 1-12, then the last five bars; the stormy middle, which climbs to C6, is cut.
	# Where a note is tied over the bar line it is struck again, and the last bar's triplet
	# is evened out to two sixteenths and an eighth. Triads for the sliding chords are near
	# fits only: the left hand's chords are mostly sevenths.
	{name = "Prelude in E minor (Chopin)", category = "Classical", difficulty = 3, key = "Em", pickup = 1, notes = [
		["B3", 0.75, "Em"], ["B4", 0.25],
		["B4", 3], ["C5", 1],
		["B4", 3, "B"], ["C5", 1, "D#dim"],
		["B4", 3, "Bdim"], ["C5", 1, "Dm"],
		["B4*", 3, "E"], ["Bb4", 1, "C#dim"],
		["A4", 3, "Am"], ["B4", 1],
		["A4", 3, "F#dim"], ["B4", 1, "B"],
		["A4", 3, "D"], ["B4", 0.75], ["A4", 0.25],
		["A4*", 3, "Dm"], ["G#4", 1, "G#dim"],
		["G#4", 1, "Caug"], ["A4", 0.5, "Am"], ["B4", 0.5], ["D5", 0.5], ["C5", 0.5], ["E4", 0.5], ["A4", 0.5],
		["F#4", 3, "B"], ["A4", 1, "Am"],
		["F#4", 3, "B"], ["A4", 1, "Am"],
		["G4", 0.5, "B"], ["F#4", 0.5], ["C4", 0.5], ["B3", 0.5], ["D#4", 0.5], ["F#4", 0.5], ["D5", 0.25], ["C5", 0.25], ["B4*", 0.5],
		["E4", 3, "C"], ["F#4", 1, "Am"],
		["E4", 3, "Em"], ["F#4", 1],
		["E4*", 2, "C"], ["r", 2],
		["E4", 2, "Em"], ["D#4", 2, "B"],
		["E4*", 4, "Em"],
	]},
	# After https://www.mutopiaproject.org/ftp/SchumannR/O68/schumann-op68-10-gai-laboureur/schumann-op68-10-gai-laboureur.ly:
	# the left hand's tune an octave up, all of it; in bars 9-10 and 15-16 the right hand's
	# upper line instead (B-flat A G over the left hand's G F E). Chords from the right hand.
	{name = "The Happy Farmer (Schumann)", category = "Classical", difficulty = 3, key = "F", pickup = 0.5, notes = [
		["C4", 0.5, "F"],
		["F4", 1.5], ["A4", 0.5], ["C5", 1.5], ["F4", 0.5],
		["Bb4", 0.5, "Bb"], ["D5", 0.5], ["F5", 0.5], ["D5", 0.5], ["C5", 1.5, "F"], ["A4", 0.5],
		["Bb4", 0.5, "C"], ["G4", 0.5], ["C4", 0.5], ["Bb4", 0.5], ["A4", 0.5, "F"], ["F4", 0.5], ["C4", 0.5], ["A4", 0.5],
		["E4", 1, "C"], ["D4", 1, "G"], ["C4*", 1, "C"], ["r", 0.5], ["C4", 0.5, "F"],
		["F4", 1.5], ["A4", 0.5], ["C5", 1.5], ["F4", 0.5],
		["Bb4", 0.5, "Bb"], ["D5", 0.5], ["F5", 0.5], ["D5", 0.5], ["C5", 1.5, "F"], ["A4", 0.5],
		["Bb4", 0.5, "C"], ["G4", 0.5], ["C4", 0.5], ["Bb4", 0.5], ["A4", 0.5, "F"], ["F4", 0.5], ["C4", 0.5], ["A4", 0.5],
		["E4", 1, "C"], ["D4", 1, "G"], ["C4*", 1, "C"], ["r", 0.5], ["C4", 0.5],
		["Bb4", 1.5], ["A4", 0.5], ["G4", 1.5], ["C4", 0.5],
		["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["G4", 1.5], ["C4", 0.5],
		["F4", 1.5, "F"], ["A4", 0.5], ["C5", 1.5], ["F4", 0.5],
		["Bb4", 0.5, "Bb"], ["D5", 0.5], ["F5", 0.5], ["D5", 0.5], ["C5", 1.5, "F"], ["A4", 0.5],
		["Bb4", 0.5, "C"], ["G4", 0.5], ["C4", 0.5], ["Bb4", 0.5], ["A4", 0.5, "F"], ["F4", 0.5], ["C4", 0.5], ["A4", 0.5],
		["G4", 1, "C"], ["E4", 1], ["F4*", 1, "F"], ["r", 0.5], ["C4", 0.5, "C"],
		["Bb4", 1.5], ["A4", 0.5], ["G4", 1.5], ["C4", 0.5],
		["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["G4", 1.5], ["C4", 0.5],
		["F4", 1.5, "F"], ["A4", 0.5], ["C5", 1.5], ["F4", 0.5],
		["Bb4", 0.5, "Bb"], ["D5", 0.5], ["F5", 0.5], ["D5", 0.5], ["C5", 1.5, "F"], ["A4", 0.5],
		["Bb4", 0.5, "C"], ["G4", 0.5], ["C4", 0.5], ["Bb4", 0.5], ["A4", 0.5, "F"], ["F4", 0.5], ["C4", 0.5], ["A4", 0.5],
		["G4", 1, "C"], ["E4", 1], ["F4*", 1, "F"], ["r", 1],
	]},
	# The main theme's first eight bars, the top line of the score in
	# https://en.wikipedia.org/wiki/Pictures_at_an_Exhibition (section 10). An octave down and
	# a tone up from E-flat, in F, so that it sits in the computer keys; alla breve counted in
	# quarters. The movement goes on; only these eight bars are in that score.
	{name = "The Great Gate of Kiev (Mussorgsky)", category = "Classical", difficulty = 2, key = "F", notes = [
		["F4", 4, "F"],
		["G4", 4, "C"],
		["A4", 2, "F"], ["F4", 1, "Dm"], ["A4", 1],
		["G4", 2, "C"], ["C4*", 2],
		["A4", 1, "F"], ["C5", 1], ["G4", 1, "C"], ["F4", 1, "Dm"],
		["E4", 2, "C"], ["C4*", 2, "F"],
		["A4", 1], ["C5", 1], ["G4", 1, "C"], ["F4", 1, "Dm"],
		["E4", 2, "C"], ["C4*", 2, "F"],
	]},
	# Wiegenlied, after the score in https://en.wikipedia.org/wiki/Wiegenlied_(Brahms),
	# a minor third down from E-flat, so that it runs from C4 to C5. The grace notes left out.
	{name = "Lullaby (Brahms)", category = "Classical", difficulty = 3, meter = 3, pickup = 1, notes = [
		["E4", 0.5, "C"], ["E4", 0.5],
		["G4", 1.5], ["E4", 0.5], ["E4", 1],
		["G4*", 1], ["r", 1], ["E4", 0.5], ["G4", 0.5],
		["C5", 1, "G"], ["B4", 1.5], ["A4", 0.5],
		["A4", 1], ["G4*", 1], ["D4", 0.5], ["E4", 0.5],
		["F4", 1], ["D4", 1], ["D4", 0.5], ["E4", 0.5],
		["F4*", 1], ["r", 1], ["D4", 0.5], ["F4", 0.5],
		["B4", 0.5], ["A4", 0.5], ["G4", 1], ["B4", 1],
		["C5*", 1, "C"], ["r", 1], ["C4", 0.5], ["C4", 0.5],
		["C5", 2, "F"], ["A4", 0.5], ["F4", 0.5],
		["G4", 2, "C"], ["E4", 0.5], ["C4", 0.5],
		["F4", 1, "F"], ["G4", 1], ["A4", 1],
		["G4*", 2, "C"], ["C4", 0.5], ["C4", 0.5],
		["C5", 2, "F"], ["A4", 0.5], ["F4", 0.5],
		["G4", 2, "C"], ["E4", 0.5], ["C4", 0.5],
		["F4", 1, "G"], ["E4", 1], ["D4", 1],
		["C4*", 2, "C"],
	]},
	# K. 545's first movement, bars 1-8, after
	# https://www.mutopiaproject.org/ftp/MozartWA/KV545/K545-1/K545-1.ly: the theme and the four
	# scale bars, a fifth down from C so that the scales fit. The trill in bar 4 is left out,
	# and the closing F is added: the score goes on to a run that would drop below A3.
	{name = "Sonata facile (Mozart)", category = "Classical", difficulty = 3, key = "F", notes = [
		["F4", 2, "F"], ["A4", 1], ["C5", 1],
		["E4", 1.5, "C"], ["F4", 0.25], ["G4", 0.25], ["F4*", 1, "F"], ["r", 1],
		["D5", 2, "Bb"], ["C5", 1, "F"], ["F5", 1],
		["C5", 1, "C"], ["Bb4", 0.5], ["A4", 0.25], ["Bb4", 0.25], ["A4*", 1, "F"], ["r", 1],
		["D4", 0.5, "Bb"], ["E4", 0.25], ["F4", 0.25], ["G4", 0.25], ["A4", 0.25], ["Bb4", 0.25], ["C5", 0.25],
		["D5", 0.25], ["C5", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["D4", 0.25],
		["C4", 0.5, "F"], ["D4", 0.25], ["E4", 0.25], ["F4", 0.25], ["G4", 0.25], ["A4", 0.25], ["Bb4", 0.25],
		["C5", 0.25], ["Bb4", 0.25], ["A4", 0.25], ["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["D4", 0.25], ["C4", 0.25],
		["Bb3", 0.5, "Gm"], ["C4", 0.25], ["D4", 0.25], ["E4", 0.25], ["F4", 0.25], ["G4", 0.25], ["A4", 0.25],
		["Bb4", 0.25], ["A4", 0.25], ["G4", 0.25], ["F4", 0.25], ["E4", 0.25, "C"], ["D4", 0.25], ["C4", 0.25], ["Bb3", 0.25],
		["A3", 0.5, "F"], ["Bb3", 0.25], ["C4", 0.25], ["D4", 0.25], ["E4", 0.25], ["F4", 0.25], ["G4", 0.25],
		["A4", 0.25], ["G4", 0.25], ["F4", 0.25], ["E4", 0.25], ["D4", 0.25], ["C4", 0.25], ["Bb3", 0.25], ["A3", 0.25],
		["F4*", 4],
	]},
	# From the notebook for Anna Magdalena (BWV Anh. 126), after
	# https://www.mutopiaproject.org/ftp/BachJS/BWVAnh126/anna-magdalena-22/anna-magdalena-22.ly:
	# the first part, played twice as its repeat says. A fourth down from D, in A, so that both
	# its high and its low bars fit; the second part, wider still, is left out.
	{name = "Musette in D", category = "Classical", difficulty = 3, key = "A", meter = 2, notes = [
		["E5", 1, "A"], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["E5", 1], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["C#4", 0.25], ["D4", 0.25], ["E4", 0.5], ["D4", 0.5], ["C#4", 0.5],
		["B3", 0.5, "E"], ["E4", 0.5], ["C#4", 0.5, "A"], ["A3*", 0.5],
		["E5", 1], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["E5", 1], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["C#4", 0.25], ["D4", 0.25], ["E4", 0.5], ["D4", 0.5], ["C#4", 0.5],
		["B3", 0.5, "E"], ["E4", 0.5], ["A3*", 1, "A"],
		["E5", 1], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["E5", 1], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["C#4", 0.25], ["D4", 0.25], ["E4", 0.5], ["D4", 0.5], ["C#4", 0.5],
		["B3", 0.5, "E"], ["E4", 0.5], ["C#4", 0.5, "A"], ["A3*", 0.5],
		["E5", 1], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["E5", 1], ["D5", 0.25], ["C#5", 0.25], ["B4", 0.25], ["A4", 0.25],
		["C#4", 0.25], ["D4", 0.25], ["E4", 0.5], ["D4", 0.5], ["C#4", 0.5],
		["B3", 0.5, "E"], ["E4", 0.5], ["A3*", 1, "A"],
	]},
	# The march's first six bars, after the score in
	# https://en.wikipedia.org/wiki/Radetzky_March, a fifth down from its C, in G. That score's
	# fourth bar is a beat short; it is filled with a rest here. The grace note left out. Only
	# these six bars are there, and the rest of the march is not written here.
	{name = "Radetzky March (Strauss)", category = "Classical", difficulty = 3, key = "G", notes = [
		["G4", 0.5, "G"], ["G4", 0.5], ["G4", 0.5], ["r", 0.5], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5], ["r", 0.5],
		["B4", 1], ["A4", 1], ["G4", 1.5], ["F#4", 0.5],
		["E4", 0.5, "A"], ["D#4", 0.5], ["E4", 0.5], ["F#4", 0.5], ["G4", 1], ["A4", 1],
		["D4*", 1, "D"], ["r", 3],
		["B4", 0.5, "G"], ["A#4", 0.5], ["B4", 0.5], ["r", 0.5], ["B4", 0.5], ["A#4", 0.5], ["B4", 0.5], ["r", 0.5],
		["B4", 0.5], ["A#4", 0.5], ["B4", 0.5], ["r", 0.5], ["A4", 0.5, "D"], ["r", 0.5], ["G4*", 0.5, "G"], ["r", 0.5],
	]},
	# The waltz's first strain (Lippen schweigen), after
	# https://abcnotation.com/tunePage?a=richardrobinson.tunebook.org.uk/static/tunebook/11639
	# with its second ending, a fourth down from F, in C. A note tied into the next bar is
	# held to its bar line and the rest of the tie is a rest.
	{name = "Merry Widow Waltz (Lehár)", category = "Classical", difficulty = 3, meter = 3, pickup = 1, notes = [
		["G4", 1, "C"],
		["G4", 2], ["E4", 1],
		["G4", 2], ["A4", 1],
		["G4*", 3],
		["r", 2], ["G4", 1],
		["G4", 2], ["E4", 1],
		["G4", 2], ["C5", 1],
		["B4*", 3, "G"],
		["r", 1], ["D5", 1], ["C5", 1],
		["B4", 2], ["A4", 1],
		["B4", 2], ["A4", 1],
		["F4*", 3],
		["r", 1], ["B4", 1], ["A4", 1],
		["A4", 2], ["G4", 1],
		["A4", 2], ["G4", 1],
		["C4*", 3, "C"],
	]},
	# The main theme, eight bars, after the organ transcription in
	# https://www.mutopiaproject.org/ftp/Mendelssohn-BartholdyF/O61/Sommernachtstraum-wedding-march/Sommernachtstraum-wedding-march.ly,
	# its top line, a fifth down from C, in F. The trills left out. Bars 1 and 5: the eighth
	# after the dotted note is taken as the tune's repeated note (E5 here); that score tops
	# its chord there with a fourth lower note.
	{name = "Wedding March (Mendelssohn)", category = "Classical", difficulty = 3, key = "F", notes = [
		["F5", 2, "F"], ["E5", 1.5, "E"], ["E5", 0.5],
		["D5", 1], ["C5", 1, "Am"], ["Bb4", 1, "Gm"], ["G4", 1],
		["F4", 2, "F"], ["G4", 1, "C"], ["C4", 0.75], ["G4", 0.25],
		["A4*", 1, "F"], ["r", 1.5], ["F4", 0.5], ["A4", 0.5], ["C5", 0.5],
		["F5", 2], ["E5", 1.5, "E"], ["E5", 0.5],
		["D5", 1], ["C5", 1, "Am"], ["Bb4", 1, "Gm"], ["G4", 1],
		["F4", 2, "F"], ["A4", 1], ["G4", 0.75, "C"], ["A4", 0.25],
		["G4", 2], ["F4*", 1, "F"], ["r", 1],
	]},
	# Here Comes the Bride, from memory, a fourth down from B-flat, in F. Bars 1-6 fairly
	# sure; bar 4's rhythm less so. Bars 7-8 doubtful: the climb to D5 and the way down to
	# the closing F are guessed.
	{name = "Bridal Chorus (Wagner)", category = "Classical", difficulty = 2, key = "F", notes = [
		["C4", 1, "F"], ["F4", 0.75], ["F4", 0.25], ["F4", 2],
		["C4", 1, "C"], ["G4", 0.75], ["E4", 0.25], ["F4*", 2, "F"],
		["C4", 1], ["F4", 0.75], ["Bb4", 0.25], ["Bb4", 2, "Bb"],
		["A4", 1, "F"], ["G4", 0.75], ["F4", 0.25], ["E4", 0.75, "C"], ["F4", 0.25], ["G4*", 1],
		["C4", 1, "F"], ["F4", 0.75], ["F4", 0.25], ["F4", 2],
		["C4", 1, "C"], ["G4", 0.75], ["E4", 0.25], ["F4*", 2, "F"],
		["C4", 1], ["F4", 0.75], ["Bb4", 0.25], ["D5", 2, "Bb"],
		["C5", 1, "F"], ["Bb4", 0.75], ["A4", 0.25], ["G4", 1, "C"], ["F4*", 1, "F"],
	]},
	# The refrain's first phrase only (Toréador, en garde! Toréador! Toréador!), from memory,
	# in F. Bars 1-3 fairly sure; bar 4, the second "Toréador" falling to the low C, less so.
	# The rest of the refrain is not written: I don't recall it well enough.
	{name = "Toreador Song (Bizet)", category = "Classical", difficulty = 3, key = "F", notes = [
		["C5", 1, "F"], ["D5", 0.75], ["C5", 0.25], ["A4", 2],
		["A4", 0.75], ["G4", 0.25], ["A4", 0.75], ["Bb4", 0.25], ["A4*", 2],
		["Bb4", 1, "C"], ["G4", 0.75], ["C5", 0.25], ["A4", 2, "F"],
		["F4", 1, "Dm"], ["D4", 0.75, "G"], ["G4", 0.25], ["C4*", 2, "C"],
	]},
	# The first line (L'amour est un oiseau rebelle), after the score in
	# https://en.wikipedia.org/wiki/Habanera_(aria), its rest before the first note left out so
	# that it starts on a pickup. Its triplets evened out to an eighth and two sixteenths, and
	# the turn in bar 3 left out. Bars 4-8, the second line, from memory as the same falling
	# line again: its ending may differ. The cello's D pedal is under all of it; the chords
	# are a songbook's.
	{name = "Habanera (Bizet)", category = "Classical", difficulty = 3, key = "Dm", meter = 2, pickup = 1, notes = [
		["D5", 0.5, "Dm"], ["C#5", 0.5],
		["C5", 0.5], ["C5", 0.25], ["C5", 0.25], ["B4", 0.5], ["Bb4", 0.5],
		["A4", 0.5], ["A4", 0.25], ["A4", 0.25], ["G#4", 0.5], ["G4", 0.5],
		["F4", 0.5], ["E4", 0.25], ["F4", 0.25], ["G4", 0.5], ["F4", 0.5],
		["E4*", 0.5, "A"], ["r", 0.5], ["D5", 0.5, "Dm"], ["C#5", 0.5],
		["C5", 0.5], ["C5", 0.25], ["C5", 0.25], ["B4", 0.5], ["Bb4", 0.5],
		["A4", 0.5], ["A4", 0.25], ["A4", 0.25], ["G#4", 0.5], ["G4", 0.5],
		["F4", 0.5], ["E4", 0.25], ["F4", 0.25], ["G4", 0.5], ["F4", 0.5],
		["E4*", 2, "A"],
	]},
	# After https://abcnotation.com/tunePage?a=trillian.mit.edu/~jc/music/abc/Italy/song/LaDonnaEMobile_F/0000:
	# the tune once (that version plays it twice, the same), the middle part and the
	# "e di pensier" close; the coda's long high notes left out.
	{name = "La donna è mobile (Verdi)", category = "Classical", difficulty = 3, key = "F", meter = 3, notes = [
		["A4", 1, "F"], ["A4", 1], ["A4", 1],
		["C5", 0.5, "C"], ["Bb4", 0.5], ["G4", 2],
		["G4", 1], ["G4", 1], ["G4", 1],
		["Bb4", 0.5, "F"], ["A4", 0.5], ["F4*", 2],
		["A4", 1], ["G4", 1], ["F4", 1],
		["F4", 0.5, "C"], ["E4", 0.5], ["E4", 2],
		["G4", 1], ["F4", 1], ["D4", 1],
		["D4", 0.5, "F"], ["C4", 0.5], ["C4*", 2],
		["G4", 0.5, "G"], ["A4", 0.5], ["G4", 1], ["G4", 1],
		["C5", 1, "C"], ["G4", 2],
		["A4", 0.5, "A"], ["Bb4", 0.5], ["A4", 1], ["A4", 1],
		["D5", 1, "Dm"], ["A4*", 2],
		["C5", 0.5, "C"], ["D5", 0.5], ["C5", 1], ["C5", 1],
		["D5", 2, "F"], ["C5", 1],
		["Bb4", 1, "C"], ["A4", 1], ["G4", 1],
		["F4*", 2, "F"], ["C4", 0.5], ["C5", 0.5],
		["C5", 2, "C"], ["C4", 0.5], ["C5", 0.5],
		["C5", 2, "F"], ["C4", 0.5], ["C5", 0.5],
		["Bb4", 1, "C"], ["A4", 1], ["G4", 1],
		["F4*", 3, "F"],
	]},
	# Ombra mai fu, the voice part of the CC0 MIDI file
	# https://commons.wikimedia.org/wiki/File:Largo_(Händel).mid, checked against Chrysander's
	# score (https://commons.wikimedia.org/wiki/File:Ombra_mai_fu_01.jpg and _02.jpg). The two
	# bars the voice rests after the first "fù" are cut. Held notes tied over a bar line are
	# written whole, so four notes cross a bar line: the opening C5 lasts six beats. The
	# fermata on the last high F is not held longer.
	{name = "Largo (Handel)", category = "Classical", difficulty = 3, key = "F", meter = 3, pickup = 2, notes = [
		["C5", 6, "F"],
		["A4", 1], ["G4", 0.75, "C"], ["F4", 0.25],
		["F4*", 3, "Dm"],
		["D4", 1, "Bb"], ["E4", 1, "C"], ["F4", 0.25, "F"], ["G4", 0.25], ["A4", 0.5],
		["G4", 1.5, "C"], ["F4", 0.5], ["G4", 1],
		["D5", 1, "Bb"], ["D5", 1], ["E5", 1],
		["F5", 1.5, "F"], ["C5", 0.5], ["C5", 1],
		["r", 0.5], ["D5", 0.5, "Bb"], ["Bb4", 1.5, "Gm"], ["A4", 0.5],
		["A4", 2, "F"], ["F4", 2],
		["E4", 1, "C"], ["D4", 0.75], ["C4", 0.25],
		["C4*", 3, "Am"],
		["Bb4", 1, "Bb"], ["Bb4", 1], ["A4", 1, "F"],
		["G4", 1.5, "Gm"], ["F4", 0.5], ["F4", 1, "F"],
		["E5", 1, "A"], ["E5", 1], ["D5", 1, "Dm"],
		["C#5", 1.5, "A"], ["D5", 0.25], ["C#5", 0.25], ["D5", 1, "Bb"],
		["r", 0.5], ["G4", 0.5, "Gm"], ["E4", 1.5, "A"], ["D4", 0.5],
		["D4", 1, "Bb"], ["Bb4", 3, "Gm"],
		["A4", 0.5, "F"], ["G4", 0.5], ["A4", 1],
		["G4", 0.75, "C"], ["F4", 0.25], ["G4", 1], ["D5", 2, "Bb"],
		["C5", 1, "F"], ["Bb4", 0.75, "Gm"], ["A4", 0.25],
		["A4*", 2, "F"], ["r", 1],
		["F5", 1], ["F5", 1], ["E5", 1],
		["D5", 1.5, "Bb"], ["C5", 0.5], ["C5", 1, "C"],
		["C5", 0.5, "G"], ["B4", 0.5], ["B4", 1.5], ["B4", 0.5],
		["C5", 1.5, "C"], ["D5", 0.5], ["C5", 1, "F"],
		["Bb4", 0.5, "Bb"], ["A4", 0.5], ["G4", 1.5, "C"], ["E5", 0.5],
		["F5*", 3, "Dm"],
		["G4", 0.25, "Gm"], ["A4", 0.25], ["Bb4", 0.5], ["A4", 1, "F"], ["G4", 0.75, "C"], ["F4", 0.25],
		["F4*", 3, "F"],
	]},
	# The first verse, after the melody in https://commons.wikimedia.org/wiki/File:Va,_pensiero.jpg,
	# a semitone down from F-sharp, in F, so that it runs from C4 to C5. Its triplets evened out
	# to an eighth and two sixteenths.
	{name = "Va, pensiero (Verdi)", category = "Classical", difficulty = 3, key = "F", pickup = 1, notes = [
		["A4", 0.75, "F"], ["G4", 0.25],
		["F4", 1], ["C4", 0.5], ["r", 0.25], ["C5", 0.25], ["C5", 1], ["A4", 0.75], ["F4", 0.25],
		["F4", 0.5, "C"], ["E4", 0.25], ["G4", 0.25], ["Bb4*", 1], ["r", 1], ["C4", 0.75], ["C4", 0.25],
		["C4", 1, "F"], ["F4", 0.75], ["A4", 0.25], ["A4", 0.75], ["G4", 0.25], ["A4", 0.75], ["G4", 0.25],
		["F4", 1], ["E4*", 1, "C"], ["r", 1], ["A4", 0.75, "F"], ["G4", 0.25],
		["F4", 1], ["C4", 0.75], ["C5", 0.25], ["C5", 1], ["A4", 0.75], ["F4", 0.25],
		["F4", 0.5, "C"], ["E4", 0.25], ["G4", 0.25], ["Bb4*", 1], ["r", 1], ["C4", 0.75], ["C4", 0.25],
		["C4", 0.5, "F"], ["F4", 0.25], ["A4", 0.25], ["C5", 0.5, "C"], ["Bb4", 0.25], ["G4", 0.25], ["F4", 1, "F"], ["E4", 0.5, "C"], ["A4", 0.25], ["G4", 0.25],
		["F4*", 2, "F"], ["r", 1],
	]},
	# After the melody in https://commons.wikimedia.org/wiki/File:Handel_Hornpipe_from_Water_Music.svg,
	# a fifth down from D, in G. Its 3/2 counted in halves, three beats a bar; the last
	# note, a half there, held to the bar's end. Chords mine.
	{name = "Water Music Hornpipe (Handel)", category = "Classical", difficulty = 3, key = "G", meter = 3, notes = [
		["D4", 1, "G"], ["G4", 1], ["A4", 1],
		["B4", 0.5], ["G4", 1], ["A4", 0.5], ["B4", 0.5], ["A4", 0.25], ["G4*", 0.25],
		["A4", 0.5, "D"], ["D5", 1], ["A4", 0.5], ["B4", 0.5], ["A4", 0.25], ["G4", 0.25],
		["A4", 0.5], ["D5", 1], ["A4", 0.5], ["B4", 0.5], ["A4", 0.25], ["G4", 0.25],
		["A4", 0.5], ["D4*", 1], ["D5", 0.5], ["D5", 0.5], ["D5", 0.5],
		["D5", 0.5, "C"], ["C5", 0.25], ["B4", 0.25], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5],
		["C5", 0.5, "D"], ["B4", 0.25], ["A4", 0.25], ["B4", 0.5], ["D5", 0.5], ["D5", 0.5], ["D5", 0.5],
		["D5", 0.5, "C"], ["C5", 0.25], ["B4", 0.25], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5],
		["C5", 1.5, "D"], ["D5", 0.5], ["B4", 0.5], ["A4*", 0.5],
		["B4", 0.5, "G"], ["C5", 0.5], ["A4", 1.5, "D"], ["G4", 0.5, "G"],
		["G4*", 3],
	]},
	# Libiamo, the first stanza's tune, after the piano transcription in
	# https://www.mutopiaproject.org/ftp/VerdiG/Traviata_02/Traviata_02.ly (its top line from
	# bar 23), a fourth down from B-flat, in F. Its 3/8 bars paired into 6/8, three beats a
	# bar; the grace notes left out, and the last note held to the bar's end.
	{name = "Brindisi (Verdi)", category = "Classical", difficulty = 3, key = "F", meter = 3, pickup = 0.5, notes = [
		["C4", 0.5, "F"],
		["A4", 2], ["C4", 0.5], ["A4", 0.5],
		["A4", 0.5], ["C4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4", 0.5],
		["C5", 2], ["Bb4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25], ["G4", 0.5], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25],
		["G4", 1, "F"], ["F4*", 0.5], ["C4", 0.5], ["r", 0.5], ["C4", 0.5],
		["A4", 2], ["C4", 0.5], ["A4", 0.5],
		["A4", 0.5], ["C4", 0.5], ["A4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4", 0.5],
		["C5", 2], ["Bb4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25], ["G4", 0.5], ["G4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["A4", 0.25],
		["F4*", 3, "F"],
	]},
	# The first strain, read off the top line of H. Werner's piano arrangement (St. Louis,
	# about 1875), https://commons.wikimedia.org/wiki/File:Pizzicato_polka_(IA_b10012527).pdf,
	# page 2: an octave down, in C. Its tempo changes (Vivo, Moderato) are not kept. The scan
	# is faint: bars 3-4 and 7-8 less sure.
	{name = "Pizzicato Polka (Strauss)", category = "Classical", difficulty = 3, meter = 2, pickup = 0.5, notes = [
		["C5", 0.5, "C"],
		["B4", 0.5, "G"], ["B4", 0.5], ["B4", 0.25], ["F4", 0.25], ["B4", 0.25], ["F4", 0.25],
		["E4", 0.5, "C"], ["E4", 0.5], ["E4", 0.25], ["C4", 0.25], ["E4", 0.25], ["C4*", 0.25],
		["F4", 0.5, "G"], ["B3", 0.5], ["F4", 0.5], ["B3", 0.5],
		["E4", 0.5, "C"], ["G4", 0.5], ["G4", 0.5], ["C5*", 0.5],
		["B4", 0.5, "G"], ["B4", 0.5], ["B4", 0.25], ["F4", 0.25], ["B4", 0.25], ["F4", 0.25],
		["E4", 0.5, "C"], ["E4", 0.5], ["E4", 0.25], ["C4", 0.25], ["E4", 0.25], ["C4", 0.25],
		["A4", 0.5, "F"], ["C4", 0.5], ["A4", 0.5], ["C4", 0.5],
		["C4", 0.5, "C"], ["E4", 0.5], ["C4", 0.5], ["E4*", 0.5],
	]},
	# The trumpets' march tune, after the vocal score
	# https://commons.wikimedia.org/wiki/File:Aida;_opera_in_four_acts_(IA_aidaoperainfoura00verd_0).pdf,
	# page 111 (the PDF's page 115): its ten bars, then the first five again. A minor third
	# down from A-flat, in F, so that it runs from C4 to C5. Triplets evened out to an eighth
	# and two sixteenths; notes tied into the next beat or bar end early, with a rest after.
	# Bar 2's triplet read as C, D-flat, A-flat there: less sure.
	{name = "Triumphal March (Verdi)", category = "Classical", difficulty = 3, key = "F", notes = [
		["F4", 3, "F"], ["F4", 0.5], ["C4", 0.25], ["F4", 0.25],
		["A4", 1], ["A4", 1], ["A4", 1], ["A4", 0.5], ["Bb4", 0.25], ["F4", 0.25],
		["A4", 1.5], ["G4", 0.5], ["F4*", 1], ["r", 1],
		["G4", 0.75, "C"], ["A4", 0.25], ["A4", 0.75], ["G4", 0.25], ["F4", 0.5], ["r", 0.5], ["G4", 0.75], ["A4", 0.25],
		["A4", 1], ["G4", 0.75], ["A4", 0.25], ["A4", 1], ["G4", 0.5], ["A4", 0.25], ["G4", 0.25],
		["F4*", 1, "F"], ["r", 2], ["F4", 0.5], ["C4", 0.25], ["F4", 0.25],
		["G4", 0.75, "C"], ["C4", 0.25], ["C4", 2], ["F4", 0.5], ["C4", 0.25], ["F4", 0.25],
		["G4", 0.75], ["C4", 0.25], ["C4", 2], ["F4", 0.5], ["C4", 0.25], ["F4", 0.25],
		["G4", 0.75], ["C5", 0.25], ["C5", 1.5], ["r", 0.25], ["G4", 0.25], ["G4", 1],
		["r", 0.75], ["C4", 0.25], ["C4", 0.75], ["C4", 0.25], ["C4", 0.75], ["C4", 0.25], ["C4", 0.75], ["C4*", 0.25],
		["F4", 3, "F"], ["F4", 0.5], ["C4", 0.25], ["F4", 0.25],
		["A4", 1], ["A4", 1], ["A4", 1], ["A4", 0.5], ["Bb4", 0.25], ["F4", 0.25],
		["A4", 1.5], ["G4", 0.5], ["F4*", 1], ["r", 1],
		["G4", 0.75, "C"], ["A4", 0.25], ["A4", 0.75], ["G4", 0.25], ["F4", 0.5], ["r", 0.5], ["G4", 0.75], ["A4", 0.25],
		["A4", 1], ["G4", 0.75], ["A4", 0.25], ["A4", 1], ["G4", 0.5], ["A4", 0.25], ["G4", 0.25],
		["F4*", 1, "F"], ["r", 3],
	]},
]
