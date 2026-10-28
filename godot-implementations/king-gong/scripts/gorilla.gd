extends Node2D
## The gorilla: a body sprite (a scared one while falling) and two arms drawn as lines from
## the shoulders to wherever the pose puts the hands.

const Pose := preload("res://scripts/pose.gd")
const Staff := preload("res://scripts/staff.gd")
const SHOULDER := Vector2(0.45, 0.05) * Staff.STEP   # right shoulder; the left one is mirrored
const ARM_LENGTH := 2.4 * Staff.STEP

@onready var _arm_left: Line2D = $ArmLeft
@onready var _hand_left: Sprite2D = $HandLeft
@onready var _arm_right: Line2D = $ArmRight
@onready var _hand_right: Sprite2D = $HandRight
@onready var _body: Sprite2D = $Body
@onready var _scared: Sprite2D = $Scared
@onready var _balloon: Node2D = $Balloon
@onready var _prompt: Label = $Prompt


func show_pose(pose: Pose, now: float) -> void:
	position = pose.pos
	rotation = pose.rot
	var hands := _hands(pose, now)
	_reach(_arm_left, _hand_left, Vector2(-SHOULDER.x, SHOULDER.y), hands[0])
	_reach(_arm_right, _hand_right, SHOULDER, hands[1])
	_scared.visible = pose.kind == &"fall"
	_body.visible = not _scared.visible
	_balloon.visible = pose.kind == &"balloon"


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


func _reach(arm: Line2D, hand: Sprite2D, shoulder: Vector2, target: Vector2) -> void:
	var at := shoulder + (target - shoulder).limit_length(ARM_LENGTH)
	arm.points = PackedVector2Array([shoulder, at])
	hand.position = at
