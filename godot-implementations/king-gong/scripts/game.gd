extends Node2D
## King Gong, ported from concepts/002-king-gong/spike: the rules and the gorilla's pose.
## The scene shows the result: World (level.gd) holds the branches and the gorilla, Hud the
## bar and messages, Metronome the beat tick, NoteInput the MIDI and keyboard.

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
const Pose := preload("res://scripts/pose.gd")
const Level := preload("res://scripts/level.gd")
const Liana := preload("res://scripts/liana.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const Gorilla := preload("res://scripts/gorilla.gd")
const Hud := preload("res://scripts/hud.gd")
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
var song := 0                  # which of Song.library(); this and the next four are chosen on the start screen
var clef := Song.Clef.TREBLE
var chords := false            # the treble clef with chords: a log to break at every chord change
var hint := ChordLog.Hint.NAME   # what the sign on each log shows
var practice := false          # the magic bananas never run out

var notes: Array[Song.Note] = []
var bananas := 0
var falls := 0
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
var _left := {}            # left-hand notes held down, with chords
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
	hud.song_chosen.connect(set_song)
	hud.style_chosen.connect(set_style)
	hud.hint_chosen.connect(set_hint)
	hud.practice_toggled.connect(set_practice)
	hud.menu_pressed.connect(show_menu)
	if Array(OS.get_cmdline_user_args()).any(func(a: String) -> bool: return a in ["--autoplay", "--perf", "--chords"] or a.begins_with("--shots=") or a.begins_with("--song=")):
		add_child(preload("res://scripts/dev_autoplay.gd").new())
	now = now_ms()
	_last = now
	set_style(clef, chords)


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


func start() -> void:
	if started:
		return
	started = true
	hud.hide_overlay()
	restart()


func restart() -> void:
	notes = Song.parse(song, clef, chords)
	split = mini(60, notes.map(func(n: Song.Note) -> int: return n.midi).min())
	note_input.octave_shift = _keys_octave()
	note_input.set_chords(notes.map(func(n: Song.Note) -> Song.Chord: return n.chord).filter(func(c: Song.Chord) -> bool: return c != null))
	hud.show_key_notes(note_input.key_notes(), note_input.chord_key_notes())
	world.build(notes, Song.bar_lines(song, notes))
	_refresh_labels()
	hud.clear_messages()
	bananas = START_BANANAS
	falls = 0
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
	_update_hud()


## Lays song `i` out behind the start screen.
func set_song(i: int) -> void:
	song = i
	restart()


## The bass clef plays the song lower, the keyboard fallback too. `with_chords` adds the
## chords to the treble clef. The level is laid out again behind the start screen.
func set_style(c: Song.Clef, with_chords: bool) -> void:
	clef = c
	chords = with_chords
	$Clef/Treble.visible = c == Song.Clef.TREBLE
	$Clef/Bass.visible = c == Song.Clef.BASS
	restart()
	hud.show_chord_options(with_chords)


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


func set_practice(on: bool) -> void:
	practice = on
	_update_hud()


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
	if chords and m < split:
		_left[m] = true
		_left_changed(ts)
		return
	if not started:
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
	if chords and m < split:
		_left.erase(m)
		_left_changed(ts)
		return
	if not _blocked.is_empty() and m == notes[_blocked.j].midi:
		_blocked = {}   # let go before the log broke: play it again
		return
	if not started or state != State.HANG or m != notes[cur].midi:
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


## The left hand's notes changed. If they now make the chord of the log ahead, on time, the
## gorilla kicks the log down; and grabs the branch if its note was already played.
func _left_changed(ts: float) -> void:
	if not started or not state in [State.WAIT, State.HANG, State.AIR, State.REST]:
		return
	var j := cur if state == State.WAIT else cur + 1
	if j >= notes.size() or not notes[j].log_up or not notes[j].chord.is_played_by(_left.keys()):
		return
	if state != State.WAIT:
		var w := windows(cur, grab_t)
		if ts < w.next_lo or ts > w.next_hi + GRACE:
			return   # off the beat: the log stays up
	notes[j].log_up = false
	gorilla.kick(world.chord_log(j).kick_spot(), now_ms())
	world.chord_log(j).break_off()
	if _blocked.is_empty():
		return
	# from the magic banana the grab restarts the beat, so it counts from when both are down
	_grab(j, ts if state == State.WAIT else _blocked.ts, _blocked.jump)


func _grab(j: int, ts: float, jump: bool) -> void:
	_blend = {from = render.pos, rot = render.rot, t0 = now_ms(), dur = 260.0 if jump else 150.0, hop = 1.4 * S if jump else 0.0}
	_blocked = {}
	state = State.HANG
	cur = j
	grab_t = ts
	if tick_on:
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
	if _blocked.is_empty():
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
	var left := "practice mode" if practice else "%d banana%s left" % [bananas, "" if bananas == 1 else "s"]
	hud.show_end("Home in the nest!", "%d fall%s · %s · Enter plays again, Esc for the menu"
		% [falls, "" if falls == 1 else "s", left])


func _update(dt: float) -> void:
	match state:
		State.HANG:
			if now > windows(cur, grab_t).rel_hi + GRACE:
				_break_branch(cur)
		State.AIR, State.REST:
			if now > windows(cur, grab_t).next_hi + GRACE:
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
	hud.show_stats(-1 if practice else bananas, done_up_to, notes.size(), falls)


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


func _refresh_labels() -> void:
	world.show_labels(notes, labels, hint, note_input)


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
func _show_hung() -> void:
	var hung := cur if state == State.HANG else -1
	if _hung != hung and _hung >= 0:
		world.branch(_hung).set_strain(0.0, 0.0)
		world.branch(_hung).let_go()
	_hung = hung
	if hung < 0:
		return
	var w := windows(hung, grab_t)
	var crack := clampf((now - w.end) / w.tol, 0.0, 1.0) if now > w.end else 0.0
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
	gorilla.show_prompt(text, (1.4 if perch_stump else 3.0) * S)


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
			if state == State.HANG and p > 1.0:
				th = a + sin(now / 22.0) * 0.05 * clampf((p - 1.0) * 4.0, 0.0, 1.0)   # straining
			var pos := Staff.note_pos(n) + Vector2(sin(th), cos(th)) * RP * S
			if state == State.AIR:
				var air := Pose.new(pos, -th, &"reach")
				air.target = next
				return air
			var hang := Pose.new(pos, -th, &"hang")
			hang.grip = n
			hang.hand = cur % 2
			hang.target = null if n.rest_after > 0 else next
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
