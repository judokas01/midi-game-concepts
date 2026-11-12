extends Node
## Dev check, not part of the game. Added by game.gd only when asked for on the command line:
##   -- --autoplay        plays the song by itself, then quits two seconds after the end. It
##                        plays one wrong note and holds one branch until it breaks, on
##                        purpose, so falls, cracks and magic bananas get exercised too
##   -- --chords          plays the treble clef with chords instead. With --autoplay the bot
##                        plays each chord before the note on even branches and after it on
##                        odd ones, right under the note, and leaves one chord out, so a log
##                        gets run into too
##   -- --bass            plays the bass clef instead
##   -- --chords-only     the gorilla plays the tune and the bot only the chords: on the beat,
##                        leaving one out; in learn mode once the gorilla waits, one wrong first
##   -- --learn           learn mode: the bot plays each next note a moment after the last
##                        grab, one of them wrong, and lets go at once
##   -- --drill           the chord drill, dealing every chord the chord menu offers
##   -- --song=<n>        plays song n of Song.library(), counting from 0, instead of the first
##   -- --pause           with --autoplay, pauses with Esc three times, once each: mid-fall,
##                        hanging on branch PAUSE_AT and in the first rest. It lets go of its
##                        note while paused, as a player reaching for Esc would, steps the tempo
##                        up with the right arrow and continues with Space a second later
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
const PAUSE_AT := 10       # with --pause, it pauses while hanging on this branch
const PAUSE_FOR_MS := 1000.0       # and stays paused this long
const PAUSE_DEADLINE_MS := 500.0   # Esc that hasn't paused the game by then didn't work

@onready var game: Game = get_parent()

var _autoplay := false
var _pause := false
var _paused_in := {}       # the states it has paused in already, each only once
var _pausing_since := 0.0  # when it pressed Esc; 0 while not pausing
var _paused_at := 0.0      # when it saw the game paused
var _resume_sent := false
var _progress := 0.0       # the most of the level the game has said is done
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
	process_mode = Node.PROCESS_MODE_ALWAYS   # works the pause menu, and keeps taking screenshots, while the game is paused
	for arg in OS.get_cmdline_user_args():
		if arg == "--autoplay":
			_autoplay = true
		elif arg == "--pause":
			_pause = true
		elif arg.begins_with("--shots="):
			_shots_dir = arg.trim_prefix("--shots=")
		elif arg == "--perf":
			_perf = true
		elif arg == "--chords":
			game.set_style.call_deferred(Song.Clef.TREBLE, true)
		elif arg == "--bass":
			game.set_style.call_deferred(Song.Clef.BASS, false)
		elif arg == "--chords-only":
			game.set_style.call_deferred(Song.Clef.TREBLE, true, true)
		elif arg == "--learn":
			game.set_mode.call_deferred(Hud.Mode.LEARN)
		elif arg == "--drill":
			game.set_drill.call_deferred(Drill.all_chords(), Drill.COUNT)
			game.set_mode.call_deferred(Hud.Mode.DRILL)
		elif arg.begins_with("--song="):
			game.set_song.call_deferred(int(arg.trim_prefix("--song=")))
	if _autoplay:
		game.start.call_deferred()


func _process(_delta: float) -> void:
	var now := Game.now_ms()
	if _autoplay:
		if _pausing_since > 0.0:
			_work_pause(now)
		elif not _start_pause(now):
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
	_check_progress()
	if game.state == Game.State.WON or game.state == Game.State.OVER:
		if _ended_at == 0.0:
			_ended_at = now
			var missed := "" if game.mode == Hud.Mode.PLAY else " misses=%d" % game.misses
			print("autoplay ended: ", Game.State.keys()[game.state], " falls=", game.falls, " bananas=", game.bananas, missed)
		elif now - _ended_at > 2000.0:
			if game.state == Game.State.WON and game.level_progress() < 1.0:
				push_error("progress ended at %.3f, not 1, with the gorilla in its nest" % game.level_progress())
			_check_counters()
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


## The counters stay readable at the end of the song: the percentage under the progress line
## clear of the pill, and bananas flying to the pill drawn over it, not under it.
func _check_counters() -> void:
	var pill: Control = game.hud.get_node("Pill")
	var label: Rect2 = game.hud.get_node("Progress").label_rect()
	if label.intersects(pill.get_global_rect()):
		push_error("the progress label %s is under the pill %s" % [label, pill.get_global_rect()])
	if game.hud.get_node("Flyers").get_index() < pill.get_index():
		push_error("bananas fly under the pill")


## The progress line's share of the level only ever grows, falls, swings back and pauses included.
func _check_progress() -> void:
	var p: float = game.level_progress()
	if p < _progress:
		push_error("progress went back from %.3f to %.3f" % [_progress, p])
	_progress = p


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


## With --pause: presses Esc the first time the gorilla falls (still in the air), hangs on
## branch PAUSE_AT, or rests. True if it did.
func _start_pause(now: float) -> bool:
	if not _pause or not game.started:
		return false
	var s := game.state
	var due := s == Game.State.REST or (s == Game.State.HANG and game.cur == PAUSE_AT) \
		or (s == Game.State.FALL and game.land_t == 0.0)
	if not due or _paused_in.has(s):
		return false
	_paused_in[s] = true
	print("paused state=%s cur=%d" % [Game.State.keys()[s], game.cur])
	_key(KEY_ESCAPE)
	_pausing_since = now
	_paused_at = 0.0
	_resume_sent = false
	return true


## While pausing: once the game is paused, lets go of the note; a second later steps the tempo
## up and continues; once it runs again, says where the gorilla is.
func _work_pause(now: float) -> void:
	var paused := get_tree().paused
	if _resume_sent:
		if not paused:
			print("resumed state=%s cur=%d bpm=%d" % [Game.State.keys()[game.state], game.cur, roundi(game.bpm)])
			_pausing_since = 0.0
		return
	if not paused:
		if now - _pausing_since > PAUSE_DEADLINE_MS:
			print("autoplay: Esc did not pause")
			get_tree().quit()
		return
	if _paused_at == 0.0:
		_paused_at = now
		if _held >= 0:
			_release(now)   # a player lets go to reach for Esc
	elif now - _paused_at >= PAUSE_FOR_MS:
		_key(KEY_RIGHT)
		_key(KEY_SPACE)
		_resume_sent = true


## Presses and lets go of computer key `code`, as if typed.
func _key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var key := InputEventKey.new()
		key.keycode = code
		key.pressed = pressed
		Input.parse_input_event(key)
