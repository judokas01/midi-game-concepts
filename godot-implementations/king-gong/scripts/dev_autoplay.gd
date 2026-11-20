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
##                        board is back. Along the way it checks that one thing alone looks
##                        selected (gold) and grown: on the main page, along the board's foot
##                        (Back · Listen · Start, or Back | Start) and back, on the end panel both ways, and on the pause menu
##                        (with --pause) Continue and Restart song; with --shots it saves each
##                        as look_<menu>_<selected>.png
##   -- --bpm=<n>         plays at n BPM instead of 60, for a quicker check
##   -- --backing         turns Backing on (it is on by default): the game plays the part the
##                        bot doesn't. Every --autoplay run checks it at the end: the chords
##                        sounded, one per grab of a branch a chord starts on (Treble or Bass
##                        clef: "backing: <n> chords sounded"), the tune, one note per grab
##                        (Chords only: "backing: <n> tune notes sounded"), or nothing and the
##                        Backing row hidden (Treble + chords: "backing: none for this part");
##                        with --pause, no backing voice while paused ("backing: silent while
##                        paused")
##                        In the drill, Backing is its tune, as for Chords only: the arpeggios
##                        on its branches and each log's root
##   -- --listen          instead of playing: Listen from the board (Play song, or Learn song
##                        with --learn), to the nest, checking that nothing counts and no tick
##                        sounds, then that the piano played the song's notes and chords each
##                        within 20 ms of the gorilla's grab: "listen: <n> notes, <m> chords,
##                        worst <x> ms off the beat". Then Listen twice more, stopped by a key
##                        ("listen: a key stops it") and by a note ("listen: a note stops it")
##   -- --perf            prints fps and draw calls once a second
##   -- --shots=<dir>     saves a screenshot every second into <dir>
##   every run checks the message, whenever it shows, clears the chord signs and the counters,
##   and prints "sound: piano ready (<n> samples)"

const Game := preload("res://scripts/game.gd")
const Song := preload("res://scripts/song.gd")
const Hud := preload("res://scripts/hud.gd")
const Drill := preload("res://scripts/drill.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const MainMenu := preload("res://scripts/main_menu.gd")
const ChordMenu := preload("res://scripts/chord_menu.gd")
const PianoSound := preload("res://scripts/piano_sound.gd")
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
var _banner_ok := false    # the message has been seen clear of the signs
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
var _end_menu_at := 0.0             # with --menu, when it moved to the end panel's Menu
var _looks_failed := false          # something other than the selection looked selected
var _paused_looked := false         # the first pause has had its looks checked
var _menu := false
var _menu_page := MainMenu.Page.PLAY  # the board it starts from
var _menu_steps: Array[String] = ["main", "pick", "foot", "foot", "foot", "board", "again", "start", "started"]
var _foot_seen := 0                 # the foot's buttons looked at so far, from Start leftwards
var _menu_step := 0
var _menu_next := 0.0
var _menu_back_at := 0.0            # when it pressed the end panel's Menu
var _board_width := 0.0             # the drill board's, before a long line of chords
var _chords := false                # a part with chords was asked for
var _listen := false                # --listen
var _grabs_n := 0                   # the gorilla's grabs in the song, for backing
var _chord_grabs := 0               # of them, grabs of a branch a chord starts on, or under a chord let go
var _chord_gone := true             # no chord rings: none yet, or let go at a fall, or stopped at a pause
var _falls_seen := 0
var _was_hanging := false
var _last_cur := -1
var _counted := {}                  # "branch@grab_t" of each grab counted
var _resumed := false               # it just continued from a pause: the gorilla grabs again, maybe unseen
var _silent_said := false           # "backing: silent while paused", once
var _heard: Array = []              # what the song player played while listening; the board's level clears it
var _listen_step := ""
var _listen_round := 0              # 0 to the nest, 1 stopped by a key, 2 by a note
var _listen_next := 0.0             # the next step not before then
var _listen_since := 0.0            # when listening started
var _grabs := {}                    # branch -> when the gorilla grabbed it, while listening
var _bananas_at := 0
var _listen_failed := false         # something counted while listening; said once


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # works the pause menu, and keeps taking screenshots, while the game is paused
	print("sound: piano ready (%d samples)" % PianoSound.sample_count())
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
		elif arg == "--listen":
			_listen = true
		elif arg == "--backing":
			game.set_backing.call_deferred(true)
	if _drill:
		game.set_drill.call_deferred(Drill.all_chords(), Drill.COUNT, _beats)
		game.set_mode.call_deferred(Hud.Mode.DRILL)
		_menu_page = MainMenu.Page.DRILL
		_menu_steps = ["main", "pick", "foot", "foot", "drill", "width", "width_check", "more", "grid", "grid_back", "sign", "again", "start", "started"]
	if _autoplay and not _menu and not _listen:
		game.start.call_deferred()


func _process(_delta: float) -> void:
	var now := Game.now_ms()
	_count_grabs()
	if _listen:
		_work_listen(now)
	elif _autoplay:
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
	_check_banner()
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
			_look("end_again")
			_expect_lit(_end_buttons(), game.hud.get_node("EndPanel/Lines/Buttons/Again"), "the end panel")
		elif now - _ended_at > 2000.0 and _end_menu_at == 0.0:
			if game.state == Game.State.WON and game.level_progress() < 1.0:
				push_error("progress ended at %.3f, not 1, with the gorilla in its nest" % game.level_progress())
			_check_counters()
			_check_backing()
			if not _menu:
				get_tree().quit()
				return
			_end_menu_at = now
			_note("F", 6)
			_expect(_cursor().selected() == game.hud.get_node("EndPanel/Lines/Buttons/Menu"), "F moves to Menu")
		elif _end_menu_at > 0.0 and now - _end_menu_at > MENU_STEP_MS:
			_look("end_menu")
			_expect_lit(_end_buttons(), game.hud.get_node("EndPanel/Lines/Buttons/Menu"), "the end panel")
			_menu_back_at = now
			_note("A", 2)
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
			_look("main")
			_expect_lit(menu.get_node("Main/Column").get_children().filter(func(c: Node) -> bool: return c is Button),
				menu.get_node("Main/Column/Play"), "the main page")
			_expect(menu.visible and menu.page == MainMenu.Page.MAIN and not game.started, "Esc and B do nothing on the main page")
			for k in PLANKS.keys().find(_menu_page):
				_note("D", 3 + k)
			_expect(cursor.selected() == plank, "D walks down to the board's plank")
			_note("A", 5)
		"foot":   # from Start leftwards to Back, a look at each, then back to Start
			var page := MainMenu.Page.keys()[_menu_page].to_lower() as String
			var foot: Array = (menu.get_node(("Drill" if _menu_page == MainMenu.Page.DRILL else "Songs") + "/Board/Rows/Foot")
				.get_children().filter(func(c: Node) -> bool: return c is Button))
			var on: Button = foot[foot.size() - 1 - _foot_seen]
			_look("%s_%s" % [page, on.name.to_lower()])
			_expect_lit(foot, on, "the board's foot")
			_foot_seen += 1
			if _foot_seen < foot.size():
				_note("E", 3)
				_expect(cursor.selected() == foot[foot.size() - 1 - _foot_seen], "E moves left along the foot to %s" % foot[foot.size() - 1 - _foot_seen].name)
			else:
				for k in foot.size() - 1:
					_note("F", 4 + k)
				_expect(cursor.selected() == foot[-1], "F walks back along the foot to Start")
				if not _looks_failed:
					print("menu: looks ok")
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
			var below := "Sign" if _chords else ("Backing" if menu.get_node(songs + "Grid/Backing").visible else ("Practice" if _menu_page == MainMenu.Page.PLAY else "Hint"))
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


## With --listen: Listen from the board to the nest, then again stopped by a key, then by a
## note, one step every MENU_STEP_MS.
func _work_listen(now: float) -> void:
	if now < _listen_next:
		return
	var menu := _main_menu()
	var foot := "Songs/Board/Rows/Foot/"
	match _listen_step:
		"":
			menu.open(_menu_page)
			_listen_step = "press"
			_listen_next = now + MENU_STEP_MS
		"press":
			_expect(menu.visible and _cursor().selected() == menu.get_node(foot + "Start"), "the board is up, on Start")
			_note("E", 4)
			_expect(_cursor().selected() == menu.get_node(foot + "Listen"), "E moves from Start to Listen")
			_note("A", 3)
			_expect(game.listening and game.started and not menu.visible, "A on Listen starts listening, the board hidden")
			_grabs.clear()
			_bananas_at = game.bananas
			_listen_since = now
			_listen_step = ["hear", "key", "note"][_listen_round]
		"hear":
			if game.listening:
				_watch_listening()
				return
			_check_heard()
			_back_on_board("at the nest")
			_next_listen(now)
		"key":
			if now - _listen_since < 1500.0:
				_watch_listening()
				return
			_key(KEY_Q)
			_listen_step = "key_check"
			_listen_next = now + MENU_STEP_MS
		"key_check":
			_back_on_board("after a key")
			_expect(game.song_player.sounding() == 0, "a key stops the piano at once: %d sounding" % game.song_player.sounding())
			print("listen: a key stops it")
			_next_listen(now)
		"note":
			if now - _listen_since < 1000.0:
				_watch_listening()
				return
			_note("A", 4)   # also what presses Start on the board, once it is back
			_back_on_board("after a note")
			print("listen: a note stops it")
			get_tree().quit()


func _next_listen(now: float) -> void:
	_listen_round += 1
	_listen_step = "press"
	_listen_next = now + MENU_STEP_MS


## While listening: the grabs, for the timing; and nothing counts, nothing ticks, no end panel.
func _watch_listening() -> void:
	_heard = game.song_player.played.duplicate()
	if game.state == Game.State.HANG and not _grabs.has(game.cur):
		_grabs[game.cur] = game.grab_t
	var counted := game.falls != 0 or game.misses != 0 or game.bananas != _bananas_at
	var ticking: bool = not game.metronome._ticks.is_empty()
	var panel: bool = game.hud.get_node("EndPanel").visible
	if (counted or ticking or panel) and not _listen_failed:
		_listen_failed = true
		push_error("listen: not so: nothing counts or ticks: falls %d, misses %d, bananas %d of %d, ticks queued %s, end panel %s"
			% [game.falls, game.misses, game.bananas, _bananas_at, ticking, panel])


## Listened to the nest: the piano played the song's own notes and chords, each heard within
## 20 ms of the gorilla's grab of its branch.
func _check_heard() -> void:
	var notes := Song.parse(game.song, game.clef, true)
	var chords := notes.filter(func(n: Song.Note) -> bool: return n.chord != null).size()
	var played := _heard
	var heard_chords := played.filter(func(p: Dictionary) -> bool: return p.chord).size()
	var worst := 0.0
	for p: Dictionary in played:
		if not _grabs.has(p.branch):
			push_error("listen: not so: branch %d sounded but was never grabbed" % p.branch)
			continue
		worst = maxf(worst, absf(p.heard_ms - _grabs[p.branch]))
	_expect(played.size() - heard_chords == notes.size() and heard_chords == chords,
		"the piano played the song's %d notes and %d chords, not %d and %d" % [notes.size(), chords, played.size() - heard_chords, heard_chords])
	_expect(worst <= 20.0, "every sound within 20 ms of its beat, not %.1f ms" % worst)
	print("listen: %d notes, %d chords, worst %.1f ms off the beat" % [played.size() - heard_chords, heard_chords, worst])


func _back_on_board(when: String) -> void:
	var menu := _main_menu()
	_expect(not game.listening and not game.started and menu.visible and menu.page == _menu_page,
		"%s the board is back, the song not started" % when)
	_expect(_cursor().selected() == menu.get_node("Songs/Board/Rows/Foot/Start"), "%s the board is on Start" % when)


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


## On `where`, `which` alone of `buttons` looks selected (its theme's hover look, gold) and
## has grown; the others look and sit as at rest.
func _expect_lit(buttons: Array, which: Button, where: String) -> void:
	var theme := ThemeDB.get_project_theme()
	var lit := buttons.filter(func(b: Button) -> bool: return b.get_theme_stylebox(&"normal") == theme.get_stylebox(&"hover", b.theme_type_variation))
	var grown := buttons.filter(func(b: Button) -> bool: return b.scale.x > 1.0)
	if lit != [which] or grown != [which]:
		_looks_failed = true
		var names := func(bs: Array) -> String: return ", ".join(bs.map(func(b: Button) -> String: return b.name))
		push_error("menu: not so: on %s only %s looks selected and grown, not lit [%s], grown [%s]" % [where, which.name, names.call(lit), names.call(grown)])


## With --shots, saves the screen as it was a frame ago as look_<name>.png, for the user to
## judge whether what is selected is plain to see.
func _look(name: String) -> void:
	if _shots_dir == "":
		return
	var path := "%s/look_%s.png" % [_shots_dir, name]
	get_viewport().get_texture().get_image().save_png(path)
	print("look: ", path)


func _end_buttons() -> Array:
	return [game.hud.get_node("EndPanel/Lines/Buttons/Again"), game.hud.get_node("EndPanel/Lines/Buttons/Menu")]


func _pause_buttons() -> Array:
	var rows := game.hud.get_node("PauseMenu/Center/Panel/Rows")
	return [rows.get_node("Continue"), rows.get_node("Restart"), rows.get_node("Menu")]


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


## A new grab: the gorilla took hold of a branch since the last frame (not while listening).
## Hanging on the same branch with its grab moved on is the beat catching up after a wait,
## unless it just continued from a pause, where it grabs again before the bot looks.
func _count_grabs() -> void:
	if _resumed or game.falls != _falls_seen:
		_chord_gone = true
		_falls_seen = game.falls
	var hanging := game.started and not game.listening and game.state == Game.State.HANG
	var key := "%d@%.3f" % [game.cur, game.grab_t]
	var again := _was_hanging and game.cur == _last_cur and not _resumed
	if hanging and not _counted.has(key) and not again:
		_counted[key] = true
		_grabs_n += 1
		var cur: int = game.cur
		var starts: bool = game.song_player.sounds.any(func(x) -> bool: return x.chord and x.branch == cur)
		var under: bool = game.song_player.sounds.any(func(x) -> bool: return x.chord and x.branch < cur)
		if starts or (_chord_gone and under):
			_chord_grabs += 1
			_chord_gone = false
	_was_hanging = hanging
	_last_cur = game.cur
	_resumed = false


## Backing played the part the bot didn't, at the gorilla's grabs: the chords of the branches
## they start on, or the tune, or for Treble + chords nothing.
func _check_backing() -> void:
	var played: Array = game.song_player.played
	var chord_sounds := played.filter(func(p: Dictionary) -> bool: return p.chord).size()
	match game.backing_part():
		"chords":
			_expect(chord_sounds == played.size() and chord_sounds == _chord_grabs and _chord_grabs > 0,
				"a chord sounded at each of the %d grabs a chord starts on, or after a fall or a pause: %d chords, %d sounds" % [_chord_grabs, chord_sounds, played.size()])
			print("backing: %d chords sounded" % chord_sounds)
		"tune":
			_expect(chord_sounds == 0 and played.size() == _grabs_n and _grabs_n > 0,
				"a tune note sounded at each of the %d grabs: %d sounds, %d chords" % [_grabs_n, played.size(), chord_sounds])
			print("backing: %d tune notes sounded" % played.size())
		"":
			_expect(played.is_empty() and not _main_menu().get_node("Songs/Board/Rows/Grid/Backing").visible,
				"nothing backed and no Backing row: %d sounds" % played.size())
			print("backing: none for this part")


## The drill's chords sit game.drill_beats apart, each log on its chord's root, and the
## branches before it are its chord's notes, low to high (none with a chord every beat).
func _check_drill_spacing() -> void:
	var at: Array = game.notes.filter(func(n: Song.Note) -> bool: return n.chord != null).map(func(n: Song.Note) -> float: return n.beat)
	for k in range(1, at.size()):
		if not is_equal_approx(at[k] - at[k - 1], game.drill_beats):
			push_error("drill chords %.2f beats apart, not %d" % [at[k] - at[k - 1], game.drill_beats])
			return
	print("drill: %d chords, %d beats apart" % [at.size(), game.drill_beats])
	var logs := range(game.notes.size()).filter(func(i: int) -> bool: return game.notes[i].chord != null)
	for k in logs.size():
		var on: Song.Note = game.notes[logs[k]]
		var classes := Array(on.chord.midi).map(func(m: int) -> int: return posmod(m, 12))
		var run := game.notes.slice(logs[k - 1] + 1, logs[k]) if k > 0 else []
		var ok: bool = posmod(on.midi, 12) == classes[0] and (k == 0 or run.size() >= 2 or (game.drill_beats == 1 and run.is_empty()))
		for i in run.size():
			ok = ok and posmod(run[i].midi, 12) in classes and (i == 0 or run[i].midi > run[i - 1].midi)
		if not ok:
			push_error("drill: not so: log %d (%s on %s) has %s before it" % [k, on.chord.name, on.name, run.map(func(n: Song.Note) -> String: return n.name)])
			return
	print("drill: logs only, a chord every beat" if game.drill_beats == 1 else "drill: each log's chord on the branches before it, low to high")
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


## The message (why you fell, what was wrong) covers nothing you need to read: no standing
## chord sign on screen nor the key under it, nor where the tallest sign reaches, nor the
## percentage or the counters, and it stays on screen.
func _check_banner() -> void:
	var at: Rect2 = game.hud.banner_rect()
	if not at.has_area():
		return
	var covered: Array[String] = []
	for i in game.notes.size():
		var standing: ChordLog = game.world.chord_log(i)
		if standing == null or not game.notes[i].log_up:
			continue
		var board: Sprite2D = standing.get_node("Top/Sign/Board")
		var key: Label = standing.get_node("Top/Sign/Key")
		if at.intersects(board.get_global_transform_with_canvas() * board.get_rect()):
			covered.append("the %s sign" % game.notes[i].chord.name)
		if key.text != "" and at.intersects(key.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, key.size)):
			covered.append("the %s key" % game.notes[i].chord.name)
	var tallest := get_viewport().get_canvas_transform() * Vector2(0.0, ChordLog.SIGN_Y - ChordLog.TALL_BOARD.get_height() / 2.0)
	if at.end.y > tallest.y:
		covered.append("where a seventh's tall sign reaches")
	if at.intersects(game.hud.get_node("Progress").label_rect()):
		covered.append("the percentage")
	if at.intersects(_pill().get_global_rect()):
		covered.append("the counters")
	if not get_viewport().get_visible_rect().encloses(at):
		covered.append("the screen's edge")
	if not covered.is_empty():
		push_error("the banner %s covers %s" % [at, ", ".join(covered)])
	elif not _banner_ok:
		_banner_ok = true
		print("banner: clear of the signs")


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
			_resumed = true   # it grabs again at once: a new grab, even on the same branch
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
	elif _pauses == 0 and not _paused_looked and now - _paused_at >= PAUSE_FOR_MS / 2.0:
		_paused_looked = true
		_expect(game.song_player.sounding() == 0, "no backing while paused: %d sounding" % game.song_player.sounding())
		if not _silent_said:
			_silent_said = true
			print("backing: silent while paused")
		var rows := game.hud.get_node("PauseMenu/Center/Panel/Rows")
		_look("pause_continue")
		_expect_lit(_pause_buttons(), rows.get_node("Continue"), "the pause menu")
		_note("D", 4)
	elif now - _paused_at >= PAUSE_FOR_MS:
		var rows := game.hud.get_node("PauseMenu/Center/Panel/Rows")
		if _pauses == 0:
			_look("pause_restart")
			_expect_lit(_pause_buttons(), rows.get_node("Restart"), "the pause menu")
			_note("C", 4)
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
					for k in (4 if rows.get_node("Backing").visible else 3):
						_note("D", 3 + k)   # Tick, Backing (if shown), Labels, Chord sign
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
