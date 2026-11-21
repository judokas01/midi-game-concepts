extends RefCounted
## The song book's Children's songs: the tunes of song-ideas.md's section "Children's songs known worldwide",
## written out in the format song.gd describes.

const CATEGORY := "Children's songs"
const SONGS := [
	{name = "Hot Cross Buns", category = "Children's songs", difficulty = 1, notes = [
		["E4", 1, "C"], ["D4", 1], ["C4*", 2], ["E4", 1], ["D4", 1], ["C4*", 2],
		["C4", 0.5], ["C4", 0.5], ["C4", 0.5], ["C4", 0.5], ["D4", 0.5, "G"], ["D4", 0.5], ["D4", 0.5], ["D4", 0.5], ["E4", 1, "C"], ["D4", 1, "G"], ["C4", 2, "C"],
	]},
	# 2/4. One verse: "Go tell Aunt Rhody" three times, "the old grey goose is dead".
	{name = "Go Tell Aunt Rhody", category = "Children's songs", difficulty = 1, meter = 2, notes = [
		["E4", 1, "C"], ["E4", 0.5], ["D4", 0.5], ["C4", 1], ["C4*", 1],
		["D4", 1, "G"], ["D4", 0.5], ["F4", 0.5], ["E4", 1], ["D4*", 1],
		["E4", 1, "C"], ["E4", 0.5], ["D4", 0.5], ["C4", 1], ["C4*", 1],
		["D4", 1, "G"], ["E4", 0.5], ["D4", 0.5], ["C4", 2, "C"],
	]},
	{name = "London Bridge", category = "Children's songs", difficulty = 2, notes = [
		["G4", 1.5, "C"], ["A4", 0.5], ["G4", 1], ["F4", 1], ["E4", 1], ["F4", 1], ["G4*", 2],
		["D4", 1, "G"], ["E4", 1], ["F4", 2], ["E4", 1, "C"], ["F4", 1], ["G4*", 2],
		["G4", 1.5], ["A4", 0.5], ["G4", 1], ["F4", 1], ["E4", 1], ["F4", 1], ["G4", 2],
		["D4", 2, "G"], ["G4*", 2], ["E4", 1, "C"], ["C4", 3],
	]},
	{name = "Au Clair de la Lune", category = "Children's songs", difficulty = 2, key = "F", notes = [
		["F4", 1, "F"], ["F4", 1], ["F4", 1], ["G4", 1], ["A4", 2], ["G4*", 2, "C"],
		["F4", 1, "F"], ["A4", 1], ["G4", 1, "C"], ["G4", 1], ["F4*", 4, "F"],
		["F4", 1], ["F4", 1], ["F4", 1], ["G4", 1], ["A4", 2], ["G4", 2, "C"],
		["F4", 1, "F"], ["A4", 1], ["G4", 1, "C"], ["G4", 1], ["F4", 4, "F"],
		["G4", 1, "C"], ["G4", 1], ["G4", 1], ["G4", 1], ["D4*", 2, "G"], ["D4", 2],
		["G4", 1], ["F4", 1], ["E4", 1], ["D4", 1], ["C4*", 4, "C"],
		["F4", 1, "F"], ["F4", 1], ["F4", 1], ["G4", 1], ["A4", 2], ["G4", 2, "C"],
		["F4", 1, "F"], ["A4", 1], ["G4", 1, "C"], ["G4", 1], ["F4", 4, "F"],
	]},
	# 6/8: three beats a bar.
	{name = "Row Your Boat", category = "Children's songs", difficulty = 2, meter = 3, notes = [
		["C4", 1.5, "C"], ["C4", 1.5], ["C4", 1], ["D4", 0.5], ["E4", 1.5],
		["E4", 1], ["D4", 0.5], ["E4", 1], ["F4", 0.5], ["G4*", 3],
		["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5], ["E4", 0.5], ["E4", 0.5], ["E4", 0.5], ["C4", 0.5], ["C4", 0.5], ["C4*", 0.5],
		["G4", 1, "G"], ["F4", 0.5], ["E4", 1], ["D4", 0.5], ["C4", 3, "C"],
	]},
	# In F: in C its "ding dang dong" falls to G3. A round, so one chord all through.
	{name = "Bratře Kubo (Frère Jacques)", category = "Children's songs", difficulty = 2, key = "F", notes = [
		["F4", 1, "F"], ["G4", 1], ["A4", 1], ["F4", 1], ["F4", 1], ["G4", 1], ["A4", 1], ["F4*", 1],
		["A4", 1], ["Bb4", 1], ["C5*", 2], ["A4", 1], ["Bb4", 1], ["C5*", 2],
		["C5", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 1], ["F4", 1],
		["C5", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 1], ["F4*", 1],
		["F4", 1], ["C4", 1], ["F4", 2], ["F4", 1], ["C4", 1], ["F4", 2],
	]},
	# In G: in C it falls to G3. One verse, with its "moo moo here".
	{name = "Old MacDonald", category = "Children's songs", difficulty = 2, key = "G", notes = [
		["G4", 1, "G"], ["G4", 1], ["G4", 1], ["D4", 1], ["E4", 1, "C"], ["E4", 1], ["D4*", 2, "G"],
		["B4", 1], ["B4", 1], ["A4", 1, "D"], ["A4", 1], ["G4*", 3, "G"], ["D4", 1],
		["G4", 1], ["G4", 1], ["G4", 1], ["D4", 1], ["E4", 1, "C"], ["E4", 1], ["D4", 2, "G"],
		["B4", 1], ["B4", 1], ["A4", 1, "D"], ["A4", 1], ["G4*", 3, "G"], ["D4", 0.5], ["D4", 0.5],
		["G4", 1], ["G4", 1], ["G4", 1], ["D4", 0.5], ["D4", 0.5], ["G4", 1], ["G4", 1], ["G4*", 2],
		["G4", 0.5], ["G4", 0.5], ["G4", 1], ["G4", 0.5], ["G4", 0.5], ["G4", 1],
		["G4", 0.5], ["G4", 0.5], ["G4", 0.5], ["G4", 0.5], ["G4", 1], ["G4", 1],
		["G4", 1], ["G4", 1], ["G4", 1], ["D4", 1], ["E4", 1, "C"], ["E4", 1], ["D4", 2, "G"],
		["B4", 1], ["B4", 1], ["A4", 1, "D"], ["A4", 1], ["G4", 4, "G"],
	]},
	{name = "This Old Man", category = "Children's songs", difficulty = 2, notes = [
		["G4", 1, "C"], ["E4", 1], ["G4", 2], ["G4", 1], ["E4", 1], ["G4*", 2],
		["A4", 1, "F"], ["G4", 1], ["F4", 1], ["E4", 1], ["D4", 1, "G"], ["E4", 1], ["F4*", 1], ["E4", 0.5], ["F4", 0.5],
		["G4", 1, "C"], ["C4", 1], ["C4", 0.5], ["C4", 0.5], ["C4", 1], ["C4", 0.5], ["D4", 0.5], ["E4", 0.5], ["F4", 0.5], ["G4*", 2],
		["G4", 1, "G"], ["D4", 1], ["D4", 1], ["F4", 1], ["E4", 1, "C"], ["D4", 1, "G"], ["C4", 2, "C"],
	]},
	# 6/8, three beats a bar, from "The" before the first bar line. In F: in C it falls to G3.
	{name = "Itsy Bitsy Spider", category = "Children's songs", difficulty = 2, key = "F", meter = 3, pickup = 0.5, notes = [
		["C4", 0.5],
		["F4", 1, "F"], ["F4", 0.5], ["F4", 1], ["G4", 0.5], ["A4", 1.5], ["A4", 1], ["A4", 0.5],
		["G4", 1, "C"], ["F4", 0.5], ["G4", 1], ["A4", 0.5], ["F4*", 1.5, "F"], ["r", 1.5],
		["A4", 1.5], ["A4", 1], ["Bb4", 0.5], ["C5", 1.5], ["r", 1], ["C5", 0.5],
		["Bb4", 1, "C"], ["A4", 0.5], ["Bb4", 1], ["C5", 0.5], ["A4*", 1.5, "F"], ["r", 1.5],
		["F4", 1.5], ["F4", 1], ["G4", 0.5], ["A4", 1.5], ["r", 1], ["A4", 0.5],
		["G4", 1, "C"], ["F4", 0.5], ["G4", 1], ["A4", 0.5], ["F4*", 2, "F"], ["C4", 0.5], ["C4", 0.5],
		["F4", 1], ["F4", 0.5], ["F4", 1], ["G4", 0.5], ["A4", 1.5], ["A4", 1], ["A4", 0.5],
		["G4", 1, "C"], ["F4", 0.5], ["G4", 1], ["A4", 0.5], ["F4", 3, "F"],
	]},
	# Hodně štěstí, zdraví. 3/4, from the "Hap-py" before the first bar line. The pickup is
	# evened out to two eighths; the real rhythm is long-short.
	{name = "Happy Birthday", category = "Children's songs", difficulty = 3, key = "F", meter = 3, pickup = 1, notes = [
		["C4", 0.5], ["C4", 0.5],
		["D4", 1, "F"], ["C4", 1], ["F4", 1], ["E4*", 2, "C"], ["C4", 0.5], ["C4", 0.5],
		["D4", 1], ["C4", 1], ["G4", 1], ["F4*", 2, "F"], ["C4", 0.5], ["C4", 0.5],
		["C5", 1], ["A4", 1], ["F4", 1], ["E4", 1, "Bb"], ["D4*", 1], ["Bb4", 0.5], ["Bb4", 0.5],
		["A4", 1, "F"], ["F4", 1], ["G4", 1, "C"], ["F4", 3, "F"],
	]},
	# 6/8: three beats a bar.
	{name = "Pop Goes the Weasel", category = "Children's songs", difficulty = 3, meter = 3, notes = [
		["C4", 1, "C"], ["C4", 0.5], ["D4", 1], ["D4", 0.5], ["E4", 0.5], ["G4", 0.5], ["E4", 0.5], ["C4*", 1.5],
		["C4", 1], ["C4", 0.5], ["D4", 1, "G"], ["D4", 0.5], ["E4", 1.5, "C"], ["C4*", 1.5],
		["C4", 1], ["C4", 0.5], ["D4", 1], ["D4", 0.5], ["E4", 0.5], ["G4", 0.5], ["E4", 0.5], ["C4*", 1.5],
		["A4", 1.5, "F"], ["D4", 1, "G"], ["F4", 0.5], ["E4", 1.5, "C"], ["C4", 1.5],
	]},
	# 6/8: three beats a bar. The round's tune, one voice.
	{name = "Three Blind Mice", category = "Children's songs", difficulty = 3, meter = 3, notes = [
		["E4", 1.5, "C"], ["D4", 1.5, "G"], ["C4*", 3, "C"], ["E4", 1.5], ["D4", 1.5, "G"], ["C4*", 3, "C"],
		["G4", 1.5], ["F4", 1, "G"], ["F4", 0.5], ["E4*", 3, "C"], ["G4", 1.5], ["F4", 1, "G"], ["F4", 0.5], ["E4*", 1.5, "C"], ["r", 1], ["G4", 0.5],
		["C5", 1], ["C5", 0.5], ["B4", 0.5, "G"], ["A4", 0.5], ["B4", 0.5], ["C5", 1, "C"], ["G4", 0.5], ["G4*", 1], ["G4", 0.5],
		["C5", 1], ["C5", 0.5], ["B4", 0.5, "G"], ["A4", 0.5], ["B4", 0.5], ["C5", 1, "C"], ["G4", 0.5], ["G4*", 1], ["G4", 0.5],
		["C5", 1], ["C5", 0.5], ["B4", 0.5, "G"], ["A4", 0.5], ["B4", 0.5], ["C5", 1, "C"], ["G4", 0.5], ["G4", 1], ["F4", 0.5, "G"],
		["E4", 1.5, "C"], ["D4", 1.5, "G"], ["C4", 3, "C"],
	]},
	# After Paul Hardy's Songs Tunebook (https://pghardy.net/tunebooks/pgh_songs_tunebook.abc,
	# "Ring a Ring o Roses"): the British tune, in C. 6/8, three beats a bar. Played twice. The
	# American "ashes, ashes" may be sung differently in the last two bars.
	{name = "Ring Around the Rosie", category = "Children's songs", difficulty = 2, meter = 3, notes = [
		["G4", 1, "C"], ["G4", 0.5], ["E4", 1], ["A4", 0.5], ["G4", 1.5], ["E4", 1], ["F4", 0.5],
		["G4", 1], ["G4", 0.5], ["E4", 1], ["A4", 0.5], ["G4*", 1.5], ["E4", 1], ["G4", 0.5],
		["C5", 1.5], ["G4", 1], ["G4", 0.5], ["C5", 1.5], ["G4", 1], ["F4", 0.5],
		["E4", 1.5], ["D4", 1.5, "G"], ["C4*", 3, "C"],
		["G4", 1], ["G4", 0.5], ["E4", 1], ["A4", 0.5], ["G4", 1.5], ["E4", 1], ["F4", 0.5],
		["G4", 1], ["G4", 0.5], ["E4", 1], ["A4", 0.5], ["G4*", 1.5], ["E4", 1], ["G4", 0.5],
		["C5", 1.5], ["G4", 1], ["G4", 0.5], ["C5", 1.5], ["G4", 1], ["F4", 0.5],
		["E4", 1.5], ["D4", 1.5, "G"], ["C4*", 3, "C"],
	]},
	# After the Digital Tradition's ABC (https://abcnotation.com/tunePage?a=sniff.numachi.com/~rickheit/dtrad/abc_dtrad.tar.gz/abc_dtrad/FRMRDELL/0000),
	# a tone down in F. 6/8, three beats a bar, from "The" before the first bar line. Two
	# verses. Its "dell", held two and a half beats, is cut to two.
	{name = "The Farmer in the Dell", category = "Children's songs", difficulty = 2, key = "F", meter = 3, pickup = 0.5, notes = [
		["C4", 0.5],
		["F4", 1, "F"], ["F4", 0.5], ["F4", 1], ["F4", 0.5], ["F4", 2], ["r", 0.5], ["G4", 0.5],
		["A4", 1], ["A4", 0.5], ["A4", 1], ["A4", 0.5], ["A4*", 2], ["r", 1],
		["C5", 1.5], ["C5", 1], ["D5", 0.5], ["C5", 1], ["A4", 0.5], ["F4", 1], ["G4", 0.5],
		["A4", 1], ["A4", 0.5], ["G4", 1, "C"], ["G4", 0.5], ["F4*", 2, "F"], ["r", 0.5], ["C4", 0.5],
		["F4", 1], ["F4", 0.5], ["F4", 1], ["F4", 0.5], ["F4", 2], ["r", 0.5], ["G4", 0.5],
		["A4", 1], ["A4", 0.5], ["A4", 1], ["A4", 0.5], ["A4*", 2], ["r", 1],
		["C5", 1.5], ["C5", 1], ["D5", 0.5], ["C5", 1], ["A4", 0.5], ["F4", 1], ["G4", 0.5],
		["A4", 1], ["A4", 0.5], ["G4", 1, "C"], ["G4", 0.5], ["F4*", 3, "F"],
	]},
	# After the score in English Wikipedia's "Here We Go Round the Mulberry Bush" (LilyPond, G),
	# a tone down in F. 6/8, three beats a bar. Twice: the verse, then "This is the way...".
	{name = "Here We Go Round the Mulberry Bush", category = "Children's songs", difficulty = 2, key = "F", meter = 3, notes = [
		["F4", 0.5, "F"], ["F4", 0.5], ["F4", 0.5], ["F4", 1], ["A4", 0.5], ["C5", 1], ["A4", 0.5], ["F4", 1], ["F4", 0.5],
		["G4", 1, "C"], ["G4", 0.5], ["G4", 1], ["F4", 0.5], ["E4", 1], ["D4", 0.5], ["C4*", 1.5],
		["F4", 0.5, "F"], ["F4", 0.5], ["F4", 0.5], ["F4", 1], ["A4", 0.5], ["C5", 1], ["A4", 0.5], ["F4", 1], ["F4", 0.5],
		["G4", 1, "C"], ["G4", 0.5], ["C4", 1], ["C4", 0.5], ["F4", 1.5, "F"], ["F4*", 1.5],
		["F4", 0.5], ["F4", 0.5], ["F4", 0.5], ["F4", 1], ["A4", 0.5], ["C5", 1], ["A4", 0.5], ["F4", 1], ["F4", 0.5],
		["G4", 1, "C"], ["G4", 0.5], ["G4", 1], ["F4", 0.5], ["E4", 1], ["D4", 0.5], ["C4*", 1.5],
		["F4", 0.5, "F"], ["F4", 0.5], ["F4", 0.5], ["F4", 1], ["A4", 0.5], ["C5", 1], ["A4", 0.5], ["F4", 1], ["F4", 0.5],
		["G4", 1, "C"], ["G4", 0.5], ["C4", 1], ["C4", 0.5], ["F4", 1.5, "F"], ["F4", 1.5],
	]},
	# After the score in English Wikipedia's "Humpty Dumpty" (J. W. Elliott's 1870 tune, LilyPond,
	# B flat), a tone up in C so that it is all white keys: C4 to F5, the last line above the
	# computer keys. 6/8, three beats a bar. Rated 3, not the list's 2, for that range.
	{name = "Humpty Dumpty", category = "Children's songs", difficulty = 3, meter = 3, notes = [
		["E4", 1, "C"], ["G4", 0.5], ["F4", 1, "F"], ["A4", 0.5], ["G4", 0.5, "G"], ["A4", 0.5], ["B4", 0.5], ["C5*", 1.5, "C"],
		["E4", 1], ["G4", 0.5], ["F4", 1, "F"], ["A4", 0.5], ["G4", 0.5, "C"], ["E4", 0.5], ["C4", 0.5], ["D4*", 1.5, "G"],
		["E4", 0.5, "C"], ["E4", 0.5], ["G4", 0.5], ["F4", 0.5, "F"], ["F4", 0.5], ["A4", 0.5], ["G4", 0.5, "G"], ["A4", 0.5], ["B4", 0.5], ["C5*", 1.5, "C"],
		["E5", 0.5], ["E5", 0.5], ["C5", 0.5], ["F5", 0.5, "F"], ["F5", 0.5], ["E5", 0.5], ["D5", 0.5, "G"], ["C5", 0.5], ["B4", 0.5], ["C5", 1.5, "C"],
	]},
	# After the melody of mfiles.co.uk's "Polly Put the Kettle On" (its MIDI, at
	# https://www.mfiles.co.uk/scores/polly-put-the-kettle-on.htm), in F; the ABC found were the
	# dance tune. "Polly put the kettle on" three times, then "Sukey take it off again". Less
	# sure of bar 6's leap down to D4, as the MIDI has it.
	{name = "Polly Put the Kettle On", category = "Children's songs", difficulty = 2, key = "F", notes = [
		["C5", 0.5, "F"], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 0.5], ["F4", 0.5], ["F4", 1],
		["G4", 0.5, "C"], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["C4", 0.5], ["C4*", 1],
		["C5", 0.5, "F"], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 0.5], ["F4", 0.5], ["F4", 0.5], ["A4", 0.5],
		["D4", 1, "Bb"], ["E4", 0.5, "C"], ["E4", 0.5], ["F4*", 2, "F"],
		["A4", 0.5], ["F4", 0.5], ["Bb4", 0.5], ["G4", 0.5], ["A4", 0.5], ["F4", 0.5], ["F4", 1],
		["Bb4", 0.5, "Bb"], ["D4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5, "C"], ["C4", 0.5], ["C4*", 1],
		["A4", 0.5, "F"], ["F4", 0.5], ["Bb4", 0.5], ["G4", 0.5], ["A4", 0.5], ["F4", 0.5], ["F4", 0.5], ["A4", 0.5],
		["D4", 1, "Bb"], ["E4", 0.5, "C"], ["E4", 0.5], ["F4", 2, "F"],
	]},
	# After the score in English Wikipedia's "Oranges and Lemons" (LilyPond, A), a major third
	# down in F: C4 to C5. 3/4. "Oranges and lemons" and "five farthings", "When will you pay
	# me?" and "When I grow rich", then "Here comes a candle". The score's leaps up an octave
	# into "You owe me" and into "Here comes" are read as the first line's octave; its D.C.
	# back to the first eight bars is left out.
	{name = "Oranges and Lemons", category = "Children's songs", difficulty = 2, key = "F", meter = 3, notes = [
		["C5", 1, "F"], ["A4", 1], ["C5", 1], ["A4", 1], ["F4", 1], ["G4", 0.5], ["A4", 0.5],
		["Bb4", 1, "C"], ["G4", 1], ["C5", 1], ["A4", 1, "F"], ["F4*", 2],
		["C5", 0.5], ["C5", 0.5], ["A4", 1], ["C5", 1], ["A4", 1], ["F4", 1], ["G4", 0.5], ["A4", 0.5],
		["Bb4", 1, "C"], ["G4", 1], ["C5", 1], ["A4", 1, "F"], ["F4*", 2],
		["G4", 1, "C"], ["E4", 1], ["G4", 1], ["E4", 1], ["C4", 1], ["D4", 0.5], ["E4", 0.5],
		["F4", 1, "G"], ["D4", 1], ["G4", 1], ["E4", 1, "C"], ["C4*", 2],
		["G4", 1], ["E4", 1], ["G4", 1], ["C4", 2], ["D4", 0.5], ["E4", 0.5],
		["F4", 1, "G"], ["D4", 1], ["G4", 1], ["C4*", 3, "C"],
		["A4", 1, "F"], ["F4", 1], ["C5", 1], ["A4", 1], ["F4", 1], ["G4", 0.5], ["A4", 0.5],
		["G4", 1, "C"], ["Bb4", 1], ["E4", 1], ["F4*", 2, "F"], ["G4", 1],
		["A4", 1], ["F4", 1], ["C5", 1], ["A4", 1], ["F4", 1], ["G4", 0.5], ["A4", 0.5],
		["Bb4", 1, "Gm"], ["A4", 1], ["G4", 1, "C"], ["F4", 3, "F"],
	]},
	# From memory — check by ear. The tune sung today; the written versions found (The Everyday
	# Song Book, 1927; the Digital Tradition) are older variants of it. In F, from "There"
	# before the first bar line. Less sure: bar 4's "name-o", the rhythm of the spelled bars
	# (two quarters, two eighths, a quarter), and bar 7's "O, and".
	{name = "Bingo", category = "Children's songs", difficulty = 2, key = "F", pickup = 1, notes = [
		["C4", 1],
		["F4", 1, "F"], ["F4", 1], ["C4", 1], ["C4", 1], ["D4", 1, "Bb"], ["D4", 1], ["C4", 1, "F"], ["C4", 1],
		["F4", 1], ["F4", 1], ["G4", 1, "C"], ["G4", 1], ["A4*", 2, "F"], ["F4", 1], ["r", 1],
		["A4", 1], ["A4", 1], ["Bb4", 0.5, "Bb"], ["Bb4", 0.5], ["Bb4", 1], ["G4", 1, "C"], ["G4", 1], ["A4", 0.5, "F"], ["A4", 0.5], ["A4*", 1],
		["F4", 1], ["F4", 1], ["G4", 0.5, "C"], ["G4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 1], ["C4", 1], ["D4", 1], ["E4", 1],
		["F4*", 3, "F"],
	]},
	# After the Digital Tradition's ABC (https://abcnotation.com/tunePage?a=sniff.numachi.com/~rickheit/dtrad/abc_dtrad.tar.gz/abc_dtrad/SKIPLOU/0000),
	# a tone down in F, in 2/4. Its "skip to my" is an eighth and two sixteenths; its bar of
	# three and a half beats ("skip to my Lou, my") is read as four. The chorus twice.
	{name = "Skip to My Lou", category = "Children's songs", difficulty = 2, key = "F", meter = 2, notes = [
		["A4", 1, "F"], ["F4", 1], ["A4", 0.5], ["A4", 0.25], ["A4", 0.25], ["C5", 1],
		["G4", 1, "C"], ["E4", 1], ["G4", 0.5], ["G4", 0.25], ["G4", 0.25], ["Bb4*", 1],
		["A4", 1, "F"], ["F4", 1], ["A4", 0.5], ["A4", 0.25], ["A4", 0.25], ["C5", 1],
		["G4", 1, "C"], ["A4", 0.5], ["Bb4", 0.5], ["A4", 1], ["G4", 1],
		["F4", 2, "F"], ["F4*", 2],
		["A4", 1], ["F4", 1], ["A4", 0.5], ["A4", 0.25], ["A4", 0.25], ["C5", 1],
		["G4", 1, "C"], ["E4", 1], ["G4", 0.5], ["G4", 0.25], ["G4", 0.25], ["Bb4*", 1],
		["A4", 1, "F"], ["F4", 1], ["A4", 0.5], ["A4", 0.25], ["A4", 0.25], ["C5", 1],
		["G4", 1, "C"], ["A4", 0.5], ["Bb4", 0.5], ["A4", 1], ["G4", 1],
		["F4", 2, "F"], ["F4*", 2],
	]},
	# After the score in English Wikipedia's "Lavender's Blue" (LilyPond, G, 3/8), a fifth down
	# in C, in 3/4 with its eighths as quarters. Its two endings, then the same again for the
	# second couplet.
	{name = "Lavender's Blue", category = "Children's songs", difficulty = 2, meter = 3, notes = [
		["C4", 1, "C"], ["G4", 1], ["G4", 1], ["G4", 1], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["C4", 0.5],
		["C4", 1, "F"], ["A4", 1], ["A4", 1], ["A4*", 3],
		["C4", 1, "C"], ["G4", 1], ["G4", 1], ["G4", 1], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["C4", 0.5],
		["F4", 1, "G"], ["E4", 1], ["D4", 1], ["C4*", 3, "C"],
		["C4", 1], ["G4", 1], ["G4", 1], ["G4", 1], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["C4", 0.5],
		["C4", 1, "F"], ["A4", 1], ["A4", 1], ["A4*", 3],
		["C4", 1, "C"], ["G4", 1], ["G4", 1], ["G4", 1], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["C4", 0.5],
		["F4", 1, "G"], ["E4", 1], ["D4", 1], ["C4*", 3, "C"],
	]},
	# After Weckerlin's 1870 setting in English Wikipedia's "Sur le Pont d'Avignon" (LilyPond, G),
	# a tone down in F: C4 to C5. 2/4. The refrain, Weckerlin's verse ("Les messieurs font comme
	# ça"; the verse sung today may differ), the refrain again. His verse chords simplified.
	{name = "Sur le Pont d'Avignon", category = "Children's songs", difficulty = 2, key = "F", meter = 2, notes = [
		["F4", 0.5, "F"], ["F4", 0.5], ["F4", 1], ["G4", 0.5, "C"], ["G4", 0.5], ["G4", 1],
		["A4", 0.75, "F"], ["Bb4", 0.25], ["C5", 0.5], ["F4", 0.5], ["E4", 0.75, "C"], ["F4", 0.25], ["G4", 0.5], ["C4*", 0.5],
		["F4", 0.5, "Dm"], ["F4", 0.5], ["F4", 1], ["G4", 0.5, "C"], ["G4", 0.5], ["G4", 1],
		["A4", 0.75, "F"], ["Bb4", 0.25], ["C5", 0.5], ["F4", 0.5], ["G4", 0.5, "C"], ["E4", 0.5], ["F4*", 0.5, "F"], ["r", 0.5],
		["F4", 0.75], ["F4", 0.25], ["F4", 0.5], ["F4", 0.5], ["G4", 1, "C"], ["F4", 0.5, "F"], ["r", 0.5],
		["F4", 0.75], ["F4", 0.25], ["F4", 0.5], ["F4", 0.5], ["G4", 1, "C"], ["F4*", 0.5, "F"], ["r", 0.5],
		["F4", 0.5], ["F4", 0.5], ["F4", 1], ["G4", 0.5, "C"], ["G4", 0.5], ["G4", 1],
		["A4", 0.75, "F"], ["Bb4", 0.25], ["C5", 0.5], ["F4", 0.5], ["E4", 0.75, "C"], ["F4", 0.25], ["G4", 0.5], ["C4*", 0.5],
		["F4", 0.5, "Dm"], ["F4", 0.5], ["F4", 1], ["G4", 0.5, "C"], ["G4", 0.5], ["G4", 1],
		["A4", 0.75, "F"], ["Bb4", 0.25], ["C5", 0.5], ["F4", 0.5], ["G4", 0.5, "C"], ["E4", 0.5], ["F4", 1, "F"],
	]},
	# After the score in English Wikipedia's "Alouette" (LilyPond, G, with chords), a tone down
	# in F: C4 to D5. The refrain, one verse ("Je te plumerai la tête"), the refrain again.
	# Rated 3, not the list's 2, for the verse's leaps of an octave.
	{name = "Alouette", category = "Children's songs", difficulty = 3, key = "F", notes = [
		["F4", 1.5, "F"], ["G4", 0.5], ["A4", 1], ["A4", 1], ["G4", 0.5, "C"], ["F4", 0.5], ["G4", 0.5], ["A4", 0.5], ["F4", 1, "F"], ["C4*", 1],
		["F4", 1.5], ["G4", 0.5], ["A4", 1], ["A4", 1, "Dm"], ["G4", 0.5, "Gm"], ["F4", 0.5], ["G4", 0.5, "C"], ["A4", 0.5], ["F4*", 2, "F"],
		["F4", 0.5], ["F4", 0.5], ["F4", 0.5], ["F4", 0.5], ["F4", 0.5], ["A4", 0.5], ["C5", 1],
		["C5", 0.5, "C"], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 0.5, "F"], ["G4", 0.5], ["F4", 1],
		["C5", 0.5, "C"], ["C5", 0.5], ["C5", 1], ["C4", 0.5], ["C4", 0.5], ["C4", 1],
		["C5", 0.5], ["C5", 0.5], ["C5", 1], ["C4", 0.5], ["C4", 0.5], ["C4*", 1],
		["C5", 1], ["Bb4", 1], ["A4", 1], ["G4", 1],
		["F4", 1.5, "F"], ["G4", 0.5], ["A4", 1], ["A4", 1], ["G4", 0.5, "C"], ["F4", 0.5], ["G4", 0.5], ["A4", 0.5], ["F4", 1, "F"], ["C4*", 1],
		["F4", 1.5], ["G4", 0.5], ["A4", 1], ["A4", 1, "Dm"], ["G4", 0.5, "Gm"], ["F4", 0.5], ["G4", 0.5, "C"], ["A4", 0.5], ["F4", 2, "F"],
	]},
	# The first eight bars after the ABC in Russian Wikipedia's "Ах, мой милый Августин" (C),
	# a fourth up in F: C4 to D5 (in C it falls to G3). 3/4. From memory, less sure: the middle
	# part ("Geld ist weg, Mädl ist weg", bars 9-12) and the last four bars after it.
	{name = "O du lieber Augustin", category = "Children's songs", difficulty = 2, key = "F", meter = 3, notes = [
		["C5", 1, "F"], ["C5", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 1], ["F4", 1], ["F4", 1],
		["G4", 1, "C"], ["C4", 1], ["C4", 1], ["A4", 1, "F"], ["F4", 1], ["F4*", 1],
		["C5", 1], ["C5", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 1], ["F4", 1], ["F4", 1],
		["G4", 1, "C"], ["C4", 1], ["C4", 1], ["F4*", 2, "F"], ["r", 1],
		["G4", 1, "C"], ["C4", 1], ["C4", 1], ["A4", 1, "F"], ["F4", 1], ["F4", 1],
		["G4", 1, "C"], ["C4", 1], ["C4", 1], ["A4", 1, "F"], ["F4", 1], ["F4*", 1],
		["C5", 1], ["C5", 0.5], ["D5", 0.5], ["C5", 0.5], ["Bb4", 0.5], ["A4", 1], ["F4", 1], ["F4", 1],
		["G4", 1, "C"], ["C4", 1], ["C4", 1], ["F4", 3, "F"],
	]},
	# After the score in English Wikipedia's "Hickory Dickory Dock" (LilyPond, D), a tone down
	# in C: C4 to C5. 6/8, three beats a bar. Its "dock", held two and a half beats, is cut to
	# two.
	{name = "Hickory Dickory Dock", category = "Children's songs", difficulty = 3, meter = 3, notes = [
		["E4", 0.5, "C"], ["F4", 0.5], ["G4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C5*", 2], ["r", 0.5], ["G4", 0.5],
		["E4", 0.5], ["F4", 0.5], ["G4", 0.5], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5], ["C5*", 2], ["r", 0.5], ["G4", 0.5],
		["C5", 1], ["C5", 0.5], ["B4", 1, "G"], ["B4", 0.5], ["A4", 1, "F"], ["A4", 0.5], ["G4*", 1.5, "C"],
		["G4", 0.5, "G"], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["E4", 0.5], ["D4", 0.5], ["C4", 3, "C"],
	]},
	# After the second score in German Wikipedia's "Rock-a-bye Baby": Effie Canning's 1886 tune
	# (she died in 1940), the one known in the US, not the older English one. 6/8, three beats
	# a bar; a fourth down from its C, in G, so that only B3 is off the computer keys.
	{name = "Rock-a-bye Baby", category = "Children's songs", difficulty = 3, key = "G", meter = 3, notes = [
		["B3", 0.75, "G"], ["D4", 0.25], ["B4", 0.5], ["A4", 1], ["G4", 0.5], ["B3", 0.75], ["D4", 0.25], ["G4", 0.5], ["F#4*", 1.5, "D"],
		["C4", 0.75, "Am"], ["D4", 0.25], ["C5", 0.5], ["B4", 1], ["A4", 0.5], ["A4", 0.5, "D"], ["G4", 0.5], ["E4", 0.5], ["D4*", 1.5],
		["B3", 0.75, "G"], ["D4", 0.25], ["B4", 0.5], ["A4", 1], ["G4", 0.5], ["B3", 0.75], ["D4", 0.25], ["G4", 0.5], ["F#4*", 1.5, "D"],
		["D4", 0.75, "G"], ["G4", 0.25], ["C5", 0.5, "C"], ["B4", 1], ["G4", 0.5], ["A4", 0.5, "D"], ["E4", 0.5], ["F#4", 0.5], ["G4", 1.5, "G"],
	]},
	# Septimus Winner set his 1864 "Der Deitcher's Dog" to "Der Lauterbacher" ("Zu Lauterbach
	# hab' ich mein' Strumpf verlor'n"). After that song as sung, in the Essen folk-song
	# collection (Erk, https://abcnotation.com/tunePage?a=ifdo.ca/~seymour/runabc/esac/erk30/0012, G),
	# checked against the Ländler "Der Lauterbacher"
	# (https://abcnotation.com/tunePage?a=www.dropbox.com/sh/flddgymslo57zvl/AAAz5s386GT0d4amGpHb8wDXa/abc.zip/Bd3/wz03134/0001),
	# whose octave-drop frills are left out. A tone down in F: C4 to E5. 3/4, from "Oh" before
	# the first bar line. One verse; the words fit it note for note, "he" taking two.
	{name = "Oh Where Has My Little Dog Gone", category = "Children's songs", difficulty = 3, key = "F", meter = 3, pickup = 1, notes = [
		["C4", 1],
		["C5", 1.5, "F"], ["C5", 0.5], ["A4", 1], ["F4", 1], ["F4", 1], ["F4", 1], ["G4", 2, "C"], ["C4", 1], ["C4*", 2], ["C4", 1],
		["D5", 1.5, "Bb"], ["C5", 0.5], ["Bb4", 1], ["Bb4", 1, "Gm"], ["A4", 1], ["G4", 1], ["C5*", 4, "C"], ["r", 1], ["C4", 1],
		["C5", 1.5, "F"], ["C5", 0.5], ["A4", 1], ["F4", 1], ["F4", 1], ["F4", 1], ["G4", 2, "C"], ["C4", 1], ["C4*", 2], ["C4", 1],
		["E5", 1.5], ["D5", 0.5], ["C5", 1], ["C5", 1], ["Bb4", 1], ["G4", 1], ["F4*", 4, "F"], ["r", 1],
	]},
	# After Version 1 in English Wikipedia's "Sing a Song of Sixpence" (LilyPond, C; it calls it
	# the version best known in Britain, Version 2 the one in the US), a tone down in B flat:
	# C4 to D5.
	{name = "Sing a Song of Sixpence", category = "Children's songs", difficulty = 3, key = "Bb", notes = [
		["Bb4", 0.5, "Bb"], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["Bb4", 1], ["D4", 0.5], ["D4", 0.5], ["F4", 0.5], ["G4", 0.5], ["F4", 0.5], ["D4", 0.5], ["F4*", 2],
		["Bb4", 0.5], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["Bb4", 1], ["D4", 1], ["C4", 1, "Cm"], ["G4", 0.5], ["G4", 0.5], ["G4*", 2],
		["F4", 0.5, "Bb"], ["Bb4", 0.5], ["Bb4", 0.5], ["Bb4", 0.5], ["Bb4", 1], ["Bb4", 0.5], ["Bb4", 0.5], ["A4", 0.5, "F"], ["C5", 0.5], ["C5", 0.5], ["C5", 0.5], ["C5*", 2],
		["D5", 0.5, "Bb"], ["C5", 0.5], ["Bb4", 0.5], ["A4", 0.5], ["Bb4", 0.5, "Eb"], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5], ["G4", 0.5], ["Bb4", 0.5], ["A4", 0.5, "F"], ["C5", 0.5], ["Bb4", 2, "Bb"],
	]},
]
