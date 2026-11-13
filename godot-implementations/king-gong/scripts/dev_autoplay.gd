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
##   -- --drill           the chord drill, dealing every chord the chord grid offers
##   -- --beats=<n>       with --drill, a chord every n beats instead of Drill.BEATS
##   -- --song=<n>        plays song n of Song.library(), counting from 0, instead of the first
##   -- --pause           with --autoplay, pauses with Esc three times, once each: mid-fall,
##                        hanging on branch PAUSE_AT and in the first rest. It lets go of its
##                        note while paused, as a player reaching for Esc would, steps the tempo
##                        up with the right arrow and continues with Space a second later
##   -- --menu          with --autoplay, works the main menu instead of starting at once: Esc
##                        and Space on the main page, the board for the mode (Play song, or Learn
##                        song or Chord drill with --learn or --drill; on the drill board it also
##                        turns Minor on and Major off, and opens More options and closes it), Esc
##                        back, the board again,
##                        Space to start. At the end it presses the end panel's Menu and checks the
##                        same board is back
##   -- --bpm=<n>         plays at n BPM instead of 60, for a quicker check
##   -- --perf            prints fps and draw calls once a second
##   -- --shots=<dir>     saves a screenshot every second into <dir>

const Game := preload("res://scripts/game.gd")
const Song := preload("res://scripts/song.gd")
const Hud := preload("res://scripts/hud.gd")
const Drill := preload("res://scripts/drill.gd")
const MainMenu := preload("res://scripts/main_menu.gd")
const ChordMenu := preload("res://scripts/chord_menu.gd")
const FLUB_AT := 5         # the bot plays a wrong note when reaching for this branch, once
const OVERHOLD_AT := 20    # and hangs on to this one until it breaks, once
const CHORDLESS_AT := 9    # with chords, it plays the first log from this branch on without its chord, once
const SHOT_EVERY_MS := 1000.0
const PAUSE_MS := 400.0    # in learn mode and the drill, the bot thinks this long before each note or chord
const PAUSE_AT := 10       # with --pause, it pauses while hanging on this branch
const PAUSE_FOR_MS := 1000.0       # and stays paused this long
const PAUSE_DEADLINE_MS := 500.0   # Esc that hasn't paused the game by then didn't work
const MENU_STEP_MS := 600.0        # with --menu, between its steps
const PLANKS := {MainMenu.Page.PLAY: "Play", MainMenu.Page.LEARN: "Learn", MainMenu.Page.DRILL: "Drill"}
const MINORS := ["Cm", "Dm", "Em", "Fm", "Gm", "Am", "Bm"]   # Minor on the white keys
const MODES := {MainMenu.Page.PLAY: Hud.Mode.PLAY, MainMenu.Page.LEARN: Hud.Mode.LEARN, MainMenu.Page.DRILL: Hud.Mode.DRILL}

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
var _drill := false
var _beats: int = Drill.BEATS
var _spacing_checked := false
var _end_state := Game.State.WAIT   # how the song ended
var _poked_end := false             # the bot has played a note on the end panel
var _menu := false
var _menu_page := MainMenu.Page.PLAY  # the board it starts from
var _menu_steps: Array[int] = [0, 1, 2, 3, 4, 5]   # with --drill, 9, 13 and 14 before 2 (the kinds) and 10 to 12 after (More options and back)
var _menu_step := 0
var _menu_next := 0.0
var _menu_back_at := 0.0            # when it pressed the end panel's Menu
var _board_width := 0.0             # the drill board's, before a long line of chords
var _chords := false                # a part with chords was asked for


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
			_chords = true
		elif arg == "--bass":
			game.set_style.call_deferred(Song.Clef.BASS, false)
		elif arg == "--chords-only":
			game.set_style.call_deferred(Song.Clef.TREBLE, true, true)
			_chords = true
		elif arg == "--learn":
			game.set_mode.call_deferred(Hud.Mode.LEARN)
			_menu_page = MainMenu.Page.LEARN
		elif arg == "--menu":
			_menu = true
		elif arg == "--drill":
			_drill = true
		elif arg.begins_with("--beats="):
			_beats = int(arg.trim_prefix("--beats="))
		elif arg.begins_with("--bpm="):
			game.bpm = float(arg.trim_prefix("--bpm="))
		elif arg.begins_with("--song="):
			game.set_song.call_deferred(int(arg.trim_prefix("--song=")))
	if _drill:
		game.set_drill.call_deferred(Drill.all_chords(), Drill.COUNT, _beats)
		game.set_mode.call_deferred(Hud.Mode.DRILL)
		_menu_page = MainMenu.Page.DRILL
		_menu_steps = [0, 1, 9, 13, 14, 2, 10, 11, 12, 3, 4, 5]
	if _autoplay and not _menu:
		game.start.call_deferred()


func _process(_delta: float) -> void:
	var now := Game.now_ms()
	if _autoplay:
		if _menu and _work_menu(now):
			pass
		elif _pausing_since > 0.0:
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
	if _menu_back_at > 0.0:
		if now - _menu_back_at > MENU_STEP_MS:
			var menu := _main_menu()
			_expect(menu.visible and menu.page == _menu_page and not game.started and not _pill().visible,
				"the end panel's Menu shows the board the song started from")
			print("menu: back on %s" % MainMenu.Page.keys()[menu.page])
			get_tree().quit()
		return
	_check_progress()
	if game.started and game.mode == Hud.Mode.DRILL and not _spacing_checked:
		_spacing_checked = true
		_check_drill_spacing()
	if game.state == Game.State.WON or game.state == Game.State.OVER:
		if _ended_at == 0.0:
			_ended_at = now
			_end_state = game.state
			var missed := "" if game.mode == Hud.Mode.PLAY else " misses=%d" % game.misses
			print("autoplay ended: ", Game.State.keys()[game.state], " falls=", game.falls, " bananas=", game.bananas, missed)
		elif now - _ended_at > 1000.0 and not _poked_end:
			_poked_end = true
			var source: String = game.note_input.source
			game.note_input.source = "MIDI"   # notes from a MIDI keyboard, as menus only listened to those
			game.note_on(60, now)   # C4: on the end panel only the mouse and the keys pick
			game.note_off(60, now)
			game.note_input.source = source
			if game.state != _end_state:
				push_error("a note on the end panel picked a button")
				get_tree().quit()
		elif now - _ended_at > 2000.0:
			if game.state == Game.State.WON and game.level_progress() < 1.0:
				push_error("progress ended at %.3f, not 1, with the gorilla in its nest" % game.level_progress())
			_check_counters()
			if _menu:
				_menu_back_at = now
				game.hud.get_node("EndPanel/Lines/Buttons/Menu").pressed.emit()
				return
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


## With --menu: works the main menu, one step every MENU_STEP_MS, until the song is started from
## its board. True while it still is.
func _work_menu(now: float) -> bool:
	if _menu_step >= _menu_steps.size():
		return false
	if now < _menu_next:
		return true
	_menu_next = now + MENU_STEP_MS
	var menu := _main_menu()
	var plank: Button = menu.get_node("Main/Column/" + PLANKS[_menu_page])
	match _menu_steps[_menu_step]:
		0:
			_expect(menu.visible and menu.page == MainMenu.Page.MAIN and not game.started and not _pill().visible,
				"the game opens on the main page, the counters hidden")
			_key(KEY_ESCAPE)
			_key(KEY_SPACE)
		1:
			_expect(menu.visible and menu.page == MainMenu.Page.MAIN and not game.started, "Esc and Space do nothing on the main page")
			plank.pressed.emit()
		2:
			_expect(menu.page == _menu_page and game.mode == MODES[_menu_page], "the plank opens its board, in its mode")
			if _menu_page == MainMenu.Page.DRILL:
				menu.get_node("Drill/Board/Rows/Grid/Chords/Picked/More").pressed.emit()
			else:
				_expect(menu.get_node("Songs/Board/Rows/Grid/Sign").visible == _chords, "the chord sign row shows with a chords part only")
				_key(KEY_ESCAPE)
		9:
			var kinds := menu.get_node("Drill/Board/Rows/Grid/Chords/Kinds")
			var minor: Button = kinds.get_node("Minor")
			var major: Button = kinds.get_node("Major")
			minor.button_pressed = true
			major.button_pressed = false
			minor.button_pressed = false   # the last kind: refused
			var grid: ChordMenu = game.hud.get_node("ChordMenu")
			_expect(grid.picked() == MINORS, "Minor on and Major off pick the white-key minors, and the last kind stays: %s" % [grid.picked()])
			_expect(menu.get_node("Drill/Board/Rows/Grid/Chords/Picked/Summary").text == " ".join(MINORS), "the line names the chords picked")
			_expect(minor.button_pressed and not major.button_pressed, "the kind buttons show what is picked")
		13:
			_board_width = menu.get_node("Drill/Board").size.x
			menu.get_node("Drill/Board/Rows/Grid/Chords/Kinds/Dom7").button_pressed = true   # a long line of chords
		14:
			var width: float = menu.get_node("Drill/Board").size.x
			_expect(is_equal_approx(width, _board_width), "the drill board keeps its width as the line of chords grows: %d, then %d" % [_board_width, width])
			var line: Label = menu.get_node("Drill/Board/Rows/Grid/Chords/Picked/Summary")
			var text_width := line.get_theme_font("font").get_string_size(line.text, HORIZONTAL_ALIGNMENT_LEFT, -1, line.get_theme_font_size("font_size")).x
			_expect(text_width <= line.size.x, "the line of chords shows in full: '%s' is %d wide in %d" % [line.text, text_width, line.size.x])
			menu.get_node("Drill/Board/Rows/Grid/Chords/Kinds/Dom7").button_pressed = false
		10:
			_expect(game.hud.chords_open() and not menu.visible and not _pill().visible, "More options opens the chord grid, over nothing else")
		11:
			_key(KEY_ESCAPE)
		12:
			_expect(not game.hud.chords_open() and menu.visible and menu.page == MainMenu.Page.DRILL, "Esc closes the chord grid back to the drill board")
			_key(KEY_ESCAPE)
		3:
			_expect(menu.visible and menu.page == MainMenu.Page.MAIN, "Esc goes back from a board to the main page")
			plank.pressed.emit()
		4:
			_expect(menu.page == _menu_page, "the plank opens its board again")
			_key(KEY_SPACE)
		5:
			_expect(game.started and not menu.visible and _pill().visible, "Space starts from a board, and the counters show")
			print("menu: started from %s" % MainMenu.Page.keys()[_menu_page])
			if _menu_page == MainMenu.Page.DRILL:
				var dealt := game.notes.filter(func(n: Song.Note) -> bool: return n.chord != null).map(func(n: Song.Note) -> String: return n.chord.name)
				_expect(dealt.all(func(c: String) -> bool: return c in MINORS), "the round deals only the chords picked: %s" % [dealt])
				print("menu: kinds ok")
	_menu_step += 1
	return true


func _main_menu() -> MainMenu:
	return game.hud.get_node("MainMenu")


func _pill() -> Control:
	return game.hud.get_node("Pill")


func _expect(ok: bool, what: String) -> void:
	if not ok:
		push_error("menu: not so: " + what)


## The counters stay readable at the end of the song: the percentage under the progress line
## clear of the pill, and bananas flying to the pill drawn over it, not under it.
func _check_counters() -> void:
	var pill: Control = game.hud.get_node("Pill")
	var label: Rect2 = game.hud.get_node("Progress").label_rect()
	if label.intersects(pill.get_global_rect()):
		push_error("the progress label %s is under the pill %s" % [label, pill.get_global_rect()])
	if game.hud.get_node("Flyers").get_index() < pill.get_index():
		push_error("bananas fly under the pill")


## The drill's chords sit game.drill_beats apart.
func _check_drill_spacing() -> void:
	var at: Array = game.notes.filter(func(n: Song.Note) -> bool: return n.chord != null).map(func(n: Song.Note) -> float: return n.beat)
	for k in range(1, at.size()):
		if not is_equal_approx(at[k] - at[k - 1], game.drill_beats):
			push_error("drill chords %.2f beats apart, not %d" % [at[k] - at[k - 1], game.drill_beats])
			return
	print("drill: %d chords, %d beats apart" % [at.size(), game.drill_beats])


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
