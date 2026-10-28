extends Node2D
## Draws the jungle staff, the branches and the gorilla, ported from the spike's canvas code.
## Reads game state, never changes it.
##
## The spike redraws everything every frame. Here anything that does not move is built once
## into meshes (backdrop.gd for the scrolling scenery; trees, branches, bananas and lianas
## below), and what does move is collected into one triangle list per stretch between text
## draws (shapes.gd). Same picture, a few dozen draw calls instead of several hundred.

const Game := preload("res://scripts/game.gd")
const Song := preload("res://scripts/song.gd")
const NoteInput := preload("res://scripts/note_input.gd")
const Backdrop := preload("res://scripts/backdrop.gd")
const Shapes := preload("res://scripts/shapes.gd")

const THICK := {1: 0.26, 2: 0.6, 3: 0.8, 4: 1.0}   # branch thickness in staff steps, by beats
const FUR := Color("2a292e")
const HAND := Color("3b3a41")
const SKIN := Color("8b7d74")
const MUZZLE := Color("a6968b")
const BARK := Color("5a3b20")
const BARK_LIGHT := Color("8a6239")
const STEM := Color("5a3d1a")
const BANANA := Color("ffd83a")
const CANOPY := Color("3e6a45")
const TEXT := Color("fff8e0")
const TEXT_OUTLINE := Color(0.0627, 0.0941, 0.0627, 0.85)

@onready var game: Game = get_parent()

var font := SystemFont.new()
var bold := SystemFont.new()
var clef_font := SystemFont.new()
var draw_us := 0              # time spent in _draw, for the --perf dev check

var s := 0.0                  # game.s, cached per frame
var _live := Shapes.new()     # this frame's moving shapes, submitted before each text draw
var _sh: Shapes = _live       # where the shape helpers below add to: _live, or a mesh being built
var _stack: Array[Transform2D] = []
var _body := Transform2D.IDENTITY   # gorilla body: position and rotation
var _world := Transform2D.IDENTITY  # world to screen: the camera scroll

var _layout := []             # what the baked meshes were built for
var _canopy: Backdrop
var _staff: Array[Backdrop] = []
var _ledger: Array[Backdrop] = []
var _mounds: Backdrop
var _trees: ArrayMesh
var _branches: Array[ArrayMesh] = []
var _bananas := {}            # note index -> ArrayMesh
var _lianas := {}             # note index -> ArrayMesh


func _ready() -> void:
	font.font_names = PackedStringArray(["Segoe UI", "Arial", "sans-serif"])
	bold.font_names = font.font_names
	bold.font_weight = 700
	clef_font.font_names = PackedStringArray(["Segoe UI Symbol", "Noto Music", "serif"])


func _draw() -> void:
	var t0 := Time.get_ticks_usec()
	if not game.notes.is_empty():
		_draw_frame()
	draw_us = Time.get_ticks_usec() - t0


func _draw_frame() -> void:
	var g := game
	s = g.s
	var now := g.now
	var w := g.view_size.x
	var h := g.view_size.y
	var cam := g.cam_x
	_world = Transform2D(0.0, Vector2(-cam, 0.0))
	var layout := [s, w, g.sky_top, g.floor_y, g.notes.size()]
	if layout != _layout:
		_layout = layout
		_build_backdrop()
		_build_world()

	# sky, the spaces of the staff
	var sky_mid := lerpf(g.sky_top, g.floor_y, 0.6)
	var sky := [Color("d7e8d2"), Color("b9d6b4"), Color("88ad86")]
	draw_rect(Rect2(0, 0, w, g.sky_top), sky[0])
	_gradient(g.sky_top, sky_mid, w, sky[0], sky[1])
	_gradient(sky_mid, g.floor_y, w, sky[1], sky[2])

	# canopy fringe overhead, far away
	draw_rect(Rect2(0, 0, w, g.sky_top - 0.6 * s), CANOPY)
	_canopy.draw(self, cam * 0.35, w)

	# bar lines: distant trunks
	for bu in g.bars:
		var x := bu * g.ppb - cam
		if x > -s and x < w + s:
			draw_rect(Rect2(x - 0.16 * s, g.sky_top, 0.32 * s, g.floor_y - g.sky_top), Color(0.376, 0.298, 0.204, 0.28))

	# staff lines: long bushes, E4 G4 B4 D5 F5; C4 ledger line: a short bush around each C4 branch
	for layer in _staff:
		layer.draw(self, cam * 0.55, w)
	for layer in _ledger:
		layer.draw(self, cam, w)

	# vine clef; its curl wraps the G line (offsets measured for Segoe UI Symbol)
	draw_string(clef_font, Vector2(0.2 * s, g.y_of(0.75)), "\U01D11E", HORIZONTAL_ALIGNMENT_LEFT, -1,
		roundi(13 * s), Color(0.149, 0.306, 0.173, 0.7))

	# jungle floor
	draw_rect(Rect2(0, g.floor_y, w, h - g.floor_y), Color("2c2a1c"))
	_mounds.draw(self, cam, w)

	# world
	_live.xf = _world
	_mesh(_trees)
	for i in g.notes.size():
		if g.notes[i].rest_after > 0 and _in_view(g.notes[i]):
			_draw_liana(g.notes[i], i, now)
	for i in g.notes.size():
		if _in_view(g.notes[i]):
			_draw_branch(g.notes[i], i, now)
	if g.state == Game.State.BOUNCE and now - g.bounce_t0 < 330.0:
		_banana(Vector2(g.bounce_from.x, g.floor_y - 0.25 * s), lerpf(0.1, 0.6, (now - g.bounce_t0) / 330.0) * s, 0.0, true)
	_gorilla(g.render, now)
	_flush()
	_live.xf = Transform2D.IDENTITY

	# prompt above the gorilla while it waits
	if g.state == Game.State.WAIT and g.started:
		var n := g.notes[g.cur]
		var key := _key_hint(n.midi)
		var txt := "Play the next branch to grab it"
		if g.labels:
			txt = "Play %s%s to grab" % [n.name, " (key %s)" % key if key != "" else ""]
		var at := g.render.pos + Vector2(-cam, -(1.4 if g.perch_stump else 3.0) * s)
		_outlined(txt, at, maxi(14, roundi(0.55 * s)), TEXT)

	# why you fell
	if g.banner != "":
		var k := (now - g.banner_t) / 2800.0
		var fade := 1.0 if k < 0.8 else maxf(0.0, (1.0 - k) / 0.2)
		_outlined(g.banner, Vector2(w / 2, g.y_of(9)), maxi(16, roundi(0.7 * s)), Color("ffd2c4"), fade)

	# collected bananas fly to the counter
	var target: Vector2 = g.hud.banana_anchor()
	for f in g.flyers:
		var k: float = (now - f.t0) / 700.0
		var e := smoothstep(0.0, 1.0, k)
		var p := Vector2(lerpf(f.pos.x, target.x, e), lerpf(f.pos.y, g.hud_h + 0.4 * s, e) - sin(PI * k) * 2.0 * s)
		_banana(p, 0.3 * s, -0.5, true)
	_flush()

	# legend on the forest floor
	if h - g.floor_y > 1.4 * s:
		var size := maxi(12, roundi(0.42 * s))
		_text("thin branch = 1 beat · thick branch = 2 beats · liana below = rest, let go and bounce · %d BPM, the beat restarts at every grab" % roundi(g.bpm),
			Vector2(w / 2, g.floor_y + 1.1 * s), size, Color("b8c4ad"), font)
		if g.input_source() == "keyboard":
			_text("keys  A S D F G H J K  =  C4 D4 E4 F4 G4 A4 B4 C5", Vector2(w / 2, g.floor_y + 1.8 * s), size, Color("8f9c86"), font)

	if g.state == Game.State.WON:
		_panel("Home in the nest!", "%d fall%s · %d banana%s left · Enter or Restart to play again"
			% [g.falls, "" if g.falls == 1 else "s", g.bananas, "" if g.bananas == 1 else "s"])
	elif g.state == Game.State.OVER:
		_panel("Out of magic bananas", "Made it to branch %d of %d · Enter or Restart to try again" % [g.done_up_to, g.notes.size()])


# ---------------------------------------------------------------- baked parts

## The scenery that only scrolls: canopy, staff and ledger bushes, floor mounds. Each layer
## covers every scroll position the camera can reach, in its own parallax space.
func _build_backdrop() -> void:
	var g := game
	var w := g.view_size.x
	var cam_lo := g.stump_spot().x - 0.3 * w - 20.0 * s
	var cam_hi := g.home_spot().x - 0.3 * w + 20.0 * s
	_canopy = Backdrop.new()
	var step := 1.1 * s
	for k in range(floori(0.35 * cam_lo / step) - 2, floori((0.35 * cam_hi + w) / step) + 3):
		_canopy.add_disc(Vector2(k * step, g.sky_top - 1.0 * s + _hash(k + 50) * 0.4 * s), (0.6 + 0.6 * _hash(k)) * s, CANOPY)
	_staff = [Backdrop.new(), Backdrop.new()]
	for idx in 5:
		_bush(_staff, 0.55 * cam_lo, 0.55 * cam_hi + w, g.y_of(2 + 2 * idx), idx * 37)
	_ledger = [Backdrop.new(), Backdrop.new()]
	for n in g.notes:
		if n.step == 0:
			_bush(_ledger, n.xu * g.ppb - 1.3 * s, n.xu * g.ppb + 1.3 * s, g.y_of(0), 91)
	_mounds = Backdrop.new()
	step = 0.6 * s
	for k in range(floori(cam_lo / step) - 2, floori((cam_hi + w) / step) + 3):
		_mounds.add_disc(Vector2(k * step, g.floor_y + 0.1 * s), (0.3 + 0.3 * _hash(k + 7)) * s, Color("3b5a2c"), PI, TAU)
	for layer: Backdrop in [_canopy, _staff[0], _staff[1], _ledger[0], _ledger[1], _mounds]:
		layer.build()


## A staff line as a band of bushes, from x0 to x1 in its layer: dark blobs into layer[0],
## the lighter ones on top into layer[1].
func _bush(layer: Array[Backdrop], x0: float, x1: float, y: float, salt: int) -> void:
	var step := 0.34 * s
	for k in range(floori(x0 / step) - 1, ceili(x1 / step) + 2):
		var r := (0.22 + 0.13 * _hash(k + salt)) * s
		layer[0].add_disc(Vector2(k * step, y + (_hash(k * 2.3 + salt) - 0.5) * 0.08 * s), r, Color("2f5a36"))
		if _hash(k * 5.1 + salt) >= 0.45:
			r = (0.1 + 0.06 * _hash(k + salt + 9)) * s
			layer[1].add_disc(Vector2(k * step + 0.05 * s, y - 0.12 * s), r, Color("4f8752"))


## Trees, and each branch, banana and liana at rest, in world coordinates.
func _build_world() -> void:
	var g := game
	_sh = Shapes.new()
	var stump := g.stump_spot()
	_tree(stump.x, stump.y + 1.7 * s, 1.4 * s, false)
	var home := g.home_spot()
	_tree(home.x, home.y + 1.7 * s, 1.6 * s, true)
	_trees = _sh.to_mesh()
	_branches.clear()
	_bananas.clear()
	_lianas.clear()
	for i in g.notes.size():
		var n := g.notes[i]
		_sh = Shapes.new()
		_branch_shapes(g.pt(n), THICK[n.beats] * s, 0.0)
		_branches.append(_sh.to_mesh())
		if n.banana:
			_sh = Shapes.new()
			_hanging_banana(g.pt(n), THICK[n.beats] * s)
			_bananas[i] = _sh.to_mesh()
		if n.rest_after > 0:
			_sh = Shapes.new()
			_liana_shapes(n, 0.45 * s)
			_lianas[i] = _sh.to_mesh()
	_sh = _live


# ---------------------------------------------------------------- scenery

func _tree(x: float, feet_y: float, w: float, nest: bool) -> void:
	_sh.rect(Rect2(x - w / 2.0, feet_y, w, game.floor_y - feet_y), Color("5d4329"))
	_sh.ellipse(Vector2(x, feet_y), w / 2.0, 0.22 * s, Color("7a5a38"))
	if not nest:
		return
	_sh.ellipse(Vector2(x, feet_y + 0.1 * s), 1.5 * s, 0.45 * s, Color("8a6a3a"), 0.0, 0.0, PI)
	for k in range(-3, 4):
		_line(Vector2(x + k * 0.4 * s, feet_y - 0.05 * s), Vector2(x + k * 0.45 * s + 0.3 * s, feet_y + 0.35 * s), Color("5a4022"))


func _liana_shapes(n: Song.Note, sag: float) -> void:
	var g := game
	var x0 := n.rx0u * g.ppb - 0.2 * s
	var x1 := n.rx1u * g.ppb + 0.2 * s
	var y0 := g.liana_y - 0.3 * s
	var post := Color("5a4630")
	_sh.rect(Rect2(x0 - 0.15 * s, y0 - 0.2 * s, 0.3 * s, g.floor_y - y0 + 0.2 * s), post)
	_sh.rect(Rect2(x1 - 0.15 * s, y0 - 0.2 * s, 0.3 * s, g.floor_y - y0 + 0.2 * s), post)
	var a := Vector2(x0, y0)
	var c := Vector2((x0 + x1) / 2.0, y0 + 2.0 * sag)
	var b := Vector2(x1, y0)
	_sh.stroke(_quad(a, c, b), Color("3f7a34"), 0.2 * s)
	var t := 0.1
	while t < 0.95:
		_sh.ellipse(a.lerp(c, t).lerp(c.lerp(b, t), t) + Vector2(0.0, 0.12 * s), 0.22 * s, 0.1 * s, Color("5c9a45"), t * 6.0)
		t += 0.16


func _draw_liana(n: Song.Note, i: int, now: float) -> void:
	var g := game
	if g.state != Game.State.REST or g.cur != i:
		_mesh(_lianas[i])
		return
	var rt := g.rest_times()
	var d: float = now - rt.t1
	var span: float = rt.t2 - rt.t0
	var k := clampf(1.0 + d / (0.06 * span), 0.0, 1.0) if d < 0.0 else clampf(1.0 - d / (0.3 * span), 0.0, 1.0)
	_liana_shapes(n, 0.45 * s + (Game.LIANA_DIP + 0.3 - 0.45) * s * k)


func _limb(a: Vector2, b: Vector2, th: float, sag: float) -> void:
	var mid := (a + b) / 2.0 + Vector2(0.0, 2.0 * sag)
	_sh.stroke(_quad(a, mid, b), BARK, th)
	var lift := Vector2(0.0, -th * 0.22)
	_sh.stroke(_quad(a + lift, mid + lift, b + lift), BARK_LIGHT, maxf(1.5, th * 0.3))


func _leaves(at: Vector2, r: float) -> void:
	_sh.ellipse(at + Vector2(0.5, -0.4) * r, 0.7 * r, 0.32 * r, Color("3c7232"), -0.5)
	_sh.ellipse(at + Vector2(0.7, 0.2) * r, 0.7 * r, 0.3 * r, Color("4b8a3e"), 0.4)
	_sh.ellipse(at + Vector2(0.2, 0.5) * r, 0.55 * r, 0.26 * r, Color("3c7232"), 1.1)


func _branch_shapes(p: Vector2, th: float, sag: float) -> void:
	var half := 1.1 * s
	_sh.stroke(PackedVector2Array([p + Vector2(-half * 0.7, 0.0), p + Vector2(-half * 1.15, -0.5 * s)]), BARK, maxf(1.5, th * 0.35))   # twig
	_limb(p + Vector2(-half, 0.0), p + Vector2(half, 0.0), th, sag)
	_leaves(p + Vector2(half, 0.0), 0.5 * s)
	_leaves(p + Vector2(-half * 1.15, -0.5 * s), 0.32 * s)


func _hanging_banana(p: Vector2, th: float) -> void:
	var bx := p.x + 0.9 * s   # toward the tip, clear of the gorilla's head
	_line(Vector2(bx, p.y), Vector2(bx, p.y + th / 2.0 + 0.3 * s), STEM)
	_banana(Vector2(bx, p.y + th / 2.0 + 0.8 * s), 0.5 * s, -1.2, false)


func _draw_branch(n: Song.Note, i: int, now: float) -> void:
	var g := game
	var p := g.pt(n)
	var th: float = THICK[n.beats] * s
	var half := 1.1 * s
	var alpha := 0.5 if i < g.done_up_to else 1.0
	if n.broken_t > 0.0:
		var k := (now - n.broken_t) / 1000.0
		if k < 1.6:
			_live.alpha = alpha * clampf(1.6 - k, 0.0, 1.0)
			_push(Transform2D(minf(1.2, k * 3.0), p + Vector2(-half, 0.0)))
			_limb(Vector2.ZERO, Vector2(half, 0.0), th, 0.0)
			_pop()
			_push(Transform2D(-k * 2.0, p + Vector2(half * 0.5, 20.0 * s * k * k)))
			_limb(Vector2(-half * 0.5, 0.0), Vector2(half * 0.5, 0.0), th, 0.0)
			_leaves(Vector2(half * 0.5, 0.0), 0.5 * s)
			_pop()
			_live.alpha = 1.0
		return
	if g.state == Game.State.HANG and g.cur == i:
		var end := g.grab_t + n.beats * g.beat_ms()
		var sag := 0.08 * s
		var crack := 0.0
		if now > end:
			crack = clampf((now - end) / g.tol_ms(), 0.0, 1.0)
			sag += crack * 0.35 * s
		_live.alpha = alpha
		_branch_shapes(p, th, sag)
		for c in ceili(crack * 3.0):
			var cp := p + Vector2((c - 1) * 0.3 * s, sag)
			_sh.stroke(PackedVector2Array([cp + Vector2(0.0, -th / 2.0), cp + Vector2(0.08 * s, -th * 0.1),
				cp + Vector2(-0.05 * s, th * 0.15), cp + Vector2(0.06 * s, th / 2.0)]), Color("1e120a"), 1.5, false)
		_live.alpha = 1.0
	else:
		_mesh(_branches[i], alpha)
	if n.banana and not n.taken:
		_mesh(_bananas[i], alpha)
	if g.labels:
		var key := _key_hint(n.midi)
		_text(n.name + (" · " + key if key != "" else ""), Vector2(p.x - g.cam_x, p.y - th / 2.0 - 0.12 * s),
			roundi(0.55 * s), TEXT, bold, 2, TEXT_OUTLINE, true, alpha)


# ---------------------------------------------------------------- gorilla and bananas

func _gorilla(b: Game.Pose, now: float) -> void:
	var g := game
	_body = Transform2D(b.rot, b.pos)
	var sh_l := _at(-0.45, 0.05)
	var sh_r := _at(0.45, 0.05)
	var hl: Vector2
	var hr: Vector2
	match b.kind:
		&"hang":
			var grip := g.pt(b.grip)
			var loose := _at(-0.75, 1.0) if b.hand == 1 else _at(0.75, 1.0)
			if b.target != null:
				loose = loose.lerp(g.pt(b.target), b.reach_k)
			hl = loose if b.hand == 1 else grip
			hr = grip if b.hand == 1 else loose
		&"reach":
			var t := g.pt(b.target)
			hl = t - Vector2(0.15 * s, 0.0)
			hr = t + Vector2(0.15 * s, 0.0)
		&"up":
			hl = _at(-0.4, -1.55)
			hr = _at(0.4, -1.55)
		&"balloon":
			hl = _at(-0.18, -1.5)
			hr = _at(0.18, -1.5)
		&"fall":
			hl = _at(-1.05, -0.5 + 0.35 * sin(now / 55.0))
			hr = _at(1.05, -0.5 + 0.35 * cos(now / 55.0))
		_:   # perch, sit
			hl = _at(-0.7, 0.95)
			hr = _at(0.7, 0.95)
	hl = sh_l + (hl - sh_l).limit_length(2.4 * s)
	hr = sh_r + (hr - sh_r).limit_length(2.4 * s)
	for arm in [[sh_l, hl], [sh_r, hr]]:
		_sh.stroke(PackedVector2Array(arm), FUR, 0.32 * s)
		_sh.circle(arm[1], 0.18 * s, HAND)

	_ell(-0.3, 1.38, 0.21, 0.32, FUR)   # legs
	_ell(0.3, 1.38, 0.21, 0.32, FUR)
	_ell(0.0, 0.62, 0.62, 0.8, FUR)     # body, chest
	_ell(0.0, 0.72, 0.36, 0.5, Color("57525c"))
	_ell(0.0, -0.2, 0.46, 0.44, FUR)    # head
	_ell(0.0, -0.1, 0.32, 0.25, SKIN)   # face, muzzle
	_ell(0.0, 0.03, 0.21, 0.14, MUZZLE)
	_ell(0.0, -0.3, 0.36, 0.09, Color("1c1b1f"))   # brow
	var look := 0.0 if b.kind == &"fall" else 0.02
	for side in [-1.0, 1.0]:
		_ell(side * 0.13, -0.2, 0.06, 0.055, Color.WHITE)
		_ell(side * 0.13 + look, -0.2, 0.032, 0.035, Color("111111"))
		_ell(side * 0.05, 0.0, 0.025, 0.02, Color("3a302c"))
	if b.kind == &"fall":
		_ell(0.0, 0.12, 0.07, 0.06, Color("3a1f1f"))
	else:
		var smile := PackedVector2Array()
		for k in 9:
			var a := lerpf(0.3, PI - 0.3, k / 8.0)
			smile.append(_at(0.09 * cos(a), 0.04 + 0.09 * sin(a)))
		_sh.stroke(smile, Color("3a302c"), maxf(1.0, 0.03 * s), false)
	var crown := PackedVector2Array()   # the king's crown
	for c in [[-0.22, -0.56], [-0.24, -0.82], [-0.11, -0.68], [0.0, -0.86], [0.11, -0.68], [0.24, -0.82], [0.22, -0.56]]:
		crown.append(_at(c[0], c[1]))
	_sh.poly(crown, Color("f2c230"))
	if b.kind == &"balloon":
		var p := _at(0.0, -2.0)
		_banana(p, 0.6 * s, 0.0, true)
		_sparkles(p, now)


## Point on the gorilla's body, in staff steps from its centre.
func _at(lx: float, ly: float) -> Vector2:
	return _body * (Vector2(lx, ly) * s)


func _ell(lx: float, ly: float, rx: float, ry: float, colour: Color) -> void:
	_sh.ellipse(_at(lx, ly), rx * s, ry * s, colour, _body.get_rotation())


## The banana as a crescent polygon. Shared with the HUD's counter icon.
static func banana_polygon(center: Vector2, size: float, rot: float) -> PackedVector2Array:
	var a := Vector2(-1.0, -0.25)
	var b := Vector2(1.0, -0.25)
	var outer := Vector2(0.0, 1.05)
	var inner := Vector2(0.0, 0.45)
	var pts := PackedVector2Array()
	for k in 13:
		var t := k / 12.0
		pts.append(a.lerp(outer, t).lerp(outer.lerp(b, t), t))
	for k in range(11, 0, -1):
		var t := k / 12.0
		pts.append(a.lerp(inner, t).lerp(inner.lerp(b, t), t))
	for k in pts.size():
		pts[k] = center + (pts[k] * size).rotated(rot)
	return pts


func _banana(center: Vector2, size: float, rot: float, glow: bool) -> void:
	if glow:   # stands in for the canvas shadowBlur
		var c := center + Vector2(0.0, 0.3 * size).rotated(rot)
		_sh.circle(c, 1.5 * size, Color(1.0, 0.953, 0.627, 0.12))
		_sh.circle(c, 1.1 * size, Color(1.0, 0.953, 0.627, 0.18))
	_sh.poly(banana_polygon(center, size, rot), BANANA)
	_sh.circle(center + (Vector2(-1.0, -0.25) * size).rotated(rot), 0.1 * size, STEM)
	_sh.circle(center + (Vector2(1.0, -0.25) * size).rotated(rot), 0.1 * size, STEM)


func _sparkles(at: Vector2, now: float) -> void:
	for i in 5:
		var a := now / 600.0 + i * 1.256
		var r := (0.75 + 0.15 * sin(now / 200.0 + i)) * s
		var c := Color("fffbd0")
		c.a = 0.5 + 0.5 * sin(now / 150.0 + i * 2.0)
		_sh.circle(at + Vector2(cos(a) * r, sin(a) * r * 0.6), 0.07 * s, c)


# ---------------------------------------------------------------- text and panels

func _key_hint(midi: int) -> String:
	return NoteInput.key_for(midi) if game.input_source() == "keyboard" else ""


func _outlined(txt: String, at: Vector2, size: int, colour: Color, fade := 1.0) -> void:
	_text(txt, at, size, colour, bold, 3, TEXT_OUTLINE, false, fade)


func _panel(title: String, line: String) -> void:
	var g := game
	var w := minf(560.0, g.view_size.x - 40.0)
	var h := 116.0
	var x := (g.view_size.x - w) / 2.0
	var y := g.y_of(8) - h / 2.0
	draw_rect(Rect2(x, y, w, h), Color(0.0627, 0.0863, 0.0627, 0.88))
	_text(title, Vector2(g.view_size.x / 2.0, y + 40.0), 26, Color.WHITE, bold)
	_text(line, Vector2(g.view_size.x / 2.0, y + 80.0), 15, Color("cfd8cc"), font)


## Centred text in screen coordinates. `at.y` is the middle of the line, or its bottom
## when `bottom` is set.
func _text(txt: String, at: Vector2, size: int, colour: Color, f: Font, outline := 0,
		outline_colour := TEXT_OUTLINE, bottom := false, fade := 1.0) -> void:
	_flush()
	var width := f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var baseline := at.y - f.get_descent(size) if bottom else at.y + (f.get_ascent(size) - f.get_descent(size)) / 2.0
	var pos := Vector2(at.x - width / 2.0, baseline)
	if outline > 0:
		draw_string_outline(f, pos, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, outline, Color(outline_colour, outline_colour.a * fade))
	draw_string(f, pos, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(colour, colour.a * fade))


# ---------------------------------------------------------------- helpers

func _in_view(n: Song.Note) -> bool:
	var x := n.xu * game.ppb - game.cam_x
	return x > -5.0 * s and x < game.view_size.x + 6.0 * s


## Draws a baked world mesh, after whatever moving shapes came before it.
func _mesh(mesh: ArrayMesh, alpha := 1.0) -> void:
	_flush()
	draw_mesh(mesh, null, _world, Color(1.0, 1.0, 1.0, alpha))


func _flush() -> void:
	_live.submit(self)


func _push(xf: Transform2D) -> void:
	_stack.push_back(_sh.xf)
	_sh.xf = _sh.xf * xf


func _pop() -> void:
	_sh.xf = _stack.pop_back()


func _line(a: Vector2, b: Vector2, colour: Color) -> void:
	_sh.stroke(PackedVector2Array([a, b]), colour, 1.5, false)


func _gradient(y0: float, y1: float, w: float, top: Color, bottom: Color) -> void:
	draw_polygon(PackedVector2Array([Vector2(0, y0), Vector2(w, y0), Vector2(w, y1), Vector2(0, y1)]),
		PackedColorArray([top, top, bottom, bottom]))


static func _quad(a: Vector2, c: Vector2, b: Vector2, segments := 16) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in segments + 1:
		var t := float(k) / segments
		pts.append(a.lerp(c, t).lerp(c.lerp(b, t), t))
	return pts


static func _hash(k: float) -> float:
	var x := sin(k * 127.1 + 311.7) * 43758.5453
	return x - floorf(x)
