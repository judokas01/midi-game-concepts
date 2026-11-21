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
	# Songs My Mother Taught Me, Op. 55 No. 4, after the voice part of
	# https://www.mutopiaproject.org/ftp/DvorakA/O55/dvorak-als-die-alte-mutter/dvorak-als-die-alte-mutter.ly
	# (2/4 over the piano's 6/8), a fifth down so that it sits on the computer keys; chords from
	# its piano part. Both verses, without the piano's interlude. The second verse's two quick
	# three-note runs (bars 19 and 23) are left out, their first note kept.
	{name = "Když mne stará matka (Dvořák)", category = "Czech classics", difficulty = 3, key = "G", meter = 2, notes = [
		["G4", 1, "G"], ["F#4", 0.5], ["E4", 0.5],
		["G4", 1, "Em"], ["F#4", 0.5], ["E4", 0.5],
		["G4", 0.5, "Am"], ["C5", 1], ["C4", 0.5],
		["C4*", 1, "D"], ["r", 1],
		["F#4", 1], ["E4", 0.5], ["D4", 0.5],
		["F#4", 1], ["E4", 0.5], ["D4", 0.5],
		["F#4", 0.5, "G"], ["B4", 1], ["B3", 0.5],
		["B3*", 1], ["r", 1],
		["E4", 1, "C"], ["E4", 1],
		["F#4", 0.5, "A"], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5],
		["C5", 1.5, "D"], ["F#4", 0.5],
		["F#4*", 1.5, "D#dim"], ["r", 0.5],
		["G4", 1.5, "Em"], ["G4", 0.5],
		["F#4", 1, "C"], ["E4", 1],
		["D4", 2, "G"],
		["D4*", 1], ["r", 1],
		["G4", 1], ["F#4", 0.5], ["E4", 0.5],
		["G4", 1, "Em"], ["F#4", 0.5], ["E4", 0.5],
		["G4", 0.5, "Am"], ["C5", 1], ["C4", 0.5],
		["C4*", 1, "D"], ["r", 1],
		["F#4", 1], ["E4", 0.5], ["D4", 0.5],
		["F#4", 1], ["E4", 0.5], ["D4", 0.5],
		["F#4", 0.5, "G"], ["B4", 1], ["B3", 0.5],
		["B3*", 1], ["r", 1],
		["E4", 1, "C"], ["E4", 1],
		["F#4", 0.5, "A"], ["G4", 0.5], ["A4", 0.5], ["B4", 0.5],
		["C5*", 2, "D"],
		["B4", 1, "D#dim"], ["A4", 1],
		["G#4", 1.5, "E"], ["G#4", 0.5],
		["B4", 1, "Am"], ["A4", 0.5], ["G4", 0.5],
		["F#4", 1, "D"], ["F#4", 1],
		["A4", 0.5], ["F#4", 0.5], ["E4", 0.5], ["C4", 0.5],
		["D4", 2, "G"],
		["D4*", 2],
	]},
	# The finale's main theme (horns and trumpets), after the first trumpet's part in
	# https://www.mutopiaproject.org/ftp/DvorakA/O95/Sym9/Sym9-lys/brass.notesF.ily at sounding
	# pitch, played twice (the orchestra's second time is an octave up); chords from the strings'
	# parts. The triplet in bars 7 and 15 is written as an eighth and two sixteenths, and bar 8's
	# E is held two beats, not two and a half.
	{name = "Finale from the New World Symphony (Dvořák)", category = "Czech classics", difficulty = 3, key = "Em", notes = [
		["E4", 2, "Em"], ["F#4", 1], ["G4", 1],
		["F#4", 1.5, "Am"], ["E4", 0.5], ["E4*", 2],
		["E4", 2, "Em"], ["D4", 1, "G"], ["B3", 0.5], ["D4", 0.5],
		["E4*", 3, "Em"], ["E4", 1],
		["E4", 2], ["F#4", 1], ["G4", 1],
		["F#4", 1.5, "Am"], ["E4", 0.5], ["E4", 2],
		["E4", 1, "Em"], ["G4", 0.5], ["E4", 0.25], ["G4", 0.25], ["B4", 1, "B"], ["B3", 1],
		["E4*", 2, "Em"], ["r", 2],
		["E4", 2], ["F#4", 1], ["G4", 1],
		["F#4", 1.5, "Am"], ["E4", 0.5], ["E4", 2],
		["E4", 2, "Em"], ["D4", 1, "G"], ["B3", 0.5], ["D4", 0.5],
		["E4*", 2, "Em"], ["r", 1], ["E4", 1],
		["E4", 2], ["F#4", 1], ["G4", 1],
		["F#4", 1.5, "Am"], ["E4", 0.5], ["E4", 2],
		["E4", 1, "Em"], ["G4", 0.5], ["E4", 0.25], ["G4", 0.25], ["B4", 1, "B"], ["B3", 1],
		["E4*", 4, "Em"],
	]},
	# Song to the Moon, from Rusalka: the aria's first three phrases, a major third down from G
	# (the original is in G-flat, 3/8; here in 3/4). From memory, bars 9 to 23 compared with the
	# only score found, a modern single-line arrangement (Colin Hume, 2016, on abcnotation.com),
	# not copied from it. Bar 14 ("v lidské příbytky") is the least sure; the long notes that end
	# each phrase are held into the orchestra's bar. Chords mine.
	{name = "Měsíčku na nebi hlubokém (Dvořák)", category = "Czech classics", difficulty = 4, key = "Eb", meter = 3, notes = [
		["G4", 1, "Eb"], ["G4", 1], ["F4", 1],
		["G4", 1], ["Bb4", 1], ["F4", 1],
		["G4", 0.5], ["Eb4", 0.5], ["C4", 1, "Ab"], ["Eb4*", 4, "Eb"],
		["F4", 1, "Bb"], ["F4", 1], ["G4", 1, "Eb"],
		["F4", 1, "Bb"], ["F4", 1], ["G4", 1, "Eb"],
		["Ab4", 0.5, "Fm"], ["F4*", 4], ["r", 1.5],
		["G4", 1, "Eb"], ["G4", 1], ["F4", 1, "Bb"],
		["Ab4", 2, "Fm"], ["G4", 1, "Cm"],
		["C5", 0.5, "Fm"], ["Ab4", 0.5], ["Bb4*", 4, "Bb"], ["r", 1],
		["Bb4", 1, "Eb"], ["Ab4", 1], ["G4", 1],
		["G4", 1, "F"], ["C5", 1], ["D4", 0.5], ["Eb4", 0.5],
		["G4", 0.5, "Eb"], ["F4*", 4, "Bb"], ["r", 1.5],
		["Bb4", 1, "Eb"], ["Bb4", 1], ["Ab4", 1, "Fm"],
		["C5", 2, "Ab"], ["Bb4", 1, "Eb"],
		["D5", 0.5, "Gm"], ["Bb4", 0.5], ["C5*", 4, "Ab"], ["r", 1],
		["C5", 1, "C"], ["Bb4", 1], ["G4", 1],
		["Bb4", 0.5, "Fm"], ["Ab4", 0.5], ["G4", 1, "Bb"], ["F4", 0.5], ["Bb3", 0.5],
		["F4", 1], ["Eb4*", 2, "Eb"],
	]},
	# Humoresque, Op. 101 No. 7, its first strain (bars 1 to 8), after the 1894 Simrock edition
	# scanned at https://commons.wikimedia.org/wiki/File:Humoresques_for_Piano,_Op._101,_by_Antonín_Dvořák.pdf
	# (its page 26), a tritone down from G-flat so that it sits on C4 to C5, with doubled note
	# values: each long-short pair is one beat, each score bar two bars here. The pairs' tiny
	# rests and the two grace notes are left out; bar 7's two-note chords give their top note.
	# Chords from its left hand.
	{name = "Humoreska (Dvořák)", category = "Czech classics", difficulty = 3, meter = 2, notes = [
		["C4", 0.75, "C"], ["D4", 0.25], ["C4", 0.75], ["D4", 0.25],
		["E4", 0.75], ["G4", 0.25], ["A4", 0.75], ["G4", 0.25],
		["C5", 0.75, "F"], ["B4", 0.25], ["D5", 0.75], ["C5", 0.25],
		["B4", 0.75], ["D5", 0.25], ["C5", 0.75], ["A4*", 0.25],
		["G4", 0.75, "C"], ["G4", 0.25], ["A4", 0.75], ["G4", 0.25],
		["C5", 0.75], ["A4", 0.25], ["G4", 0.75], ["E4", 0.25],
		["D4*", 4, "G"],
		["C4", 0.75, "C"], ["D4", 0.25], ["C4", 0.75], ["D4", 0.25],
		["E4", 0.75], ["G4", 0.25], ["A4", 0.75], ["G4", 0.25],
		["A4", 0.75, "F"], ["B4", 0.25], ["D5", 0.75], ["C5", 0.25],
		["B4", 0.75], ["D5", 0.25], ["C5", 0.75], ["A4*", 0.25],
		["G4", 0.75, "C"], ["G4", 0.25], ["C5", 0.75], ["C4", 0.25],
		["D4", 1, "G"], ["G4", 1],
		["C4*", 3, "C"], ["r", 1],
	]},
	# The fanfare's opening motif, after the score block on
	# https://en.wikipedia.org/wiki/Sinfonietta_(Janáček): its top line, at pitch, the chords its
	# bare fifths. Only these seven bars are in the score found; the trumpets' fanfare tune that
	# follows is not recalled, so it is left out.
	{name = "Sinfonietta (Janáček)", category = "Czech classics", difficulty = 1, key = "Db", meter = 2, notes = [
		["Eb4", 2, "Ab"], ["Db4", 2, "Gb"], ["Bb3*", 2, "Ebm"],
		["Db4", 2, "Gb"], ["Bb3", 2, "Ebm"], ["Db4", 2, "Gb"], ["Bb3*", 2, "Ebm"],
	]},
	# The circus march's opening strain, the chromatic run, twice with its two endings, after
	# https://abcnotation.com/tunePage?a=trillian.mit.edu/~jc/music/abc/mirror/musicaviva.com/anon/gladiators-phil/gladiators-phil-1/0000
	# whose writer typed it from memory; it matches the tune as I know it. The rest of the march
	# is left out. Chords mine.
	{name = "Vjezd gladiátorů (Fučík)", category = "Czech classics", difficulty = 5, key = "D", notes = [
		["D5", 0.5, "D"], ["C#5", 0.5], ["C5", 0.25], ["C#5", 0.25], ["C5", 0.25], ["B4", 0.25], ["A#4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4", 0.5],
		["B4", 0.5, "Bm"], ["A#4", 0.5], ["A4", 0.25], ["A#4", 0.25], ["A4", 0.25], ["G#4", 0.25], ["G4", 0.5], ["F#4", 0.5], ["F4", 0.5], ["F#4*", 0.5],
		["A4", 0.5, "A"], ["E4", 0.25], ["E4", 0.25], ["D#4", 0.5], ["E4", 0.5], ["A4", 0.5], ["E4", 0.25], ["E4", 0.25], ["D4", 0.5], ["E4", 0.5],
		["A3", 0.25], ["B3", 0.25], ["C#4", 0.25], ["D4", 0.25], ["E4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["G#4", 0.25], ["A4", 0.25], ["B4", 0.25], ["C5", 0.25], ["C#5", 0.25], ["B4", 0.5], ["A4*", 0.5],
		["D5", 0.5, "D"], ["C#5", 0.5], ["C5", 0.25], ["C#5", 0.25], ["C5", 0.25], ["B4", 0.25], ["A#4", 0.5], ["A4", 0.5], ["G#4", 0.5], ["A4", 0.5],
		["B4", 0.5, "Bm"], ["A#4", 0.5], ["A4", 0.25], ["A#4", 0.25], ["A4", 0.25], ["G#4", 0.25], ["G4", 0.5], ["F#4", 0.5], ["F4", 0.5], ["F#4*", 0.5],
		["A4", 0.5, "A"], ["E4", 0.25], ["E4", 0.25], ["D#4", 0.5], ["E4", 0.5], ["A4", 0.5], ["E4", 0.25], ["E4", 0.25], ["D4", 0.5], ["E4", 0.5],
		["A3", 0.25], ["B3", 0.25], ["C#4", 0.25], ["D4", 0.25], ["E4", 0.25], ["F#4", 0.25], ["G4", 0.25], ["G#4", 0.25], ["A4", 0.25], ["B4", 0.25], ["C5", 0.25], ["C#5", 0.25], ["D5*", 1, "D"],
	]},
	# The anthem as the 1998 law prints it (Škroup's tune in Cmíral's 1933 setting), after the
	# LilyPond source on https://commons.wikimedia.org/wiki/File:Kde_domov_můj.mid , a major third
	# down from E so that it sits on C4 to C5. Its opening rest is dropped, so the first bar is a
	# pickup. "Skví" and "ráj", tied over two and a half beats, are held two, with a half-beat
	# breath. Chords mine (the score has none).
	{name = "Kde domov můj (Škroup)", category = "Czech classics", difficulty = 3, pickup = 3, notes = [
		["G4", 2, "C"], ["A4", 0.5], ["G4", 0.5],
		["D4", 1, "G"], ["F4", 2], ["E4", 0.5], ["D4", 0.5],
		["C4*", 2, "C"], ["r", 1], ["C4", 0.5], ["C4", 0.5],
		["C4", 0.75, "F"], ["F4", 0.25], ["F4", 2], ["G4", 0.5], ["A4", 0.5],
		["G4", 0.5, "C"], ["E4", 0.5], ["C4", 1], ["r", 1], ["C4", 0.5], ["C4", 0.5],
		["C4", 0.5, "F"], ["F4", 0.5], ["F4", 0.5], ["A4", 0.5], ["C5", 1], ["B4", 0.5], ["A4", 0.5],
		["A4", 1], ["G4*", 1, "C"], ["r", 1], ["G4", 0.5], ["G4", 0.5],
		["G4", 2], ["r", 0.5], ["A4", 0.5], ["G4", 0.5, "G"], ["F4", 0.5],
		["E4*", 2, "C"], ["r", 1], ["G4", 0.5], ["G4", 0.5],
		["B4", 2, "G"], ["r", 0.5], ["A4", 0.5], ["G4", 0.5], ["F4", 0.5],
		["E4*", 2, "C"], ["r", 1], ["E4", 0.5], ["E4", 0.5],
		["E4", 1.5, "E"], ["E4", 0.5], ["E4", 1], ["F#4", 0.5], ["G#4", 0.5],
		["G#4", 0.5], ["A4", 0.5, "Am"], ["A4", 1], ["r", 1], ["A4", 0.5], ["A4", 0.5],
		["A4", 0.5], ["G4", 0.5, "C"], ["G4", 2], ["F4", 0.5, "G"], ["G4", 0.5],
		["E4", 1, "C"], ["C5*", 2], ["B4", 0.5], ["A4", 0.5],
		["A4", 1, "F"], ["G4", 2, "C"], ["D4", 0.5, "G"], ["E4", 0.5],
		["C4*", 2, "C"], ["r", 2],
	]},
	# Slavonic Dance Op. 72 No. 2, in E minor: its first sixteen bars, after the excerpt on
	# https://commons.wikimedia.org/wiki/File:Dvorak_Slavonic_Dance_Op_72,_No._3.png (its
	# description says No. 2, and it is), an octave down and with doubled note values (3/8 to
	# 3/4). The first bar's opening rest is dropped, so its five notes are a pickup; bar 8's E,
	# tied over two and a half beats, is held three, through its rest. Its cadence chords (B7 as
	# B, F#7 as F#); the others mine.
	{name = "Slavonic Dance Op. 72 No. 2 (Dvořák)", category = "Czech classics", difficulty = 4, key = "Em", meter = 3, pickup = 2.5, notes = [
		["B4", 0.5, "Em"], ["C5", 0.5], ["B4", 0.5], ["A#4", 0.5], ["B4", 0.5],
		["C5", 2, "Am"], ["B4", 1],
		["A4", 1.5], ["G4", 0.5], ["F#4", 0.5], ["E4", 0.5],
		["F#4*", 3, "B"],
		["r", 0.5], ["F#4", 0.5], ["G4", 0.5], ["F#4", 0.5], ["E#4", 0.5], ["F#4", 0.5],
		["A4", 2], ["G4", 1],
		["G4", 1.5], ["F#4", 0.5], ["E4", 0.5], ["D#4", 0.5],
		["E4*", 3, "C"],
		["r", 0.5], ["B4", 0.5, "Em"], ["C5", 0.5], ["B4", 0.5], ["A#4", 0.5], ["B4", 0.5],
		["D5", 2, "A"], ["C#5", 1],
		["C5", 1.5, "Am"], ["G4", 0.5], ["F#4", 0.5, "F#"], ["E4", 0.5],
		["G4", 1, "B"], ["F#4*", 2],
		["r", 0.5], ["G4", 0.5, "Em"], ["A4", 0.5], ["G4", 0.5], ["F#4", 0.5], ["G4", 0.5],
		["B4", 2], ["A4", 1],
		["G4", 2], ["F#4", 1, "B"],
		["E4*", 3, "Em"],
	]},
	# The opera's opening chorus, after its melody line as printed in a 1909 edition of the
	# principal airs, https://commons.wikimedia.org/wiki/File:Bartered_Bride_piano_score_1909.jpg
	# a fifth down from G so that it sits on C4 to C5: the refrain once (its repeat left out),
	# then the two halves of the middle part, each once. Chords mine (the page has none).
	{name = "Proč bychom se netěšili (Smetana)", category = "Czech classics", difficulty = 3, meter = 2, notes = [
		["C4", 1, "C"], ["D4", 1],
		["E4", 1.5], ["F4", 0.5],
		["E4", 0.5], ["D4", 0.5], ["D4", 0.5], ["E4", 0.5],
		["D4", 0.5, "G"], ["C4*", 0.5], ["C4", 0.5], ["D4", 0.5],
		["E4", 1, "C"], ["F4", 1],
		["G4", 1.5], ["A4", 0.5],
		["G4", 0.5, "G"], ["F4", 0.5], ["F4", 0.5], ["G4", 0.5],
		["F4", 0.5, "C"], ["E4*", 0.5], ["E4", 0.5], ["G4", 0.5],
		["C5", 1], ["B4", 1],
		["B4", 1.5, "G"], ["A4", 0.5],
		["A4", 0.5, "Am"], ["G4", 0.5], ["G4", 0.75], ["A4", 0.25],
		["G4", 0.5, "G"], ["F4", 0.5], ["F4*", 1],
		["G4", 1], ["F4", 1],
		["F4", 1.5, "C"], ["E4", 0.5],
		["E4", 0.5], ["D4", 0.5], ["D4", 1],
		["A4", 0.5, "F"], ["G4", 0.5], ["G4*", 1],
		["G4", 1, "G"], ["F4", 1],
		["F4", 1.5, "C"], ["E4", 0.5],
		["E4", 0.5], ["D4", 0.5], ["D4", 0.75], ["E4", 0.25],
		["D4", 0.5, "G"], ["C4", 0.5, "C"], ["C4*", 1],
		["A4", 1, "Dm"], ["A4", 1],
		["A4", 1], ["A4", 1],
		["Bb4", 0.5, "Gm"], ["A4", 0.5], ["A4", 0.5], ["G4", 0.5],
		["G4", 1, "C"], ["G4*", 1],
		["A4", 1, "F"], ["A4", 1],
		["A4", 1], ["A4", 1],
		["G4", 0.5, "C"], ["F4", 0.5], ["F4", 0.5], ["E4", 0.5],
		["E4", 1], ["E4*", 1],
		["F4", 1, "F"], ["F4", 1],
		["F4", 1], ["E4", 1, "C"],
		["E4", 0.5], ["D4", 0.5], ["D4", 0.5], ["A4", 0.5],
		["A4", 0.5, "F"], ["G4", 0.5], ["G4*", 1],
		["G4", 1, "G"], ["F4", 1],
		["F4", 1], ["E4", 1, "C"],
		["E4", 0.5], ["D4", 0.5], ["D4", 0.5], ["E4", 0.5],
		["D4", 0.5, "G"], ["C4", 0.5, "C"], ["C4*", 1],
	]},
]
