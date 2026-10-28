extends Node2D
## King Gong, ported from concepts/002-king-gong/spike: the rules, the layout and the
## gorilla's pose. Drawing lives in view.gd, sound in synth.gd, input in note_input.gd.

const Song := preload("res://scripts/song.gd")
const Synth := preload("res://scripts/synth.gd")
const NoteInput := preload("res://scripts/note_input.gd")

enum State { WAIT, HANG, AIR, REST, FALL, BOUNCE, OVER, WON }

const START_BANANAS := 3
const TOL := 0.35          # timing window either side of the ideal moment, in beats
const GRACE := 25.0        # ms: an event that arrives just in time beats the frame-loop timeout
const SWING := 0.85        # pendulum half-angle, radians
const RP := 1.5            # shoulders hang this many staff steps below the grip
const LIANA_DIP := 0.95    # liana midpoint below liana_y when the gorilla lands, in steps


## Where the gorilla is and what its arms are doing. Kinds: perch, balloon, hang, reach,
## up, fall, sit.
class Pose:
	var pos: Vector2
	var rot: float
	var kind: StringName
	var grip: Song.Note
	var hand := 0
	var target: Song.Note
	var reach_k := 0.0

	func _init(p: Vector2, r: float, k: StringName) -> void:
		pos = p
		rot = r
		kind = k


@onready var view: Node2D = $View
@onready var synth: Synth = $Synth
@onready var note_input: NoteInput = $NoteInput
@onready var hud = $Hud

# settings, set from the HUD
var bpm := 60.0
var labels := true
var tick_on := true

# layout, recomputed every frame like the spike does on resize
var view_size := Vector2.ZERO
var hud_h := 0.0
var s := 0.0               # one staff step (half a line spacing), in pixels
var sky_top := 0.0
var c4_y := 0.0
var liana_y := 0.0
var floor_y := 0.0
var ppb := 0.0             # pixels per beat unit

var notes: Array[Song.Note] = []
var bars: Array[float] = []
var bananas := 0
var falls := 0
var done_up_to := 0
var started := false

# `cur` is the branch being hung on (HANG, AIR, REST) or waited for (WAIT, FALL, BOUNCE).
# Every window is measured from `grab_t`, the grab of branch `cur`, never from a global clock.
var state := State.WAIT
var cur := 0
var grab_t := 0.0
var rel_t := 0.0
var rel_pose: Pose
var perch_stump := true
var creaked := false
var boinged := false
var fall_pos := Vector2.ZERO
var fall_vel := Vector2.ZERO
var fall_rot := 0.0
var fall_spin := 0.0
var land_t := 0.0
var bounce_t0 := 0.0
var bounce_from := Vector2.ZERO

var now := 0.0             # ms, this frame
var render: Pose
var cam_x := 0.0
var banner := ""
var banner_t := 0.0
var flyers: Array[Dictionary] = []   # collected bananas flying to the counter: {t0, pos}
var _blend := {}           # eases into a new pose: {from, rot, t0, dur, hop}; empty when idle
var _cam_set := false
var _last := 0.0


static func now_ms() -> float:
	return Time.get_ticks_usec() / 1000.0


func _ready() -> void:
	note_input.note_on.connect(note_on)
	note_input.note_off.connect(note_off)
	note_input.source_changed.connect(hud.show_source)
	note_input.start_requested.connect(start)
	note_input.restart_requested.connect(_on_restart_key)
	hud.start_pressed.connect(start)
	hud.restart_pressed.connect(restart)
	hud.tempo_changed.connect(func(v: float) -> void: bpm = v)
	hud.labels_toggled.connect(func(on: bool) -> void: labels = on)
	hud.tick_toggled.connect(_on_tick_toggled)
	hud.synth_toggled.connect(_on_synth_toggled)
	if Array(OS.get_cmdline_user_args()).any(func(a: String) -> bool: return a in ["--autoplay", "--perf"] or a.begins_with("--shots=")):
		add_child(preload("res://scripts/dev_autoplay.gd").new())
	now = now_ms()
	_last = now
	_layout()
	restart()


func _process(_delta: float) -> void:
	now = now_ms()
	var dt := minf(0.05, (now - _last) / 1000.0)
	_last = now
	_layout()
	if started:
		_update(dt)
	render = _apply_blend(_pose())
	var cam_target := render.pos.x - view_size.x * 0.3
	cam_x = cam_x + (cam_target - cam_x) * (1.0 - exp(-dt * 3.5)) if _cam_set else cam_target
	_cam_set = true
	if banner != "" and now - banner_t > 2800.0:
		banner = ""
	flyers = flyers.filter(func(f: Dictionary) -> bool: return now - f.t0 < 700.0)
	view.queue_redraw()


func start() -> void:
	if started:
		return
	started = true
	hud.hide_overlay()
	restart()


func restart() -> void:
	notes = Song.parse()
	bars.clear()
	for n in notes:
		if n.beat > 0 and n.beat % 4 == 0:
			bars.append(n.xu - 0.45)
	bananas = START_BANANAS
	falls = 0
	done_up_to = 0
	banner = ""
	flyers.clear()
	synth.stop_all_notes()
	synth.cancel_ticks()
	state = State.WAIT
	cur = 0
	perch_stump = true
	_blend = {}
	_cam_set = false
	render = _pose()
	_update_hud()


func input_source() -> String:
	return note_input.source


# ---------------------------------------------------------------- layout

func _layout() -> void:
	view_size = get_viewport_rect().size
	hud_h = hud.bar_height()
	var avail := view_size.y - hud_h
	s = maxf(14.0, minf(40.0, avail / 18.2))
	sky_top = hud_h + maxf(0.0, avail - 18.2 * s) * 0.35
	c4_y = sky_top + 11.6 * s
	liana_y = c4_y + 4.1 * s
	floor_y = c4_y + 5.7 * s
	ppb = 3.0 * s


func y_of(step: float) -> float:
	return c4_y - step * s


func pt(n: Song.Note) -> Vector2:
	return Vector2(n.xu * ppb, y_of(n.step))


func beat_ms() -> float:
	return 60000.0 / bpm


func tol_ms() -> float:
	return TOL * beat_ms()


func windows(i: int, g: float) -> Dictionary:
	var n := notes[i]
	var end := g + n.beats * beat_ms()
	var next := end + n.rest_after * beat_ms()
	var tol := tol_ms()
	return {end = end, rel_lo = end - tol, rel_hi = end + tol, next = next, next_lo = next - tol, next_hi = next + tol}


func rest_times() -> Dictionary:
	var t2: float = windows(cur, grab_t).next
	return {t0 = rel_t, t1 = rel_t + (t2 - rel_t) * 0.45, t2 = t2}


func wait_spot(r: int) -> Vector2:
	return pt(notes[r]) + Vector2(-2.1 * s, 1.7 * s)


func stump_spot() -> Vector2:
	return pt(notes[0]) + Vector2(-2.6 * s, 1.4 * s)


func home_spot() -> Vector2:
	return pt(notes[-1]) + Vector2(2.9 * s, 1.9 * s)


# ---------------------------------------------------------------- rules

func note_on(m: int, ts: float) -> void:
	if not started:
		return
	synth.play_note(m)
	if state == State.WAIT:
		var n := notes[cur]
		if m == n.midi:
			_grab(cur, ts, false)
		else:
			_fall("Wrong note: %s. That branch is %s" % [Song.note_name(m), n.name], cur)
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
	if hanging:
		_complete(i)
	_grab(j, ts, state != State.REST and absi(nj.step - notes[i].step) > 2)   # more than a third apart: jump


func note_off(m: int, ts: float) -> void:
	synth.stop_note(m)
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
	boinged = false


func _grab(j: int, ts: float, jump: bool) -> void:
	_blend = {from = render.pos, rot = render.rot, t0 = now_ms(), dur = 260.0 if jump else 150.0, hop = 1.4 * s if jump else 0.0}
	state = State.HANG
	cur = j
	grab_t = ts
	creaked = false
	notes[j].broken_t = 0.0
	if tick_on:
		synth.schedule_ticks(ts, beat_ms(), notes[j].beats + notes[j].rest_after)
	else:
		synth.cancel_ticks()
	synth.sfx(&"grab")


func _complete(i: int) -> void:
	done_up_to = maxi(done_up_to, i + 1)
	var n := notes[i]
	if n.banana and not n.taken:
		n.taken = true
		bananas += 1
		synth.sfx(&"collect")
		flyers.append({t0 = now_ms(), pos = pt(n) + Vector2(0.65 * s - cam_x, 0.7 * s)})
	_update_hud()


func _break_branch(i: int) -> void:
	notes[i].broken_t = now_ms()
	synth.sfx(&"crack")
	_fall("Held too long. The branch broke", i)


## `resume` is the branch the magic banana brings you back to.
func _fall(reason: String, resume: int) -> void:
	falls += 1
	synth.cancel_ticks()
	synth.sfx(&"fall")
	state = State.FALL
	cur = resume
	fall_pos = render.pos
	fall_rot = render.rot
	fall_vel = Vector2(1.5 * s, -3.0 * s)
	fall_spin = 3.0 if randf() < 0.5 else -3.0
	land_t = 0.0
	_blend = {}
	banner = reason
	banner_t = now_ms()
	_update_hud()


func _win() -> void:
	synth.cancel_ticks()
	synth.sfx(&"win")
	_blend = {from = render.pos, rot = render.rot, t0 = now_ms(), dur = 450.0, hop = 1.5 * s}
	state = State.WON


func _update(dt: float) -> void:
	match state:
		State.HANG:
			var w := windows(cur, grab_t)
			if not creaked and now > w.end + tol_ms() * 0.3:
				creaked = true
				synth.sfx(&"creak")
			if now > w.rel_hi + GRACE:
				_break_branch(cur)
		State.AIR, State.REST:
			if state == State.REST and not boinged and now > rest_times().t1:
				boinged = true
				synth.sfx(&"boing")
			if now > windows(cur, grab_t).next_hi + GRACE:
				_fall("Too late. Missed the branch", cur + 1)
		State.FALL:
			if land_t == 0.0:
				fall_vel.y += 40.0 * s * dt
				fall_pos += fall_vel * dt
				fall_rot += fall_spin * dt
				if fall_pos.y >= floor_y - 1.7 * s:
					fall_pos.y = floor_y - 1.7 * s
					fall_rot = 0.0
					land_t = now
					synth.sfx(&"thud")
			elif now - land_t > 550.0:
				if bananas > 0:
					bananas -= 1
					_update_hud()
					state = State.BOUNCE
					bounce_t0 = now
					bounce_from = fall_pos
					synth.sfx(&"magic")
				else:
					state = State.OVER
		State.BOUNCE:
			if now - bounce_t0 > 1100.0:
				notes[cur].broken_t = 0.0
				state = State.WAIT
				perch_stump = false


func _update_hud() -> void:
	hud.show_stats(bananas, done_up_to, notes.size(), falls)


func _on_restart_key() -> void:
	if started:
		restart()


func _on_tick_toggled(on: bool) -> void:
	tick_on = on
	if not on:
		synth.cancel_ticks()


func _on_synth_toggled(on: bool) -> void:
	synth.synth_on = on
	if not on:
		synth.stop_all_notes()


# ---------------------------------------------------------------- pose

func _pose() -> Pose:
	var a := SWING
	match state:
		State.WAIT:
			if perch_stump:
				return Pose.new(stump_spot(), 0.0, &"perch")
			return Pose.new(wait_spot(cur) + Vector2(0.0, sin(now / 320.0) * 0.12 * s), 0.0, &"balloon")
		State.HANG, State.AIR:
			# one pendulum per note: from behind the grip to the front of the swing, arriving when the note's length is up
			var n := notes[cur]
			var next: Song.Note = notes[cur + 1] if cur + 1 < notes.size() else null
			var p := (now - grab_t) / (n.beats * beat_ms())
			var th := -a + a * (1.0 - cos(PI * clampf(p, 0.0, 1.0)))
			if state == State.HANG and p > 1.0:
				th = a + sin(now / 22.0) * 0.05 * clampf((p - 1.0) * 4.0, 0.0, 1.0)   # straining
			var pos := pt(n) + Vector2(sin(th), cos(th)) * RP * s
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
			var n := notes[cur]
			var j := notes[cur + 1]
			var rt := rest_times()
			var l := Vector2((n.rx0u + n.rx1u) / 2.0 * ppb, liana_y + LIANA_DIP * s - 1.7 * s)
			var e := pt(j) + Vector2(-sin(a), cos(a)) * RP * s
			if now < rt.t1:
				var drop := clampf((now - rt.t0) / (rt.t1 - rt.t0), 0.0, 1.0)
				var into := Vector2(lerpf(rel_pose.pos.x, l.x, drop), lerpf(rel_pose.pos.y, l.y, drop * drop))
				return Pose.new(into, lerpf(rel_pose.rot, 0.0, drop), &"up")
			var k := clampf((now - rt.t1) / (rt.t2 - rt.t1), 0.0, 1.0)
			var rising := Pose.new(Vector2(lerpf(l.x, e.x, k), lerpf(l.y, e.y, 1.0 - (1.0 - k) * (1.0 - k))), 0.0,
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
				return Pose.new(bounce_from + Vector2(0.0, sin(k / 0.3 * PI) * 0.25 * s), 0.0, &"sit")
			var w := wait_spot(cur)
			var e := clampf((k - 0.3) / 0.7, 0.0, 1.0)
			var ee := 1.0 - (1.0 - e) * (1.0 - e)
			var pos := Vector2(lerpf(bounce_from.x, w.x, ee), lerpf(bounce_from.y, w.y, ee) - sin(PI * e) * 2.5 * s)
			return Pose.new(pos, 0.0, &"balloon")
		_:   # WON
			var h := home_spot()
			return Pose.new(h - Vector2(0.0, absf(sin(now / 250.0)) * 0.3 * s), 0.0, &"up")


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
