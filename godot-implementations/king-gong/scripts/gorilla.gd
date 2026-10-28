extends Node2D
## The gorilla: a body sprite (a scared one while falling) and two arms drawn as lines from
## the shoulders to wherever the pose puts the hands. A leg comes out only to kick a log.

const Pose := preload("res://scripts/pose.gd")
const Staff := preload("res://scripts/staff.gd")
const SHOULDER := Vector2(0.45, 0.05) * Staff.STEP   # right shoulder; the left one is mirrored
const ARM_LENGTH := 2.4 * Staff.STEP
const HIP := Vector2(0.3, 1.1) * Staff.STEP   # right hip, where the kicking leg starts
const LEG_LENGTH := 1.6 * Staff.STEP
const KICK_MS := 320.0                         # out and back
const KICK_LEAN := 0.35                        # radians the body leans back while kicking

var _kick_t := -INF
var _kick_at := Vector2.ZERO   # world position the foot kicks towards

@onready var _arm_left: Line2D = $ArmLeft
@onready var _hand_left: Sprite2D = $HandLeft
@onready var _arm_right: Line2D = $ArmRight
@onready var _hand_right: Sprite2D = $HandRight
@onready var _leg: Line2D = $Leg
@onready var _foot: Sprite2D = $Foot
@onready var _body: Sprite2D = $Body
@onready var _scared: Sprite2D = $Scared
@onready var _balloon: Node2D = $Balloon
@onready var _prompt: Label = $Prompt


func show_pose(pose: Pose, now: float) -> void:
	position = pose.pos
	rotation = pose.rot - KICK_LEAN * _kick_out(now)
	var hands := _hands(pose, now)
	_reach(_arm_left, _hand_left, Vector2(-SHOULDER.x, SHOULDER.y), hands[0])
	_reach(_arm_right, _hand_right, SHOULDER, hands[1])
	_scared.visible = pose.kind == &"fall"
	_body.visible = not _scared.visible
	_balloon.visible = pose.kind == &"balloon"
	_show_leg(now)


## A quick kick at `at`, a world position, starting `now`.
func kick(at: Vector2, now: float) -> void:
	_kick_t = now
	_kick_at = at


## Text floating `above` pixels over the gorilla; empty hides it.
func show_prompt(text: String, above: float) -> void:
	_prompt.text = text
	_prompt.visible = text != ""
	_prompt.position = Vector2(-_prompt.size.x / 2.0, -above - _prompt.size.y / 2.0)


## Left and right hand positions, in the gorilla's own (rotated) space.
func _hands(pose: Pose, now: float) -> Array:
	var s := Staff.STEP
	match pose.kind:
		&"hang":
			var grip := to_local(Staff.note_pos(pose.grip))
			var loose := Vector2(-0.75 if pose.hand == 1 else 0.75, 1.0) * s
			if pose.target != null:
				loose = loose.lerp(to_local(Staff.note_pos(pose.target)), pose.reach_k)
			return [loose, grip] if pose.hand == 1 else [grip, loose]
		&"reach":
			var branch := Staff.note_pos(pose.target)
			return [to_local(branch - Vector2(0.15 * s, 0.0)), to_local(branch + Vector2(0.15 * s, 0.0))]
		&"up":
			return [Vector2(-0.4, -1.55) * s, Vector2(0.4, -1.55) * s]
		&"balloon":
			return [Vector2(-0.18, -1.5) * s, Vector2(0.18, -1.5) * s]
		&"fall":   # flailing
			return [Vector2(-1.05, -0.5 + 0.35 * sin(now / 55.0)) * s, Vector2(1.05, -0.5 + 0.35 * cos(now / 55.0)) * s]
		_:   # perch, sit
			return [Vector2(-0.7, 0.95) * s, Vector2(0.7, 0.95) * s]


## How far the kick is out, 0..1 and back; 0 when not kicking.
func _kick_out(now: float) -> float:
	var k := (now - _kick_t) / KICK_MS
	return sin(PI * k) if k >= 0.0 and k < 1.0 else 0.0


## The leg shoots out at full length towards the kick spot, however close the log is.
func _show_leg(now: float) -> void:
	var out := _kick_out(now)
	_leg.visible = out > 0.0
	_foot.visible = _leg.visible
	if not _leg.visible:
		return
	var foot := HIP + (to_local(_kick_at) - HIP).normalized() * LEG_LENGTH * out
	_leg.points = PackedVector2Array([HIP, foot])
	_foot.position = foot


func _reach(arm: Line2D, hand: Sprite2D, shoulder: Vector2, target: Vector2) -> void:
	var at := shoulder + (target - shoulder).limit_length(ARM_LENGTH)
	arm.points = PackedVector2Array([shoulder, at])
	hand.position = at
