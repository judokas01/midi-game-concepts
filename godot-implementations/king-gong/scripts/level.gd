extends Node2D
## Lays the song out as a level: a branch per note, a liana per rest, a log per chord change,
## the start stump and the nest; plus, in the layers behind, the ledger bushes below the staff
## and the bar-line trunks.

const Song := preload("res://scripts/song.gd")
const Staff := preload("res://scripts/staff.gd")
const NoteInput := preload("res://scripts/note_input.gd")
const Branch := preload("res://scripts/branch.gd")
const Liana := preload("res://scripts/liana.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const BranchScene := preload("res://scenes/branch.tscn")
const LianaScene := preload("res://scenes/liana.tscn")
const ChordLogScene := preload("res://scenes/chord_log.tscn")
const GlowingBanana := preload("res://scenes/glowing_banana.tscn")
const LEDGER_BUSH := preload("res://art/ledger_bush.svg")
const TRUNK_COLOUR := Color(0.376, 0.298, 0.204, 0.28)

@export var ledger: Node2D   ## lives behind the clef, so outside this node
@export var trunks: Node2D   ## bar lines: faint distant tree trunks

var _lianas_by_note := {}    # note index -> liana
var _logs_by_note := {}      # note index -> the chord log before its branch

@onready var _stump: Sprite2D = $Stump
@onready var _nest: Sprite2D = $Nest
@onready var _lianas: Node2D = $Lianas
@onready var _branches: Node2D = $Branches
@onready var _logs: Node2D = $Logs
@onready var _pops: Node2D = $Pops


## `bars`: where the bar lines go, in beats.
func build(notes: Array[Song.Note], bars: Array) -> void:
	for holder: Node in [_lianas, _branches, _logs, _pops, ledger, trunks]:
		for child in holder.get_children():
			holder.remove_child(child)
			child.queue_free()
	_lianas_by_note.clear()
	_logs_by_note.clear()
	_stump.position = Staff.stump_spot(notes[0]) + Vector2(0.0, 1.7 * Staff.STEP)
	_nest.position = Staff.home_spot(notes[-1]) + Vector2(0.0, 1.7 * Staff.STEP)
	for i in notes.size():
		var note := notes[i]
		var new_branch: Branch = BranchScene.instantiate()
		_branches.add_child(new_branch)
		new_branch.setup(note)
		if note.rest_after > 0:
			var new_liana: Liana = LianaScene.instantiate()
			_lianas.add_child(new_liana)
			var rest := note.beat + note.beats
			new_liana.setup(Staff.x_of(rest) - 0.2 * Staff.STEP, Staff.x_of(rest + note.rest_after) + 0.2 * Staff.STEP)
			_lianas_by_note[i] = new_liana
		if note.chord:
			var new_log: ChordLog = ChordLogScene.instantiate()
			_logs.add_child(new_log)
			new_log.setup(note)
			_logs_by_note[i] = new_log
		for step in range(0, note.step - 1, -2):   # a ledger line under the staff for each line down to the note
			var bush := Sprite2D.new()
			bush.texture = LEDGER_BUSH
			bush.position = Vector2(Staff.note_pos(note).x, Staff.y_of(step))
			ledger.add_child(bush)
	for bar in bars:
		var trunk := ColorRect.new()
		trunk.color = TRUNK_COLOUR
		trunk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		trunk.position = Vector2(Staff.x_of(bar) - 0.16 * Staff.STEP, Staff.SKY_TOP)
		trunk.size = Vector2(0.32 * Staff.STEP, Staff.FLOOR_Y - Staff.SKY_TOP)
		trunks.add_child(trunk)


func branch(i: int) -> Branch:
	return _branches.get_child(i)


func liana(i: int) -> Liana:
	return _lianas_by_note.get(i)


func chord_log(i: int) -> ChordLog:
	return _logs_by_note.get(i)


## Note names on the branches and the `hint` on each log, with the computer key when playing
## on the keyboard (on the branches only with `tune_keys`, when you play the tune). Without
## labels the logs keep their hint.
func show_labels(notes: Array[Song.Note], on: bool, hint: ChordLog.Hint, keys: NoteInput, tune_keys := true) -> void:
	for i in notes.size():
		var key := keys.key_for(notes[i].midi) if tune_keys else ""
		var text := notes[i].name + (" · " + key if key != "" else "")
		branch(i).set_label(text if on else "")
		if notes[i].chord:
			chord_log(i).show_hint(hint, keys.chord_key_for(notes[i].chord) if on else "")


## The magic banana popping up under a fallen gorilla.
func pop_banana(at: Vector2) -> void:
	var pop: Node2D = GlowingBanana.instantiate()
	pop.position = at
	pop.scale = Vector2.ONE * 0.2
	_pops.add_child(pop)
	var grow := pop.create_tween()
	grow.tween_property(pop, "scale", Vector2.ONE * 1.2, 0.33)
	grow.tween_callback(pop.queue_free)
