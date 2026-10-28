extends RefCounted
## Where the gorilla is and what its arms are doing this frame. game.gd works it out from the
## rules, gorilla.gd shows it.
##
## Kinds: perch, balloon, hang, reach, up, fall, sit.

const Song := preload("res://scripts/song.gd")

var pos: Vector2
var rot: float
var kind: StringName
var grip: Song.Note        # hang: the branch held
var hand := 0              # hang: 0 grips with the left hand, 1 with the right
var target: Song.Note      # hang, reach: the branch reached for, if any
var reach_k := 0.0         # hang: how far the free hand has reached for it, 0..1


func _init(p: Vector2, r: float, k: StringName) -> void:
	pos = p
	rot = r
	kind = k
