extends Node
## Dev check, not part of the game. Added by game.gd only when asked for on the command line:
##   -- --autoplay        plays the song by itself, flubbing one branch on purpose so a fall
##                        and a magic banana get exercised, then quits two seconds after the end
##   -- --shots=<dir>     saves a screenshot every 2 s into <dir>

const Game := preload("res://scripts/game.gd")
const FLUB_AT := 5         # the bot plays a wrong note when reaching for this branch, once
const SHOT_EVERY_MS := 2000.0

@onready var game: Game = get_parent()

var _autoplay := false
var _shots_dir := ""
var _perf := false
var _next_perf := 0.0
var _next_shot := 0.0
var _shot_n := 0
var _held := -1
var _flubbed := false
var _ended_at := 0.0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--autoplay":
			_autoplay = true
		elif arg.begins_with("--shots="):
			_shots_dir = arg.trim_prefix("--shots=")
		elif arg == "--perf":
			_perf = true
	if _autoplay:
		game.start.call_deferred()


func _process(_delta: float) -> void:
	var now := Game.now_ms()
	if _autoplay:
		_play(now)
	if _perf and now >= _next_perf:
		_next_perf = now + 1000.0
		print("draw_ms=%.1f fps=%d process_ms=%.1f draw_calls=%d primitives=%d" % [game.view.draw_us / 1000.0, Engine.get_frames_per_second(),
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
				_press(game.notes[game.cur].midi, now)
		Game.State.HANG:
			if now >= game.windows(game.cur, game.grab_t).end:
				_release(now)
		Game.State.AIR, Game.State.REST:
			if now >= game.windows(game.cur, game.grab_t).next:
				var j := game.cur + 1
				var m := game.notes[j].midi
				if j == FLUB_AT and not _flubbed:
					_flubbed = true
					m += 2
				_press(m, now)
		Game.State.FALL, Game.State.BOUNCE:
			if _held >= 0:
				_release(now)
		_:   # WON, OVER
			if _ended_at == 0.0:
				_ended_at = now
				print("autoplay ended: ", Game.State.keys()[game.state], " falls=", game.falls, " bananas=", game.bananas)
			elif now - _ended_at > 2000.0:
				get_tree().quit()


func _press(m: int, now: float) -> void:
	_held = m
	game.note_on(m, now)


func _release(now: float) -> void:
	game.note_off(_held, now)
	_held = -1
