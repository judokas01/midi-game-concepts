extends Node
## Dev check, not part of the game. Added by game.gd only when asked for on the command line:
##   -- --autoplay        plays the song by itself, then quits two seconds after the end. It
##                        plays one wrong note and holds one branch until it breaks, on
##                        purpose, so falls, cracks and magic bananas get exercised too
##   -- --chords          plays the treble clef with chords instead. With --autoplay the bot
##                        plays each chord before the note on even branches and after it on
##                        odd ones, right under the note, and leaves one chord out, so a log
##                        gets run into too
##   -- --chords-only     the gorilla plays the tune and the bot only the chords: on the beat,
##                        leaving one out; in learn mode once the gorilla waits, one wrong first
##   -- --learn           learn mode: the bot plays each next note a moment after the last
##                        grab, one of them wrong, and lets go at once
##   -- --drill           the chord drill, drawing on every kind of chord
##   -- --song=<n>        plays song n of Song.library(), counting from 0, instead of the first
##   -- --perf            prints fps and draw calls once a second
##   -- --shots=<dir>     saves a screenshot every second into <dir>

const Game := preload("res://scripts/game.gd")
const Song := preload("res://scripts/song.gd")
const Hud := preload("res://scripts/hud.gd")
const Drill := preload("res://scripts/drill.gd")
const FLUB_AT := 5         # the bot plays a wrong note when reaching for this branch, once
const OVERHOLD_AT := 20    # and hangs on to this one until it breaks, once
const CHORDLESS_AT := 9    # with chords, it plays the first log from this branch on without its chord, once
const SHOT_EVERY_MS := 1000.0
const PAUSE_MS := 400.0    # in learn mode and the drill, the bot thinks this long before each note or chord

@onready var game: Game = get_parent()

var _autoplay := false
var _shots_dir := ""
var _perf := false
var _next_perf := 0.0
var _next_shot := 0.0
var _shot_n := 0
var _held := -1
var _pressed_at := -INF
var _skipped := -1         # the branch whose chord was left out
var _flubbed := false
var _overheld := false
var _chordless := false
var _ended_at := 0.0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--autoplay":
			_autoplay = true
		elif arg.begins_with("--shots="):
			_shots_dir = arg.trim_prefix("--shots=")
		elif arg == "--perf":
			_perf = true
		elif arg == "--chords":
			game.set_style.call_deferred(Song.Clef.TREBLE, true)
		elif arg == "--chords-only":
			game.set_style.call_deferred(Song.Clef.TREBLE, true, true)
		elif arg == "--learn":
			game.set_mode.call_deferred(Hud.Mode.LEARN)
		elif arg == "--drill":
			game.set_drill_kinds.call_deferred(Drill.Kind.values())
			game.set_mode.call_deferred(Hud.Mode.DRILL)
		elif arg.begins_with("--song="):
			game.set_song.call_deferred(int(arg.trim_prefix("--song=")))
	if _autoplay:
		game.start.call_deferred()


func _process(_delta: float) -> void:
	var now := Game.now_ms()
	if _autoplay:
		_play(now)
	if _perf and now >= _next_perf:
		_next_perf = now + 1000.0
		print("fps=%d process_ms=%.1f draw_calls=%d primitives=%d" % [Engine.get_frames_per_second(),
			Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
			Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
			Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	if _shots_dir != "" and now >= _next_shot:
		_next_shot = now + SHOT_EVERY_MS
		var path := "%s/shot_%02d.png" % [_shots_dir, _shot_n]
		get_viewport().get_texture().get_image().save_png(path)
		print("shot ", path, " state=", Game.State.keys()[game.state], " branch=", game.done_up_to)
		_shot_n += 1


func _play(now: float) -> void:
	if game.state == Game.State.WON or game.state == Game.State.OVER:
		if _ended_at == 0.0:
			_ended_at = now
			var missed := "" if game.mode == Hud.Mode.PLAY else " misses=%d" % game.misses
			print("autoplay ended: ", Game.State.keys()[game.state], " falls=", game.falls, " bananas=", game.bananas, missed)
		elif now - _ended_at > 2000.0:
			get_tree().quit()
		return
	if game.by_itself:
		_play_chords(now)
	elif game.mode != Hud.Mode.PLAY:
		_learn(now)
	else:
		_play_song(now)


func _play_song(now: float) -> void:
	match game.state:
		Game.State.WAIT:
			if game.started and _held < 0:
				_press(game.cur, game.notes[game.cur].midi, now)
		Game.State.HANG:
			var hang_on := game.cur == OVERHOLD_AT and not _overheld
			if not hang_on and now >= game.windows(game.cur, game.grab_t).end:
				_release(now)
		Game.State.AIR, Game.State.REST:
			if _held < 0 and now >= game.windows(game.cur, game.grab_t).next:
				var j := game.cur + 1
				var m := game.notes[j].midi
				if j == FLUB_AT and not _flubbed:
					_flubbed = true
					m += 2
				_press(j, m, now)
		Game.State.FALL, Game.State.BOUNCE:
			_overheld = _overheld or game.cur == OVERHOLD_AT
			if _held >= 0:
				_release(now)


## Learn mode: a moment after each grab, the next note (and its chord), let go of at once.
func _learn(now: float) -> void:
	if not game.started:
		return
	if _held >= 0:
		if now - _pressed_at > 120.0:
			_release(now)
		return
	if now - _pressed_at < PAUSE_MS:
		return
	var j: int = game.cur if game.state == Game.State.WAIT else game.cur + 1
	if j >= game.notes.size():
		return
	var m: int = game.notes[j].midi
	if j == FLUB_AT and not _flubbed:
		_flubbed = true
		m += 2
	_press(j, m, now)


## The gorilla plays the tune; the bot strikes each log's chord. When playing, on the beat,
## and once not at all; in learn mode and the drill once the gorilla waits, once wrong first.
func _play_chords(now: float) -> void:
	if not game.started:
		return
	var j: int = game.cur if game.state == Game.State.WAIT else game.cur + 1
	if j >= game.notes.size() or not game.notes[j].log_up:
		return
	var chord: Song.Chord = game.notes[j].chord
	if game.state == Game.State.WAIT:
		if now - _pressed_at > PAUSE_MS:
			_strike(chord.midi, now)
		return
	if not game.state in [Game.State.HANG, Game.State.AIR, Game.State.REST]:
		return
	var w: Dictionary = game.windows(game.cur, game.grab_t)
	if game.mode == Hud.Mode.PLAY:
		if now < w.next or j == _skipped:
			return
		if j >= CHORDLESS_AT and not _chordless:
			_chordless = true
			_skipped = j
			return
		_strike(chord.midi, now)
	elif now >= w.end + PAUSE_MS and now - _pressed_at > PAUSE_MS:
		if j >= FLUB_AT and not _flubbed:
			_flubbed = true
			_strike(chord.midi.map(func(m: int) -> int: return m + 2), now)   # a step up: another chord
		else:
			_strike(chord.midi, now)


## Plays `m` for branch `j`, and the chord of its log if one stands.
func _press(j: int, m: int, now: float) -> void:
	var chord: Song.Chord = game.notes[j].chord if game.notes[j].log_up else null
	if chord and j >= CHORDLESS_AT and not _chordless:
		_chordless = true
		chord = null
	var under: Array = chord.midi.map(func(c: int) -> int: return _under(c, game.notes[j].midi)) if chord else []
	if chord and j % 2 == 0:
		_strike(under, now)
	_held = m
	_pressed_at = now
	game.note_on(m, now)
	if chord and j % 2 == 1:
		_strike(under, now)


## `c` moved by octaves to just under the note `m`: the chord as close under the tune as it
## goes, often across middle C, as only notes below the next branch's are the left hand's.
func _under(c: int, m: int) -> int:
	return m - 1 - posmod(m - 1 - c, 12)


## A chord's `pitches`, struck and let go at once.
func _strike(pitches: Array, now: float) -> void:
	_pressed_at = now
	for c: int in pitches:
		game.note_on(c, now)
	for c: int in pitches:
		game.note_off(c, now)


func _release(now: float) -> void:
	game.note_off(_held, now)
	_held = -1
