extends Node
## Dev check, not part of the game. Added by game.gd only when asked for on the command line:
##   -- --autoplay        plays the song by itself, then quits two seconds after the end. It
##                        plays one wrong note and holds one branch until it breaks, on
##                        purpose, so falls, cracks and magic bananas get exercised too
##   -- --chords          plays the treble clef with chords instead. With --autoplay the bot
##                        plays each chord before the note on even branches and after it on
##                        odd ones, and leaves one chord out, so a log gets run into too
##   -- --perf            prints fps and draw calls once a second
##   -- --shots=<dir>     saves a screenshot every second into <dir>

const Game := preload("res://scripts/game.gd")
const Song := preload("res://scripts/song.gd")
const FLUB_AT := 5         # the bot plays a wrong note when reaching for this branch, once
const OVERHOLD_AT := 20    # and hangs on to this one until it breaks, once
const CHORDLESS_AT := 9    # with chords, it plays this branch without its chord, once
const SHOT_EVERY_MS := 1000.0

@onready var game: Game = get_parent()

var _autoplay := false
var _shots_dir := ""
var _perf := false
var _next_perf := 0.0
var _next_shot := 0.0
var _shot_n := 0
var _held := -1
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
		_:   # WON, OVER
			if _ended_at == 0.0:
				_ended_at = now
				print("autoplay ended: ", Game.State.keys()[game.state], " falls=", game.falls, " bananas=", game.bananas)
			elif now - _ended_at > 2000.0:
				get_tree().quit()


## Plays `m` for branch `j`, and the chord of its log if one stands.
func _press(j: int, m: int, now: float) -> void:
	var chord: Song.Chord = game.notes[j].chord if game.notes[j].log_up else null
	if chord and j == CHORDLESS_AT and not _chordless:
		_chordless = true
		chord = null
	if chord and j % 2 == 0:
		_strike(chord, now)
	_held = m
	game.note_on(m, now)
	if chord and j % 2 == 1:
		_strike(chord, now)


## The chord, struck and let go at once.
func _strike(chord: Song.Chord, now: float) -> void:
	for c in chord.midi:
		game.note_on(c, now)
	for c in chord.midi:
		game.note_off(c, now)


func _release(now: float) -> void:
	game.note_off(_held, now)
	_held = -1
