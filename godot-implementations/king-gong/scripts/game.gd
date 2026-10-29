extends Node2D
## King Gong, ported from concepts/002-king-gong/spike: the rules and the gorilla's pose.
## The scene shows the result: World (level.gd) holds the branches and the gorilla, Hud the
## bar and messages, Metronome the beat tick, NoteInput the MIDI and keyboard.
##
## Besides playing a song by the spike's rules there is learn mode, where nothing is timed and
## the gorilla waits for each note and chord, and the chord drill, a made-up tune the gorilla
## climbs by itself, waiting at every log for its chord.

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
const Pose := preload("res://scripts/pose.gd")
const Level := preload("res://scripts/level.gd")
const Liana := preload("res://scripts/liana.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const Gorilla := preload("res://scripts/gorilla.gd")
const Hud := preload("res://scripts/hud.gd")
const Drill := preload("res://scripts/drill.gd")
const Metronome := preload("res://scripts/metronome.gd")
const NoteInput := preload("res://scripts/note_input.gd")

enum State { WAIT, HANG, AIR, REST, FALL, BOUNCE, OVER, WON }

const S := Staff.STEP
const START_BANANAS := 3
const TOL := 0.35          # timing window either side of the ideal moment, in beats (see tol_ms)
const GRACE := 25.0        # ms: an event that arrives just in time beats the frame-loop timeout
const SWING := 0.85        # pendulum half-angle, radians
const RP := 1.5            # shoulders hang this many staff steps below the grip
const LIANA_DIP := 0.95    # liana below LIANA_Y where the gorilla lands, in steps
const HOP := 1.5           # height of a bounce along the liana during a long rest, in steps

# settings, set from the HUD
var bpm := 60.0
var labels := true
var tick_on := true
var mode := Hud.Mode.PLAY      # this and the next seven are chosen on the start screen
var song := 0                  # which of Song.library()
var hint := ChordLog.Hint.NAME   # what the sign on each log shows
var practice := false          # the magic bananas never run out
var piano := true              # learn mode and the drill: the little keyboard lights what to play
var drill_kinds: Array = [Drill.Kind.MAJOR]   # the kinds of chord the drill draws from
var _style := {clef = Song.Clef.TREBLE, chords = false, by_itself = false}   # how the songs are played

# how this level is played: the songs' style, or the drill's
var clef := Song.Clef.TREBLE
var chords := false            # the treble clef with chords: a log to break at every chord change
var by_itself := false         # with chords: the gorilla plays the tune itself, you only the chords

var notes: Array[Song.Note] = []
var bananas := 0
var falls := 0
var misses := 0            # learn mode and the drill: wrong notes and chords
var done_up_to := 0
var started := false
var split := 60            # with chords, the notes below this are the left hand's: middle C, or the melody's lowest note

# `cur` is the branch being hung on (HANG, AIR, REST) or waited for (WAIT, FALL, BOUNCE).
# Every window is measured from `grab_t`, the grab of branch `cur`, never from a global clock.
var state := State.WAIT
var cur := 0
var grab_t := 0.0
var rel_t := 0.0
var rel_pose: Pose
var perch_stump := true
var fall_pos := Vector2.ZERO
var fall_vel := Vector2.ZERO
var fall_rot := 0.0
var fall_spin := 0.0
var _left := {}            # left-hand notes held down, with chords; every note when the gorilla plays the tune
var _right := {}           # the other notes held down
var _wrong := {}           # learn mode: notes held down that were wrong
var _missed_chord := false # learn mode and the drill: a wrong chord was counted, not again until the left hand lets go
var _stale := {}           # left-hand notes still held from the last chord played: they make no wrong chord
var _blocked := {}         # the next branch's note, played while its log still stood: {j, ts, jump}; empty when none
var land_t := 0.0
var bounce_t0 := 0.0

var now := 0.0             # ms, this frame
var render: Pose
var _blend := {}           # eases into a new pose: {from, rot, t0, dur, hop}; empty when idle
var _hung := -1            # branch shown hung on, if any
var _dipping := -1         # note whose liana is shown dipping, if any
var _last := 0.0

@onready var world: Level = $World
@onready var gorilla: Gorilla = $World/Gorilla
@onready var camera: Camera2D = $Camera
@onready var hud: Hud = $Hud
@onready var metronome: Metronome = $Metronome
@onready var note_input: NoteInput = $NoteInput


static func now_ms() -> float:
	return Time.get_ticks_usec() / 1000.0


func _ready() -> void:
	# Without a working GPU driver Windows renders in software, and vsync there stutters at
	# ~40 fps. Capping at 60 without vsync is steady.
	if RenderingServer.get_video_adapter_name().contains("Basic Render Driver"):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 60
	note_input.note_on.connect(note_on)
	note_input.note_off.connect(note_off)
	note_input.source_changed.connect(_on_source_changed)
	note_input.start_requested.connect(start)
	note_input.restart_requested.connect(_on_restart_key)
	note_input.menu_requested.connect(_on_menu_key)
	hud.start_pressed.connect(start)
	hud.restart_pressed.connect(restart)
	hud.tempo_changed.connect(func(v: float) -> void: bpm = v)
	hud.labels_toggled.connect(_on_labels_toggled)
	hud.tick_toggled.connect(_on_tick_toggled)
	hud.mode_chosen.connect(set_mode)
	hud.song_chosen.connect(set_song)
	hud.style_chosen.connect(set_style)
	hud.hint_chosen.connect(set_hint)
	hud.kinds_chosen.connect(set_drill_kinds)
	hud.practice_toggled.connect(set_practice)
	hud.piano_toggled.connect(set_piano)
	hud.menu_pressed.connect(show_menu)
	var dev_flags := ["--autoplay", "--perf", "--chords", "--chords-only", "--learn", "--drill"]
	if Array(OS.get_cmdline_user_args()).any(func(a: String) -> bool: return a in dev_flags or a.begins_with("--shots=") or a.begins_with("--song=")):
		add_child(preload("res://scripts/dev_autoplay.gd").new())
	now = now_ms()
	_last = now
	set_style(_style.clef, _style.chords, _style.by_itself)


func _process(_delta: float) -> void:
	now = now_ms()
	var dt := minf(0.05, (now - _last) / 1000.0)
	_last = now
	if started:
		_update(dt)
	render = _apply_blend(_pose())
	gorilla.show_pose(render, now)
	camera.position.x = _camera_x()
	_show_hung()
	_show_liana()
	_show_prompt()
	_show_piano()


func start() -> void:
	if started:
		return
	started = true
	hud.hide_overlay()
	restart()


func restart() -> void:
	var drill := mode == Hud.Mode.DRILL
	clef = Song.Clef.TREBLE if drill else _style.clef
	chords = drill or _style.chords
	by_itself = drill or _style.by_itself
	$Clef/Treble.visible = clef == Song.Clef.TREBLE
	$Clef/Bass.visible = clef == Song.Clef.BASS
	var bars: Array
	if drill:   # new chords every time
		notes = Song.parse_entries(Drill.entries(drill_kinds), clef, true)
		bars = notes.filter(func(n: Song.Note) -> bool: return n.chord != null and n.beat > 0.0).map(func(n: Song.Note) -> float: return n.beat)
	else:
		notes = Song.parse(song, clef, chords)
		bars = Song.bar_lines(song, notes)
	split = mini(60, notes.map(func(n: Song.Note) -> int: return n.midi).min())
	note_input.octave_shift = _keys_octave()
	world.build(notes, bars)
	_set_chord_keys()
	hud.clear_messages()
	bananas = START_BANANAS if mode == Hud.Mode.PLAY else 0
	falls = 0
	misses = 0
	_wrong.clear()
	_missed_chord = false
	_stale.clear()
	done_up_to = 0
	metronome.cancel_ticks()
	state = State.WAIT
	cur = 0
	perch_stump = true
	_blend = {}
	_blocked = {}
	_hung = -1
	_dipping = -1
	render = _pose()
	camera.position.x = _camera_x()
	camera.reset_smoothing()
	_setup_piano()
	_update_hud()


## Play, learn or drill; the level is laid out again behind the start screen.
func set_mode(m: Hud.Mode) -> void:
	mode = m
	restart()
	hud.show_options(mode, _style.chords, _style.by_itself)


## Lays song `i` out behind the start screen.
func set_song(i: int) -> void:
	song = i
	restart()


## How the songs are played. The bass clef plays the song lower, the keyboard fallback too.
## `with_chords` adds the chords to the treble clef; `itself`, the gorilla plays the tune and
## you only the chords. The level is laid out again behind the start screen.
func set_style(c: Song.Clef, with_chords: bool, itself := false) -> void:
	_style = {clef = c, chords = with_chords, by_itself = itself}
	restart()
	hud.show_options(mode, with_chords, itself)


## The octave of the computer keys, from C: the one that plays the most of the song.
func _keys_octave() -> int:
	var best := 0
	var most := -1
	for octave in range(-3, 3):
		var hits := notes.filter(func(n: Song.Note) -> bool: return n.midi >= 60 + 12 * octave and n.midi <= 72 + 12 * octave).size()
		if hits > most:
			best = octave
			most = hits
	return best


func set_hint(h: ChordLog.Hint) -> void:
	hint = h
	_refresh_labels()


## The drill's chords are drawn from these Drill.Kinds.
func set_drill_kinds(kinds: Array) -> void:
	drill_kinds = kinds
	if mode == Hud.Mode.DRILL:
		restart()


func set_practice(on: bool) -> void:
	practice = on
	_update_hud()


func set_piano(on: bool) -> void:
	piano = on
	_setup_piano()


## Back to the start screen, with the level laid out again behind it.
func show_menu() -> void:
	started = false
	restart()
	hud.show_overlay()


func beat_ms() -> float:
	return 60000.0 / bpm


## The timing window either side of branch `i`'s let-go and of the next grab, in ms. A note or
## rest shorter than a beat narrows it, so an eighth can't be held like a quarter.
func tol_ms(i: int) -> float:
	var shortest := minf(1.0, notes[i].beats)
	if notes[i].rest_after > 0.0:
		shortest = minf(shortest, notes[i].rest_after)
	return TOL * shortest * beat_ms()


func windows(i: int, g: float) -> Dictionary:
	var n := notes[i]
	var end := g + n.beats * beat_ms()
	var next := end + n.rest_after * beat_ms()
	var tol := tol_ms(i)
	return {end = end, tol = tol, rel_lo = end - tol, rel_hi = end + tol, next = next, next_lo = next - tol, next_hi = next + tol}


## A rest is one bounce on the liana per beat of it, at least one. The gorilla lets go at `t0`,
## each bounce takes `each` ms and lands 45% of the way in, and the last one throws it up to
## the next branch, due at `t2`.
func rest_times() -> Dictionary:
	var t2: float = windows(cur, grab_t).next
	var bounces := maxi(1, roundi(notes[cur].rest_after))
	return {t0 = rel_t, t2 = t2, bounces = bounces, each = (t2 - rel_t) / bounces}


func _landing_t(rt: Dictionary, b: int) -> float:
	return rt.t0 + (b + 0.45) * rt.each


## The landings are spread along the liana, one per beat of the rest.
func _landing_pos(rt: Dictionary, b: int) -> Vector2:
	var n := notes[cur]
	var x := Staff.x_of(n.beat + n.beats + (b + 0.5) * n.rest_after / rt.bounces)
	return Vector2(x, Staff.LIANA_Y + LIANA_DIP * S - 1.7 * S)


## Where the gorilla floats on its magic banana, waiting to retry branch `r`: left of the
## branch, and of its log if it has one.
func wait_spot(r: int) -> Vector2:
	var spot := Staff.note_pos(notes[r]) + Vector2(-2.1, 1.7) * S
	if notes[r].chord:
		spot.x = minf(spot.x, Staff.x_of(notes[r].beat) - 0.9 * S)
	return spot


# ---------------------------------------------------------------- rules

func note_on(m: int, ts: float) -> void:
	if hud.menu_up():
		# menus are worked from the MIDI keyboard; on the computer keyboard there is the mouse
		if note_input.source == "MIDI" and not hud.choose(m) and not started:
			start()   # any note that picks nothing; it grabs nothing either
		return
	if chords and (by_itself or m < split):
		_left[m] = true
		_left_changed(ts, true)
		return
	_right[m] = true
	if not started:
		return
	if mode != Hud.Mode.PLAY:
		_learn_note(m, ts)
		return
	if state == State.WAIT:
		var n := notes[cur]
		if m != n.midi:
			_fall("Wrong note: %s. That branch is %s" % [Song.note_name(m), n.name], cur)
		elif n.log_up:
			_blocked = {j = cur, ts = ts, jump = false}
		else:
			_grab(cur, ts, false)
		return
	if state != State.HANG and state != State.AIR and state != State.REST:
		return
	var i := cur
	var j := i + 1
	var w := windows(i, grab_t)
	var hanging := state == State.HANG
	if j >= notes.size():
		_fall("Wrong note: %s. Last branch: hold it, then let go" % Song.note_name(m), i)
		return
	var nj := notes[j]
	if m != nj.midi:
		_fall("Wrong note: %s. The next branch is %s" % [Song.note_name(m), nj.name], j)
		return
	if hanging and notes[i].rest_after > 0:
		_fall("Too early. There is a rest: let go and bounce off the liana first", i)
		return
	if ts < w.next_lo:
		if hanging:
			_fall("Too early. %s is %s long" % [notes[i].name, Song.beats_word(notes[i].beats)], i)
		else:
			_fall("Too early. Wait for the rest to end", j)
		return
	if ts > w.next_hi + GRACE:
		if hanging:
			_break_branch(i)
		else:
			_fall("Too late. Missed the branch", j)
		return
	var jump := state != State.REST and absi(nj.step - notes[i].step) > 2   # more than a third apart
	if hanging:
		_complete(i)
	if nj.log_up:
		_blocked = {j = j, ts = ts, jump = jump}   # grabbed once the chord breaks the log
		if hanging:
			state = State.AIR
		return
	_grab(j, ts, jump)


func note_off(m: int, ts: float) -> void:
	_right.erase(m)
	_wrong.erase(m)
	if chords and (by_itself or m < split):
		_left.erase(m)
		_stale.erase(m)
		_left_changed(ts, false)
		return
	if not _blocked.is_empty() and m == notes[_blocked.j].midi:
		_blocked = {}   # let go before the log broke: play it again
		return
	if not started or state != State.HANG or m != notes[cur].midi:
		return
	if mode != Hud.Mode.PLAY:
		if cur == notes.size() - 1:   # learn mode: let go of the last branch to finish
			_complete(cur)
			_win()
		return
	var i := cur
	var w := windows(i, grab_t)
	if ts < w.rel_lo:
		_fall("Let go too early. %s is %s long" % [notes[i].name, Song.beats_word(notes[i].beats)], i)
		return
	if ts > w.rel_hi + GRACE:
		_break_branch(i)
		return
	_complete(i)
	if i == notes.size() - 1:
		_win()
		return
	state = State.REST if notes[i].rest_after > 0 else State.AIR
	rel_t = ts
	rel_pose = render


## Learn mode: the gorilla waits for the next branch's note, however long it takes, and for
## the chord too if a log stands before it. A wrong note only counts.
func _learn_note(m: int, ts: float) -> void:
	if state != State.WAIT and state != State.HANG:
		return
	var j := cur if state == State.WAIT else cur + 1
	if j >= notes.size():
		return
	if m != notes[j].midi:
		_wrong[m] = true
		_miss("Not %s: the next branch is %s" % [Song.note_name(m), notes[j].name])
		return
	var jump := state == State.HANG and (notes[cur].rest_after > 0 or absi(notes[j].step - notes[cur].step) > 2)
	if state == State.HANG:
		_complete(cur)
	if notes[j].log_up:
		_blocked = {j = j, ts = ts, jump = jump}   # grabbed once the chord breaks the log
		return
	_grab(j, ts, jump)


## The left hand's notes changed, a note `pressed` or let go. If they now make the chord of the
## log ahead, on time when playing, the gorilla kicks the log down. In learn mode and the drill
## a wrong chord counts, played with fresh notes: not while letting go of the last chord.
func _left_changed(ts: float, pressed: bool) -> void:
	if _left.is_empty():
		_missed_chord = false
	var j := _log_ahead()
	if j < 0:
		return
	var chord := notes[j].chord
	if chord.is_played_by(_left.keys()):
		if mode == Hud.Mode.PLAY and state != State.WAIT:
			var w := windows(cur, grab_t)
			if ts < w.next_lo or ts > w.next_hi + GRACE:
				return   # off the beat: the log stays up
		_break_log(j, ts)
		return
	if not pressed or mode == Hud.Mode.PLAY or _missed_chord:
		return
	var fresh := _left.keys().filter(func(m: int) -> bool: return not _stale.has(m))
	if fresh.size() >= chord.midi.size() and not chord.is_played_by(fresh):
		_missed_chord = true
		_miss("That isn't %s: play %s" % [chord.name, " ".join(chord.tones)])


## The branch whose log the left hand would break now, if that log still stands; else -1.
func _log_ahead() -> int:
	if not started or not state in [State.WAIT, State.HANG, State.AIR, State.REST]:
		return -1
	var j := cur if state == State.WAIT else cur + 1
	return j if j < notes.size() and notes[j].log_up else -1


## The chord is in: the gorilla kicks down the log before branch `j`, and grabs the branch if
## its note was already played.
func _break_log(j: int, ts: float) -> void:
	notes[j].log_up = false
	_stale = _left.duplicate()
	gorilla.kick(world.chord_log(j).kick_spot(), now_ms())
	world.chord_log(j).break_off()
	if mode == Hud.Mode.DRILL:
		_set_chord_keys()
	_update_hud()
	if by_itself and state == State.HANG:
		_catch_up()
	if _blocked.is_empty():
		return
	# from the magic banana, and in learn mode, the grab restarts the beat, so it counts from when both are down
	_grab(j, ts if state == State.WAIT or mode != Hud.Mode.PLAY else _blocked.ts, _blocked.jump)


## The gorilla waited at the end of its branch for the chord: the beat restarts from now, as
## if the branch had been that much longer.
func _catch_up() -> void:
	var late: float = now_ms() - windows(cur, grab_t).end
	if late <= 0.0:
		return
	grab_t += late
	if tick_on:
		metronome.schedule_ticks(grab_t, beat_ms(), notes[cur].beats, notes[cur].rest_after)


## Chords only: the gorilla plays the tune by itself, on the beat. In learn mode and the drill
## it waits at the end of a branch while the log after it stands.
func _play_tune() -> void:
	match state:
		State.WAIT:
			if not _blocked.is_empty():
				return
			if notes[cur].log_up:
				_blocked = {j = cur, ts = now, jump = false}   # grabbed once the chord breaks the log
			else:
				_grab(cur, now, false)
		State.HANG:
			var w := windows(cur, grab_t)
			if now < w.end:
				return
			if cur == notes.size() - 1:
				_complete(cur)
				_win()
				return
			if mode != Hud.Mode.PLAY and notes[cur + 1].log_up:
				return
			_complete(cur)
			state = State.REST if notes[cur].rest_after > 0 else State.AIR
			rel_t = w.end
			rel_pose = render
		State.AIR, State.REST:
			var w := windows(cur, grab_t)
			if now < w.next or not _blocked.is_empty():
				return
			var j := cur + 1
			var jump := state != State.REST and absi(notes[j].step - notes[cur].step) > 2
			if notes[j].log_up:
				_blocked = {j = j, ts = w.next, jump = jump}   # grabbed if the chord comes in time
			else:
				_grab(j, w.next, jump)


func _miss(why: String) -> void:
	misses += 1
	hud.show_banner(why)
	_update_hud()


func _grab(j: int, ts: float, jump: bool) -> void:
	_blend = {from = render.pos, rot = render.rot, t0 = now_ms(), dur = 260.0 if jump else 150.0, hop = 1.4 * S if jump else 0.0}
	_blocked = {}
	state = State.HANG
	cur = j
	grab_t = ts
	if tick_on and (mode == Hud.Mode.PLAY or by_itself):   # in learn mode there is no beat to keep
		metronome.schedule_ticks(ts, beat_ms(), notes[j].beats, notes[j].rest_after)
	else:
		metronome.cancel_ticks()


func _complete(i: int) -> void:
	done_up_to = maxi(done_up_to, i + 1)
	var n := notes[i]
	world.branch(i).mark_done()
	if n.banana and not n.taken:
		n.taken = true
		bananas += 1
		world.branch(i).take_banana()
		hud.fly_banana(get_viewport().get_canvas_transform() * world.branch(i).banana_spot())
	_update_hud()


func _break_branch(i: int) -> void:
	world.branch(i).break_off()
	_fall("Held too long. The branch broke", i)


## The gorilla runs into the log before branch `j`: the log shakes, the gorilla drops back.
func _bump_log(j: int) -> void:
	world.chord_log(j).wobble()
	var chord := notes[j].chord.name
	if by_itself:
		_fall("No %s chord in time, so the log stayed up" % chord, j, true)
	elif _blocked.is_empty():
		_fall("Too late. Missed the branch and its %s chord" % chord, j, true)
	else:
		_fall("No %s chord, so the log stayed up. Play it together with %s" % [chord, notes[j].name], j, true)


## `resume` is the branch the magic banana brings you back to. `back`: thrown back, off a log.
func _fall(reason: String, resume: int, back := false) -> void:
	falls += 1
	metronome.cancel_ticks()
	state = State.FALL
	cur = resume
	_blocked = {}
	fall_pos = render.pos
	fall_rot = render.rot
	fall_vel = Vector2(-1.5 if back else 1.5, -3.0) * S
	fall_spin = 3.0 if randf() < 0.5 else -3.0
	land_t = 0.0
	_blend = {}
	hud.show_banner(reason)
	_update_hud()


func _win() -> void:
	metronome.cancel_ticks()
	_blend = {from = render.pos, rot = render.rot, t0 = now_ms(), dur = 450.0, hop = 1.5 * S}
	state = State.WON
	var wrong := "no mistakes" if misses == 0 else "%d mistake%s" % [misses, "" if misses == 1 else "s"]
	match mode:
		Hud.Mode.LEARN:
			hud.show_end("Home in the nest!", "%s · now try it in Play mode · Enter plays again, Esc for the menu" % wrong)
		Hud.Mode.DRILL:
			hud.show_end("All %d chords played!" % notes.filter(func(n: Song.Note) -> bool: return n.chord != null).size(),
				"%s · Enter for new chords, Esc for the menu" % wrong)
		_:
			var left := "practice mode" if practice else "%d banana%s left" % [bananas, "" if bananas == 1 else "s"]
			hud.show_end("Home in the nest!", "%d fall%s · %s · Enter plays again, Esc for the menu"
				% [falls, "" if falls == 1 else "s", left])


func _update(dt: float) -> void:
	if mode != Hud.Mode.PLAY:
		var j := _log_ahead()
		if j >= 0 and notes[j].chord.is_played_by(_left.keys()):
			_break_log(j, now)   # the chord was held down before its log came up
	if by_itself:
		_play_tune()
	match state:
		State.HANG:
			if mode == Hud.Mode.PLAY and not by_itself and now > windows(cur, grab_t).rel_hi + GRACE:
				_break_branch(cur)
		State.AIR, State.REST:
			if mode == Hud.Mode.PLAY and now > windows(cur, grab_t).next_hi + GRACE:
				if notes[cur + 1].log_up:
					_bump_log(cur + 1)
				else:
					_fall("Too late. Missed the branch", cur + 1)
		State.FALL:
			if land_t == 0.0:
				fall_vel.y += 40.0 * S * dt
				fall_pos += fall_vel * dt
				fall_rot += fall_spin * dt
				if fall_pos.y >= Staff.FLOOR_Y - 1.7 * S:
					fall_pos.y = Staff.FLOOR_Y - 1.7 * S
					fall_rot = 0.0
					land_t = now
			elif now - land_t > 550.0:
				if practice or bananas > 0:
					if not practice:
						bananas -= 1
						_update_hud()
					state = State.BOUNCE
					bounce_t0 = now
					world.pop_banana(Vector2(fall_pos.x, Staff.FLOOR_Y - 0.25 * S))
				else:
					state = State.OVER
					hud.show_end("Out of magic bananas", "Made it to branch %d of %d · Enter tries again, Esc for the menu"
						% [done_up_to, notes.size()])
		State.BOUNCE:
			if now - bounce_t0 > 1100.0:
				world.branch(cur).restore()
				state = State.WAIT
				perch_stump = false


func _update_hud() -> void:
	var progress := "branch %d/%d" % [done_up_to, notes.size()]
	if mode == Hud.Mode.DRILL:
		var logs := notes.filter(func(n: Song.Note) -> bool: return n.chord != null)
		progress = "chord %d/%d" % [logs.filter(func(n: Song.Note) -> bool: return not n.log_up).size(), logs.size()]
	var missed := "falls %d" % falls if mode == Hud.Mode.PLAY else "wrong %d" % misses
	hud.show_stats(-1 if practice and mode == Hud.Mode.PLAY else bananas, progress, missed)


# ---------------------------------------------------------------- settings

func _on_restart_key() -> void:
	if started:
		restart()


func _on_menu_key() -> void:
	if started:
		show_menu()


func _on_labels_toggled(on: bool) -> void:
	labels = on
	_refresh_labels()


func _on_source_changed(source: String) -> void:
	hud.show_source(source)
	_refresh_labels()
	_setup_piano()


func _refresh_labels() -> void:
	world.show_labels(notes, labels, ChordLog.Hint.NAME if mode == Hud.Mode.DRILL else hint, note_input, not by_itself)


## The chord keys of the keyboard fallback, one per root: the song's chords, or in the drill
## every root in the kind of chord the next log wants, so a wrong key plays a wrong chord.
func _set_chord_keys() -> void:
	var keyed := notes.map(func(n: Song.Note) -> Song.Chord: return n.chord).filter(func(c: Song.Chord) -> bool: return c != null)
	if mode == Hud.Mode.DRILL:
		var ahead := notes.filter(func(n: Song.Note) -> bool: return n.log_up)
		if not ahead.is_empty():
			var quality: String = ahead[0].chord.name.substr(1)
			keyed = []
			for root in Song.LETTERS:
				keyed.append(Song.parse_chord(root + quality))
	note_input.set_chords(keyed)
	hud.show_key_notes(note_input.key_notes(), note_input.chord_key_notes())
	_refresh_labels()


func _on_tick_toggled(on: bool) -> void:
	tick_on = on
	if not on:
		metronome.cancel_ticks()


# ---------------------------------------------------------------- what the scene shows

## The camera keeps the gorilla 30% in from the left edge (it eases there by itself).
func _camera_x() -> float:
	return render.pos.x - get_viewport_rect().size.x * 0.3


## The branch being hung on breaks away from the left as the note runs, its last piece
## falling at the moment to let go; it sags, and cracks once the note has run past its length.
## Where nothing is timed it only sags, and waiting for a chord it never cracks.
func _show_hung() -> void:
	var hung := cur if state == State.HANG else -1
	if _hung != hung and _hung >= 0:
		world.branch(_hung).set_strain(0.0, 0.0)
		world.branch(_hung).let_go()
	_hung = hung
	if hung < 0:
		return
	if mode != Hud.Mode.PLAY and not by_itself:
		world.branch(hung).set_strain(0.08 * S, 0.0)
		return
	var w := windows(hung, grab_t)
	var crack := clampf((now - w.end) / w.tol, 0.0, 1.0) if now > w.end and mode == Hud.Mode.PLAY else 0.0
	world.branch(hung).crumble((now - grab_t) / (notes[hung].beats * beat_ms()))
	world.branch(hung).set_strain((0.08 + crack * 0.35) * S, crack)


## The liana under a rest dips where the gorilla lands in it, then springs back, once per bounce.
func _show_liana() -> void:
	var resting := cur if state == State.REST else -1
	if _dipping != resting and _dipping >= 0:
		world.liana(_dipping).set_sag(Liana.SLACK)
	_dipping = resting
	if resting < 0:
		return
	var rt := rest_times()
	var b := clampi(roundi((now - rt.t0) / rt.each - 0.45), 0, rt.bounces - 1)   # the nearest landing
	var d := now - _landing_t(rt, b)
	var k: float = clampf(1.0 + d / (0.06 * rt.each), 0.0, 1.0) if d < 0.0 else clampf(1.0 - d / (0.3 * rt.each), 0.0, 1.0)
	var liana := world.liana(resting)
	liana.set_sag(Liana.SLACK + (LIANA_DIP + 0.3 - 0.45) * S * k, lerpf(0.5, liana.across(_landing_pos(rt, b).x), k))


func _show_prompt() -> void:
	if state != State.WAIT or not started:
		gorilla.show_prompt("", 0.0)
		return
	var n := notes[cur]
	var key := note_input.key_for(n.midi)
	var branch := "the next branch"
	if labels:
		branch = n.name + (" (key %s)" % key if key != "" else "")
	var text := ("Play the log's chord and %s" if n.log_up else "Play %s to grab it") % branch
	if by_itself:
		text = "Play the log's chord" if n.log_up else ""
	gorilla.show_prompt(text, (1.4 if perch_stump else 3.0) * S)


## The little keyboard, in learn mode and the drill: two octaves for the chord, below the tune
## when you play it too, and the tune's range (an octave at least) for the note.
func _setup_piano() -> void:
	if mode == Hud.Mode.PLAY or not piano:
		hud.set_piano(-1, -1, -1)
		return
	var chord_from := -1
	if chords:
		chord_from = 48 if by_itself else 12 * floori((split - 24) / 12.0)   # the two octaves below the tune's
	if by_itself:
		hud.set_piano(chord_from, -1, -1)
		return
	var pitches := notes.map(func(n: Song.Note) -> int: return n.midi)
	var lo: int = pitches.min()
	var hi: int = maxi(pitches.max(), lo + 11)
	var letters := {}
	for m in range(lo, hi + 1):
		if note_input.key_for(m) != "":
			letters[m] = note_input.key_for(m)
	hud.set_piano(chord_from, lo, hi, letters)


## Lights what to play next: the tune's next note and the chord of its log. When the gorilla
## plays the tune, the chord of the next log, however far ahead.
func _show_piano() -> void:
	if mode == Hud.Mode.PLAY or not piano:
		return
	var j := cur if state == State.WAIT else cur + 1
	var note: Song.Note = null
	var chord: Song.Chord = null
	if by_itself:
		for k in range(j, notes.size()):
			if notes[k].log_up:
				chord = notes[k].chord
				break
	elif j < notes.size() and state != State.WON:
		note = notes[j]
		chord = note.chord if note.log_up else null
	var wrong_left: Array = []
	if _missed_chord and chord:
		wrong_left = _left.keys().filter(func(m: int) -> bool: return not chord.midi.any(func(c: int) -> bool: return c % 12 == m % 12))
	hud.light_piano(chord, note, _left.keys(), _right.keys(), wrong_left, _wrong.keys())


# ---------------------------------------------------------------- pose

func _pose() -> Pose:
	var a := SWING
	match state:
		State.WAIT:
			if perch_stump:
				return Pose.new(Staff.stump_spot(notes[0]), 0.0, &"perch")
			return Pose.new(wait_spot(cur) + Vector2(0.0, sin(now / 320.0) * 0.12 * S), 0.0, &"balloon")
		State.HANG, State.AIR:
			# one pendulum per note: from behind the grip to the front of the swing, arriving when the note's length is up
			var n := notes[cur]
			var next: Song.Note = notes[cur + 1] if cur + 1 < notes.size() else null
			var p := (now - grab_t) / (n.beats * beat_ms())
			var th := -a + a * (1.0 - cos(PI * clampf(p, 0.0, 1.0)))
			if state == State.HANG and p > 1.0 and mode == Hud.Mode.PLAY:
				th = a + sin(now / 22.0) * 0.05 * clampf((p - 1.0) * 4.0, 0.0, 1.0)   # straining
			elif state == State.HANG and p > 1.0:   # waiting: swings back and comes to rest
				var since := (p - 1.0) * n.beats * beat_ms()
				th = a * cos(since / 380.0) * exp(-since / 900.0)
			var pos := Staff.note_pos(n) + Vector2(sin(th), cos(th)) * RP * S
			if state == State.AIR:
				var air := Pose.new(pos, -th, &"reach")
				air.target = next
				return air
			var hang := Pose.new(pos, -th, &"hang")
			hang.grip = n
			hang.hand = cur % 2
			hang.target = null if n.rest_after > 0 and (mode == Hud.Mode.PLAY or by_itself) else next
			hang.reach_k = smoothstep(0.0, 1.0, (p - 0.35) / 0.6)
			return hang
		State.REST:
			# drop into the liana, bounce along it once per beat, then up to the next branch
			var j := notes[cur + 1]
			var rt := rest_times()
			var b := clampi(floori((now - rt.t0) / rt.each - 0.45), -1, rt.bounces - 1)   # the last landing so far
			if b < 0:
				var l := _landing_pos(rt, 0)
				var drop := clampf((now - rt.t0) / (_landing_t(rt, 0) - rt.t0), 0.0, 1.0)
				var into := Vector2(lerpf(rel_pose.pos.x, l.x, drop), lerpf(rel_pose.pos.y, l.y, drop * drop))
				return Pose.new(into, lerpf(rel_pose.rot, 0.0, drop), &"up")
			var from := _landing_pos(rt, b)
			var since := now - _landing_t(rt, b)
			if b < rt.bounces - 1:
				var v: float = since / rt.each
				var to := _landing_pos(rt, b + 1)
				return Pose.new(Vector2(lerpf(from.x, to.x, v), from.y - 4.0 * v * (1.0 - v) * HOP * S), 0.0, &"up")
			var e := Staff.note_pos(j) + Vector2(-sin(a), cos(a)) * RP * S
			var k := clampf(since / (rt.t2 - _landing_t(rt, b)), 0.0, 1.0)
			var rising := Pose.new(Vector2(lerpf(from.x, e.x, k), lerpf(from.y, e.y, 1.0 - (1.0 - k) * (1.0 - k))), 0.0,
				&"reach" if k > 0.4 else &"up")
			rising.target = j
			return rising
		State.FALL:
			return Pose.new(fall_pos, fall_rot, &"sit" if land_t > 0.0 else &"fall")
		State.OVER:
			return Pose.new(fall_pos, 0.0, &"sit")
		State.BOUNCE:
			var k := (now - bounce_t0) / 1100.0
			if k < 0.3:
				return Pose.new(fall_pos + Vector2(0.0, sin(k / 0.3 * PI) * 0.25 * S), 0.0, &"sit")
			var w := wait_spot(cur)
			var e := clampf((k - 0.3) / 0.7, 0.0, 1.0)
			var ee := 1.0 - (1.0 - e) * (1.0 - e)
			var pos := Vector2(lerpf(fall_pos.x, w.x, ee), lerpf(fall_pos.y, w.y, ee) - sin(PI * e) * 2.5 * S)
			return Pose.new(pos, 0.0, &"balloon")
		_:   # WON
			var h := Staff.home_spot(notes[-1])
			return Pose.new(h - Vector2(0.0, absf(sin(now / 250.0)) * 0.3 * S), 0.0, &"up")


func _apply_blend(target: Pose) -> Pose:
	if _blend.is_empty():
		return target
	var k: float = (now - _blend.t0) / _blend.dur
	if k >= 1.0:
		_blend = {}
		return target
	var e := smoothstep(0.0, 1.0, k)
	target.pos = Vector2(lerpf(_blend.from.x, target.pos.x, e), lerpf(_blend.from.y, target.pos.y, e) - sin(PI * k) * _blend.hop)
	target.rot = lerpf(_blend.rot, target.rot, e)
	if _blend.hop > 0.0:
		target.kind = &"up"
	return target
