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
##                        note while paused, as a player reaching for Esc would; a second later
##                        it steps the tempo up by notes (D to Tempo, F) and continues with B,
##                        then by keys (down arrows, right arrow, Esc), and last continues with
##                        Enter. With chords, the first time it also picks Bass clef on Chord
##                        sign and checks the logs show it
##   -- --menu            with --autoplay, works the menus by MIDI notes in mixed octaves (C up,
##                        D down, E and F left and right, A press, B back) instead of starting
##                        at once, checking the selection and the sign's lit keys at each step:
##                        on the main page the mouse, Esc and B (nothing); the board for the mode
##                        (Play song, or Learn song or Chord drill with --learn or --drill), where
##                        it steps the song on and back and walks down past the Chord sign row,
##                        or on the drill board turns Minor on and Major off, tries Minor off,
##                        opens More options, toggles C in the chord grid, goes back with B and
##                        picks Bass clef on Chord sign;
##                        B to the main page, A on the same plank, and the arrows and Space to
##                        start. At the end it presses the end panel's Menu and checks the same
##                        board is back
##   -- --bpm=<n>         plays at n BPM instead of 60, for a quicker check
##   -- --perf            prints fps and draw calls once a second
##   -- --shots=<dir>     saves a screenshot every second into <dir>

const Game := preload("res://scripts/game.gd")
const Song := preload("res://scripts/song.gd")
const Hud := preload("res://scripts/hud.gd")
const Drill := preload("res://scripts/drill.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
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
const MenuCursor := preload("res://scripts/menu_cursor.gd")
const KEYS := {"C": 0, "D": 2, "E": 4, "F": 5, "A": 9, "B": 11}   # the white keys that work the menus

@onready var game: Game = get_parent()

var _autoplay := false
var _pause := false
var _paused_in := {}       # the states it has paused in already, each only once
var _pausing_since := 0.0  # when it pressed Esc; 0 while not pausing
var _paused_at := 0.0      # when it saw the game paused
var _resume_sent := false
var _pauses := 0           # pauses worked so far: the first by notes, the second by keys, the rest by Enter
var _tempo_due := 0.0      # the tempo a pause worked by keys should have left; 0 for none
var _counts_at_pause := []   # falls and misses when it paused: a pause costs nothing
var _held_over := -1       # the next branch's note, held down on the pause menu into the song; -1 for none
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
var _poked_end := false             # the bot has played a note on the end panel in its first second
var _end_checked := false           # and seen it listen after that
var _menu := false
var _menu_page := MainMenu.Page.PLAY  # the board it starts from
var _menu_steps: Array[String] = ["main", "pick", "board", "again", "start", "started"]
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
		_menu_steps = ["main", "pick", "drill", "width", "width_check", "more", "grid", "grid_back", "sign", "again", "start", "started"]
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
			_expect(_cursor().selected() == menu.get_node(("Drill" if _menu_page == MainMenu.Page.DRILL else "Songs") + "/Board/Rows/Foot/Start"),
				"the board is back on Start")
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
		elif now - _ended_at > 300.0 and not _poked_end:
			_poked_end = true
			_note("A", 4)   # hands still on the piano as the panel comes up
			_expect(game.state == _end_state and game.hud.get_node("EndPanel").visible and not _cursor().sign_shown(),
				"in the end panel's first second a note does nothing, and the sign waits")
		elif now - _ended_at > 1300.0 and not _end_checked:
			_end_checked = true
			_expect(_cursor().sign_shown() and _lit() == "EFAB" and _cursor().selected() == game.hud.get_node("EndPanel/Lines/Buttons/Again"),
				"after a second the end panel's sign shows, on Play again, E F A B lit: %s" % _lit())
			print("end: guard ok")
		elif now - _ended_at > 2000.0:
			if game.state == Game.State.WON and game.level_progress() < 1.0:
				push_error("progress ended at %.3f, not 1, with the gorilla in its nest" % game.level_progress())
			_check_counters()
			if _menu:
				_menu_back_at = now
				_note("F", 6)
				_expect(_cursor().selected() == game.hud.get_node("EndPanel/Lines/Buttons/Menu"), "F moves to Menu")
				_note("A", 2)
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


## With --menu: works the menus by notes, one step every MENU_STEP_MS, until the song is started
## from its board. True while it still is.
func _work_menu(now: float) -> bool:
	if _menu_step >= _menu_steps.size():
		return false
	if now < _menu_next:
		return true
	_menu_next = now + MENU_STEP_MS
	var menu := _main_menu()
	var cursor := _cursor()
	var plank: Button = menu.get_node("Main/Column/" + PLANKS[_menu_page])
	var songs := "Songs/Board/Rows/"
	var drill := "Drill/Board/Rows/"
	var grid: ChordMenu = game.hud.get_node("ChordMenu")
	var step := _menu_steps[_menu_step]
	_menu_step += 1   # before the step: one that breaks halfway is not tried again and again
	match step:
		"main":
			_expect(menu.visible and menu.page == MainMenu.Page.MAIN and not game.started and not _pill().visible,
				"the game opens on the main page, the counters hidden")
			_expect(cursor.selected() == menu.get_node("Main/Column/Play") and _lit() == "CDA" and cursor.sign_shown(),
				"the main page opens on Play song, the sign lit C D A: %s" % _lit())
			menu.get_node("Main/Column/Learn").mouse_entered.emit()
			_expect(cursor.selected() == menu.get_node("Main/Column/Learn"), "the mouse selects the plank it points at")
			_note("C", 1)
			_expect(cursor.selected() == menu.get_node("Main/Column/Play"), "C moves up from there")
			_key(KEY_ESCAPE)
			_note("B", 2)
		"pick":
			_expect(menu.visible and menu.page == MainMenu.Page.MAIN and not game.started, "Esc and B do nothing on the main page")
			for k in PLANKS.keys().find(_menu_page):
				_note("D", 3 + k)
			_expect(cursor.selected() == plank, "D walks down to the board's plank")
			_note("A", 5)
		"board":
			_expect(menu.page == _menu_page and game.mode == MODES[_menu_page], "A on the plank opens its board, in its mode")
			_expect(cursor.selected() == menu.get_node(songs + "Foot/Start") and _lit() == "CDEFAB", "the board opens on Start, all six lit: %s" % _lit())
			_expect(menu.get_node(songs + "Grid/Sign").visible == _chords, "the chord sign row shows with a chords part only")
			var pick: OptionButton = menu.get_node(songs + "Grid/Song/Pick")
			var first := pick.selected
			_note("D", 2)
			_expect(cursor.selected() == menu.get_node(songs + "Grid/Song") and _lit() == "CDEFB", "D from Start wraps to the song, no A there: %s" % _lit())
			_note("F", 4)
			_expect(pick.selected == posmod(first + 1, pick.item_count) and game.song == pick.selected, "F steps to the next song")
			_note("E", 6)
			_expect(pick.selected == first and game.song == first, "E steps back")
			_note("D", 1)
			_note("D", 5)
			var below := "Sign" if _chords else ("Practice" if _menu_page == MainMenu.Page.PLAY else "Hint")
			_expect(_row_name() == below, "D below the part lands on %s, not %s" % [below, _row_name()])
			_note("B", 3)
		"drill":
			_expect(menu.page == MainMenu.Page.DRILL and game.mode == Hud.Mode.DRILL, "A on the plank opens the drill board")
			_expect(cursor.selected() == menu.get_node(drill + "Foot/Start") and _lit() == "CDEFAB", "the drill board opens on Start: %s" % _lit())
			var kinds := menu.get_node(drill + "Grid/Chords/Kinds")
			var minor: Button = kinds.get_node("Minor")
			var major: Button = kinds.get_node("Major")
			_note("D", 1)
			_expect(cursor.selected() == kinds.get_node("Aug"), "D from Start wraps to the kinds, on the nearest one")
			_note("F", 3)
			_expect(cursor.selected() == major, "F wraps round the kinds")
			_note("F", 5)
			_note("A", 2)   # Minor on
			_note("E", 6)
			_note("A", 4)   # Major off
			_note("F", 2)
			_note("A", 3)   # the last kind: refused
			_expect(grid.picked() == MINORS, "Minor on and Major off pick the white-key minors, and the last kind stays: %s" % [grid.picked()])
			_expect(menu.get_node(drill + "Grid/Chords/Picked/Summary").text == " ".join(MINORS), "the line names the chords picked")
			_expect(minor.button_pressed and not major.button_pressed, "the kind buttons show what is picked")
		"width":
			_board_width = menu.get_node("Drill/Board").size.x
			menu.get_node(drill + "Grid/Chords/Kinds/Dom7").button_pressed = true   # a long line of chords
		"width_check":
			var width: float = menu.get_node("Drill/Board").size.x
			_expect(is_equal_approx(width, _board_width), "the drill board keeps its width as the line of chords grows: %d, then %d" % [_board_width, width])
			var line: Label = menu.get_node(drill + "Grid/Chords/Picked/Summary")
			var text_width := line.get_theme_font("font").get_string_size(line.text, HORIZONTAL_ALIGNMENT_LEFT, -1, line.get_theme_font_size("font_size")).x
			_expect(text_width <= line.size.x, "the line of chords shows in full: '%s' is %d wide in %d" % [line.text, text_width, line.size.x])
			menu.get_node(drill + "Grid/Chords/Kinds/Dom7").button_pressed = false
		"more":
			_note("D", 4)
			_expect(cursor.selected() == menu.get_node(drill + "Grid/Chords/Picked/More"), "D goes down to More options")
			_note("A", 2)
		"grid":
			_expect(game.hud.chords_open() and not menu.visible and not _pill().visible, "More options opens the chord grid, over nothing else")
			_expect((cursor.selected() as Button).text == "C" and _lit() == "CDEFAB", "the chord grid opens on C, all six lit: %s" % _lit())
			_note("A", 3)
			_expect("C" in grid.picked(), "A picks the chord under the cursor")
			_note("D", 5)
			_expect((cursor.selected() as Button).text == "Cm", "D keeps the column: Cm, not %s" % (cursor.selected() as Button).text)
			_note("C", 2)
			_note("A", 6)
			_expect(grid.picked() == MINORS, "A again unpicks it: %s" % [grid.picked()])
			_note("B", 4)
		"grid_back":
			_expect(not game.hud.chords_open() and menu.visible and menu.page == MainMenu.Page.DRILL, "B closes the chord grid back to the drill board")
			_expect(cursor.selected() == menu.get_node(drill + "Foot/Start"), "the drill board is back on Start")
		"sign":
			_note("C", 3)
			_note("C", 5)
			_expect(_row_name() == "Sign" and _lit() == "CDFB", "C twice from Start goes up to the chord sign, on Name, F lit: %s %s" % [_row_name(), _lit()])
			_note("F", 2)
			_expect(game.hint == ChordLog.Hint.BASS_CLEF, "F picks the bass clef")
			_expect(menu.get_node(songs + "Grid/Sign/Bass").button_pressed and not menu.get_node(songs + "Grid/Sign/Name").button_pressed,
				"the song boards show the bass clef picked too")
			_note("B", 1)
		"again":
			_expect(menu.visible and menu.page == MainMenu.Page.MAIN, "B goes back from a board to the main page")
			_expect(cursor.selected() == plank, "back on the main page, the board's own plank is selected")
			_note("A", 4)
			_expect(menu.page == _menu_page, "A on it opens its board again")
		"start":
			_key(KEY_UP)
			_key(KEY_DOWN)
			_key(KEY_SPACE)
		"started":
			_expect(game.started and not menu.visible and _pill().visible, "up, down and Space start from Start, and the counters show")
			if not game.started:
				print("autoplay: the menus never started the song")
				get_tree().quit()
				return true
			print("menu: started from %s" % MainMenu.Page.keys()[_menu_page])
			if _menu_page == MainMenu.Page.DRILL:
				var dealt := game.notes.filter(func(n: Song.Note) -> bool: return n.chord != null).map(func(n: Song.Note) -> String: return n.chord.name)
				_expect(dealt.all(func(c: String) -> bool: return c in MINORS), "the round deals only the chords picked: %s" % [dealt])
				print("menu: kinds ok")
				var named := range(game.notes.size()).filter(func(i: int) -> bool:
					return game.notes[i].chord != null and not game.world.chord_log(i).get_node("Top/Sign/Staff").visible)
				_expect(named.is_empty(), "every log's sign shows the bass clef, not the %d named" % named.size())
				print("menu: bass clef ok")
	return true


## The white key `name` ("C" … "B") in `octave` (4 is middle C's), played and let go on the
## MIDI keyboard, as only notes from one work the menus.
func _note(name: String, octave: int) -> void:
	var m: int = 12 * (octave + 1) + KEYS[name]
	var source: String = game.note_input.source
	game.note_input.source = "MIDI"
	var t := Game.now_ms()
	game.note_on(m, t)
	game.note_off(m, t)
	game.note_input.source = source


func _cursor() -> MenuCursor:
	return game.hud.cursor


## The keys lit on the sign, by name: "CDEFAB" when all six are.
func _lit() -> String:
	return "".join(_cursor().lit().map(func(a: int) -> String: return "CDEFAB"[a]))


## The selected board row's name: its own for a row of choices, its button's parent's otherwise.
func _row_name() -> String:
	var selected := _cursor().selected()
	return selected.name if selected is HBoxContainer else selected.get_parent().name


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
	# the drill is about the chords: the gorilla plays the notes itself, unnamed, labels on or off
	for i in game.notes.size():
		var name: String = game.world.branch(i).get_node("NoteLabel").text
		if name != "":
			push_error("the drill's note %d is labelled %s" % [i, name])
			return
	print("drill: no note names")


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
	_counts_at_pause = [game.falls, game.misses]
	print("paused state=%s cur=%d" % [Game.State.keys()[s], game.cur])
	_key(KEY_ESCAPE)
	_pausing_since = now
	_paused_at = 0.0
	_resume_sent = false
	return true


## While pausing: once the game is paused, lets go of the note; a second later works the pause
## menu (see --pause); once it runs again, says where the gorilla is.
func _work_pause(now: float) -> void:
	var paused := get_tree().paused
	if _resume_sent:
		if paused and now - _paused_at > PAUSE_FOR_MS + PAUSE_DEADLINE_MS:
			print("autoplay: the pause menu did not continue")
			get_tree().quit()
		if not paused:
			print("resumed state=%s cur=%d bpm=%d" % [Game.State.keys()[game.state], game.cur, roundi(game.bpm)])
			_pausing_since = 0.0
			if _tempo_due > 0.0:
				_expect(is_equal_approx(game.bpm, _tempo_due), "the right arrow on Tempo stepped it to %d, not %d" % [_tempo_due, game.bpm])
				print("pause: tempo %d" % roundi(game.bpm))
				_tempo_due = 0.0
			_expect(game._menu_notes.keys() == ([_held_over] if _held_over >= 0 else []),
				"the notes that worked the pause menu are let go of without reaching the song: %s" % [game._menu_notes.keys()])
			_expect([game.falls, game.misses] == _counts_at_pause, "the pause cost nothing: falls and misses %s, then %s" % [_counts_at_pause, [game.falls, game.misses]])
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
		var rows := game.hud.get_node("PauseMenu/Center/Panel/Rows")
		_expect(_cursor().selected() == rows.get_node("Continue") and _lit() == "CDAB", "the pause menu opens on Continue: %s" % _lit())
		var downs := 3 if game.mode == Hud.Mode.PLAY else 2   # Practice mode's row is Play's only
		var up_to := minf(game.bpm + 5.0, 120.0)
		var nth := _pauses
		_pauses += 1          # before the walk: one that breaks halfway is not tried again and again
		_resume_sent = true
		match nth:
			0:
				for k in downs:
					_note("D", 2 + 2 * k)
				_expect(_cursor().selected() == rows.get_node("Tempo"), "D walks down to Tempo")
				_expect(("F" in _lit()) == (game.bpm < 120.0), "F is lit on Tempo only below 120 BPM: %s at %d" % [_lit(), game.bpm])
				_note("F", 3)
				_expect(is_equal_approx(game.bpm, up_to), "F on Tempo steps it to %d, not %d" % [up_to, game.bpm])
				print("pause: tempo %d" % roundi(game.bpm))
				_expect(rows.get_node("Sign").visible == game.chords, "the chord sign row shows with chords only")
				if game.chords:
					for k in 3:
						_note("D", 3 + k)   # Tick, Labels, Chord sign
					_expect(_cursor().selected() == rows.get_node("Sign") and _lit() == "CDFB", "D walks down to Chord sign, on Name: %s" % _lit())
					_note("F", 4)
					_expect(game.hint == ChordLog.Hint.BASS_CLEF, "F on Chord sign picks the bass clef")
					var named := range(game.notes.size()).filter(func(i: int) -> bool:
						return game.notes[i].chord != null and not game.world.chord_log(i).get_node("Top/Sign/Staff").visible)
					_expect(named.is_empty(), "every log's sign shows the bass clef at once, not the %d named" % named.size())
					var boards := ["Songs/Board/Rows/Grid/Sign/Bass", "Drill/Board/Rows/Grid/Sign/Bass"]
					_expect(boards.all(func(b: String) -> bool: return (_main_menu().get_node(b) as Button).button_pressed),
						"the song and drill boards show the bass clef picked too")
					print("pause: bass clef ok")
				_note("B", 5)
			1:
				for k in downs:
					_key(KEY_DOWN)
				_key(KEY_RIGHT)
				_key(KEY_ESCAPE)
				_tempo_due = up_to
			_:
				if game.state == Game.State.REST and game.mode == Hud.Mode.PLAY:
					_held_over = game.notes[game.cur + 1].midi   # the note it plays next, once in the song
					game.note_on(_held_over, now)   # still down from the menu: playing it again lets the old one go
				_key(KEY_ENTER)


## Presses and lets go of computer key `code`, as if typed.
func _key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var key := InputEventKey.new()
		key.keycode = code
		key.pressed = pressed
		Input.parse_input_event(key)
