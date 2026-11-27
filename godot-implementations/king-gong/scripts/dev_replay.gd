extends Node
## Dev check, not part of the game. Added by game.gd only when asked for on the command line:
##   -- --replay=<file>   plays a bug report back (a file in bug-reports/, see run_record.gd): the
##                        song or the drill's round with the report's settings, then every note,
##                        pause and setting change at the time it came, each note with the time
##                        it was stamped with. A pause lasts PAUSE_MS at most. It ends paused
##                        where the report was written, the player's words in the pause menu,
##                        and says whether the game stands as it did then:
##                        "replay: as reported (HANG on branch 12, falls 1, bananas 2, misses 0)",
##                        or "replay: differs from the report: falls 2, reported 1"
##   -- --quit            with --replay, quits once it has said so
## replay-bug.cmd runs it.
##
## The game moves on once a frame, and frames don't fall where they fell when the report's run
## was played, so a note can come a frame before the game stands where it stood for it: the
## moment the gorilla was ready (WAIT, after a magic banana, a pause or at the stump), or let go
## in the frame the gorilla fell. Each note waits for the game to stand as the report says it
## did (its state and branch): a note played waiting holds up to HOLD_MAX_MS, and everything
## after it comes that much later, as waiting isn't timed; any other note holds a few frames at
## most (NUDGE_MS), keeping the time it was stamped with. One that never gets there plays anyway
## and is said: "replay: a note came in AIR on 9, in the report in FALL on 9". So is a pause
## in another state than the report's: "replay: paused in AIR on 10, the report in HANG on 10".

const Game := preload("res://scripts/game.gd")
const Song := preload("res://scripts/song.gd")
const Hud := preload("res://scripts/hud.gd")
const RunRecord := preload("res://scripts/run_record.gd")
const PAUSE_MS := 1000.0   # a pause in the report lasts no longer than this
const SETTLE_MS := 500.0   # after the last input, before checking how the game stands
const HOLD_MAX_MS := 5000.0   # a note played waiting holds for the gorilla to wait no longer than this
const NUDGE_MS := 50.0        # any other note, for the game to stand as it did for it
const SETTINGS := ["bpm", "practice", "tick", "backing", "labels", "hint", "keyboard_hint", "source"]

@onready var game: Game = get_parent()

var _rec := {}
var _events: Array = []
var _next := 0            # the next event to play
var _t0 := -1.0           # the replay's start, the report's 0; < 0 until it starts
var _shift := 0.0         # ms taken out of long pauses so far
var _held_since := 0.0    # when the next event started holding for the gorilla to wait; 0 when not
var _done_at := 0.0       # when the last event played
var _checked := false
var _quit := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # pauses and continues the game
	process_priority = -100   # before the game's _process: a frame's notes come before its update, as played ones do
	var path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--replay="):
			path = arg.trim_prefix("--replay=")
		elif arg == "--quit":
			_quit = true
	if not FileAccess.file_exists(path) and FileAccess.file_exists(RunRecord.DIR + "/" + path):
		path = RunRecord.DIR + "/" + path   # a report's file name alone
	_rec = RunRecord.read(path)
	if _rec.is_empty() or not _rec.has("settings"):
		push_error("replay: can't read a bug report from %s" % path)
		get_tree().quit(1)
		return
	_events = _rec.get("events", [])
	print("replay: %s, %d events: \"%s\"" % [path.get_file(), _events.size(), _rec.get("report", "")])
	_start.call_deferred()


## The report's settings, then the run, as Start would.
func _start() -> void:
	var s: Dictionary = _rec.settings
	var mode: Hud.Mode = Hud.Mode[s.mode]
	game.set_style(Song.Clef[s.clef], s.chords, s.by_itself)
	if mode == Hud.Mode.DRILL:
		game.set_drill(s.drill.chords, int(s.drill.count), int(s.drill.beats))
	else:
		var song := _song_of(s)
		if song < 0:
			push_error("replay: no song %s in the library" % s.get("song", "?"))
			get_tree().quit(1)
			return
		game.set_song(song)
	game.set_mode(mode)
	for kind: String in SETTINGS:
		if s.has(kind):
			game.apply_setting(kind, s[kind])
	if mode == Hud.Mode.DRILL:
		game.next_deal = s.drill.entries
	game.start()
	_t0 = game.record.start_ms
	if game.level_print() != _rec.get("level", []):
		print("replay: the level isn't as it was: the song has changed since, so it may not play out the same")


func _process(_delta: float) -> void:
	if _t0 < 0.0 or _checked:
		return
	var now := Game.now_ms()
	while _next < _events.size():
		var event: Array = _events[_next]
		var at := _t0 + _shift + float(event[0])
		if at > now:
			break
		var hold := _hold_for(event)
		if hold > 0.0:
			if _held_since == 0.0:
				_held_since = now
			if now - _held_since < hold:
				break
			print("replay: a note came in %s on %d, in the report in %s on %d (%.0f ms)"
				% [Game.State.keys()[game.state], game.cur, event[3], int(event[4]), event[0]])
		if _held_since > 0.0:
			if _waited(event):
				_shift += now - at   # everything after it comes that much later too
				at = now
			_held_since = 0.0
		_next += 1
		_play(event, at, _next - 1)
	if _next < _events.size():
		return
	if _done_at == 0.0:
		_done_at = now
	elif now - _done_at > SETTLE_MS:
		_check()


## Event `i`, `event`, due at `at`.
func _play(event: Array, at: float, i: int) -> void:
	match event[1]:
		"on":
			game.note_on(int(event[2]), at)
		"off":
			game.note_off(int(event[2]), at)
		"pause":
			var here := "%s on %d" % [Game.State.keys()[game.state], game.cur]
			var there := "%s on %d" % [event[2], int(event[3])]
			if here != there:
				print("replay: paused in %s, the report in %s" % [here, there])
			if game.can_pause():
				game.pause()
			else:
				print("replay: can't pause at %.0f ms in %s" % [event[0], here])
			_shorten_pause(i)
		"resume":
			if get_tree().paused:
				game.resume()
		_:
			game.apply_setting(event[1], event[2])


## How long `event`, a note, may hold for the game to stand as it did when the note came; 0 if
## it does, or for anything but a note.
func _hold_for(event: Array) -> float:
	if not event[1] in ["on", "off"]:
		return 0.0
	if game.state == Game.State[event[3]] and game.cur == int(event[4]):
		return 0.0
	return HOLD_MAX_MS if _waited(event) else NUDGE_MS


## A note played while the gorilla waited: untimed.
func _waited(event: Array) -> bool:
	return event[1] == "on" and event[3] == "WAIT"


## The pause at event `i` lasts PAUSE_MS at most: to its resume, or to the last event if
## the report was written in it.
func _shorten_pause(i: int) -> void:
	var end := float(_events[-1][0])
	for k in range(i + 1, _events.size()):
		if _events[k][1] == "resume":
			end = float(_events[k][0])
			break
	var long := end - float(_events[i][0])
	if long > PAUSE_MS:
		_shift -= long - PAUSE_MS


## How the game stands, against how it stood when the report was written.
func _check() -> void:
	_checked = true
	var want: Dictionary = _rec.get("at_report", {})
	var got := game.snapshot()
	var off: Array[String] = []
	for key: String in want:
		var w: Variant = want[key]
		var g: Variant = got.get(key)
		var same: bool = absf(float(g) - w) <= (0.01 if key == "progress" else 0.0) if w is float else g == w
		if not same:
			off.append("%s %s, reported %s" % [key, JSON.stringify(g), JSON.stringify(w)])
	var verdict := "as reported (%s on branch %d, falls %d, bananas %d, misses %d)" % [got.state, got.branch,
		got.falls, got.bananas, got.misses] if off.is_empty() else "differs from the report: " + "; ".join(off)
	print("replay: ", verdict)
	if get_tree().paused:
		game.hud.show_pause_note("Replay %s\n\"%s\"" % [verdict, _rec.get("report", "")])
	if _quit:
		get_tree().quit()


## The report's song in the library, by its name, else by its number; -1 if neither is there.
func _song_of(s: Dictionary) -> int:
	var songs := Song.library()
	for k in songs.size():
		if songs[k].name == s.get("song"):
			return k
	var k := int(s.get("song_number", -1))
	return k if k >= 0 and k < songs.size() else -1
