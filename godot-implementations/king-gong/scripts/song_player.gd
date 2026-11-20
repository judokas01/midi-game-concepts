extends Node
## Plays a song on the piano: its tune, its chords (each voiced below the note it starts on,
## ringing until the next chord comes in), or both. Each sound starts so that it is heard when
## it is due, by the audio clock (PianoSound.due_now()).
##
## Inside a level the gorilla's grabs drive it: grab() sounds a branch's part as the gorilla
## takes hold of it, so backing follows the player the way the beat tick does; expect()
## schedules the next branch ahead when its grab is certain, so it is heard right on the beat.
## Outside a level, play() plays the whole song from its start at the tempo. For Listen,
## backing, and the library's preview.

const Song := preload("res://scripts/song.gd")
const PianoSound := preload("res://scripts/piano_sound.gd")
const VOLUME_DB := -10.0     # under the player's own instrument
const TUNE_VELOCITY := 96
const CHORD_VELOCITY := 60   # each of its notes: three of them under the tune, which stays on top


## One thing the piano plays: a branch's note, or the chord that starts on it.
class Sound:
	var branch: int
	var beat: float          # when it starts, in the song's beats
	var beats: float         # how long a tune note rings; for a chord, to the next chord
	var midi: Array[int] = []
	var chord := false

	func _init(on: int, at: float, length: float, notes: Array[int], is_chord: bool) -> void:
		branch = on
		beat = at
		beats = length
		midi = notes
		chord = is_chord


var sounds: Array[Sound] = []         # in the order they come
var played: Array[Dictionary] = []    # {branch, chord, heard_ms} per sound started, for the dev checks

var _branch_beat: Array[float] = []   # each branch's beat
var _chord_on: Array = []             # each branch's chord sound: the one it starts, or the one it is under (null: none)
var _beat_ms := 1000.0
var _pending: Array[Dictionary] = []  # {sound, due}: to start once due, in the order they come
var _started_at := {}                 # sound -> the due time it was last started for
var _ringing: Array[Dictionary] = []  # {ids, off_ms, chord}: what sounds, and when it lets go (INF: a chord, until the next)
var _piano: PianoSound


func _ready() -> void:
	_piano = PianoSound.new()
	_piano.volume_db = VOLUME_DB
	add_child(_piano)


## The song's branches, `notes`, as sounds: on each, the chord that starts there (with
## `chords`) and its note (with `tune`).
func load_song(notes: Array[Song.Note], tune := true, chords := true) -> void:
	stop()
	sounds.clear()
	played.clear()
	_started_at.clear()
	_branch_beat.clear()
	_chord_on.clear()
	var end := notes[-1].beat + notes[-1].beats
	var under: Sound = null
	for j in notes.size():
		var n := notes[j]
		_branch_beat.append(n.beat)
		if n.chord and chords:
			var until := end
			for k in range(j + 1, notes.size()):
				if notes[k].chord:
					until = notes[k].beat
					break
			under = Sound.new(j, n.beat, until - n.beat, voiced(n.chord, n.midi), true)
			sounds.append(under)
		_chord_on.append(under)
		if tune:
			var note: Array[int] = [n.midi]
			sounds.append(Sound.new(j, n.beat, n.beats, note, false))


## `chord` as the bass clef writes it (root position), moved down by octaves until no note of
## it is above the tune's note `under`.
static func voiced(chord: Song.Chord, under: int) -> Array[int]:
	var shift := 0
	while chord.midi.max() + shift > under:
		shift -= 12
	var out: Array[int] = []
	for m in chord.midi:
		out.append(m + shift)
	return out


## The gorilla took hold of `branch` at `grab_ms` (Time.get_ticks_usec's clock, in ms), at a
## beat of `beat_ms`: its sounds are heard from then, unless they were already started for
## that very moment (expected). Nothing else waits to start: the gorilla has gone its own way.
## With no chord ringing (let go at a fall, stopped at a pause), the chord it is under comes
## back too, though it started on an earlier branch.
func grab(branch: int, grab_ms: float, beat_ms: float) -> void:
	_beat_ms = beat_ms
	_pending.clear()
	for s in sounds:
		if s.branch == branch and not is_equal_approx(_started_at.get(s, -INF), grab_ms):
			_pending.append({sound = s, due = grab_ms})
	var under: Sound = _chord_on[branch] if branch < _chord_on.size() else null
	if under and under.branch != branch and not _ringing.any(func(r: Dictionary) -> bool: return r.chord):
		_pending.push_front({sound = under, due = grab_ms})


## `branch` will be grabbed at `at_ms`, for certain: its sounds are heard then.
func expect(branch: int, at_ms: float) -> void:
	for s in sounds:
		if s.branch == branch and not _pending.any(func(p: Dictionary) -> bool: return p.sound == s):
			_pending.append({sound = s, due = at_ms})
	_pending.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.due < b.due)


## Outside a level: the whole song from its start, its first beat heard at `at_ms`.
func play(beat_ms: float, at_ms: float) -> void:
	_beat_ms = beat_ms
	_pending.clear()
	for s in sounds:
		_pending.append({sound = s, due = at_ms + (s.beat - _branch_beat[0]) * beat_ms})


## What sounds is let go, fading as a piano's does, and nothing more starts: a fall.
func let_go() -> void:
	_pending.clear()
	for r: Dictionary in _ringing.duplicate():
		_let_go(r)


## Nothing more starts, and what sounds stops at once: a pause, a restart, the menu.
func stop() -> void:
	_pending.clear()
	_ringing.clear()
	if _piano:
		_piano.silence()


func sounding() -> int:
	return _piano.sounding()


func _process(delta: float) -> void:
	while not _pending.is_empty() and PianoSound.due_now(_pending[0].due, delta):
		var p: Dictionary = _pending.pop_front()
		_start(p.sound, p.due)
	for r: Dictionary in _ringing.duplicate():
		if PianoSound.due_now(r.off_ms, delta):
			_let_go(r)


## A chord lets the last one go as it comes in.
func _start(s: Sound, due: float) -> void:
	if s.chord:
		for r: Dictionary in _ringing.duplicate():
			if r.chord:
				_let_go(r)
	var heard := PianoSound.heard_ms()
	var ids: Array[int] = []
	for m in s.midi:
		ids.append(_piano.strike(m, CHORD_VELOCITY if s.chord else TUNE_VELOCITY))
	_started_at[s] = due
	_ringing.append({ids = ids, off_ms = INF if s.chord else due + s.beats * _beat_ms, chord = s.chord})
	played.append({branch = s.branch, chord = s.chord, heard_ms = heard})


func _let_go(r: Dictionary) -> void:
	for id: int in r.ids:
		_piano.release(id)
	_ringing.erase(r)
