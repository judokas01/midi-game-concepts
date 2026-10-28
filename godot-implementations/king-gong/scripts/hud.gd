extends CanvasLayer
## Everything drawn over the game: the top bar (settings and score), the start overlay, why
## you fell, the end panel, the legend, and bananas flying to the counter.

signal start_pressed
signal restart_pressed
signal tempo_changed(bpm: float)
signal labels_toggled(on: bool)
signal tick_toggled(on: bool)
signal style_chosen(clef: Song.Clef, chords: bool)
signal hint_chosen(hint: ChordLog.Hint)

const Song := preload("res://scripts/song.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const Staff := preload("res://scripts/staff.gd")
const GlowingBanana := preload("res://scenes/glowing_banana.tscn")
const SOURCE_COLOURS := {"keyboard": Color("3a3f49"), "MIDI": Color("2e8b57")}

var _banner_fade: Tween

@onready var _bar: Control = $Bar
@onready var _tempo: HSlider = $Bar/Row/Tempo/Slider
@onready var _tempo_value: Label = $Bar/Row/Tempo/Value
@onready var _source: Label = $Bar/Row/Source
@onready var _bananas: Control = $Bar/Row/Bananas
@onready var _banana_count: Label = $Bar/Row/Bananas/Count
@onready var _progress: Label = $Bar/Row/Progress
@onready var _falls: Label = $Bar/Row/Falls
@onready var _overlay: Control = $Overlay
@onready var _overlay_keys: RichTextLabel = $Overlay/Center/Box/Keys
@onready var _chord_rule: Control = $Overlay/Center/Box/ChordRule
@onready var _hint: Control = $Overlay/Center/Box/Hint
@onready var _banner: Label = $Banner
@onready var _legend: Label = $Legend
@onready var _keys: Label = $Keys
@onready var _end: Control = $EndPanel
@onready var _flyers: Node2D = $Flyers


func _ready() -> void:
	_tempo.value_changed.connect(_on_tempo)
	_toggle($Bar/Row/Labels/Toggle, labels_toggled)
	_toggle($Bar/Row/Tick/Toggle, tick_toggled)
	$Bar/Row/Restart.pressed.connect(func() -> void: restart_pressed.emit())
	$Overlay/Center/Box/Clef/Treble.pressed.connect(func() -> void: style_chosen.emit(Song.Clef.TREBLE, false))
	$Overlay/Center/Box/Clef/Bass.pressed.connect(func() -> void: style_chosen.emit(Song.Clef.BASS, false))
	$Overlay/Center/Box/Clef/Chords.pressed.connect(func() -> void: style_chosen.emit(Song.Clef.TREBLE, true))
	$Overlay/Center/Box/Hint/Name.pressed.connect(func() -> void: hint_chosen.emit(ChordLog.Hint.NAME))
	$Overlay/Center/Box/Hint/Bass.pressed.connect(func() -> void: hint_chosen.emit(ChordLog.Hint.BASS_CLEF))
	_overlay.gui_input.connect(_on_overlay_input)
	# own copy, so recolouring it does not touch the scene's shared style
	_source.add_theme_stylebox_override("normal", _source.get_theme_stylebox("normal").duplicate())


func show_stats(bananas: int, done: int, total: int, falls: int) -> void:
	_banana_count.text = str(bananas)
	_progress.text = "branch %d/%d" % [done, total]
	_falls.text = "falls %d" % falls


func show_source(source: String) -> void:
	_source.text = source
	(_source.get_theme_stylebox("normal") as StyleBoxFlat).bg_color = SOURCE_COLOURS[source]
	_keys.visible = source == "keyboard"


## What the computer keys play, on the start screen and under the floor. `chords` is what the
## chord keys play, "Z = C  V = F  B = G", or "" without chords.
func show_key_notes(names: String, chords: String) -> void:
	_keys.text = "keys  A S D F G H J K  =  " + names
	var overlay := "No MIDI? Keys [b]A S D F G H J K[/b] = %s." % names
	if chords != "":
		_keys.text += "   ·   chords  " + chords
		overlay += " Chords: [b]%s[/b]." % chords
	_overlay_keys.text = "[center]%s[/center]" % overlay


## The start screen explains the logs and offers the chord hints only with chords.
func show_chord_options(on: bool) -> void:
	_chord_rule.visible = on
	_hint.visible = on


func show_tempo(bpm: float) -> void:
	_legend.text = "short branch = 1 beat · twice as long = 2 beats · liana below = rest, let go and bounce · %d BPM, the beat restarts at every grab" % roundi(bpm)


func hide_overlay() -> void:
	_overlay.hide()


## Why you fell: shown for 2.8 s, fading over the last fifth.
func show_banner(text: String) -> void:
	if _banner_fade:
		_banner_fade.kill()
	_banner.text = text
	_banner.modulate.a = 1.0
	_banner.show()
	_banner_fade = create_tween()
	_banner_fade.tween_interval(2.24)
	_banner_fade.tween_property(_banner, "modulate:a", 0.0, 0.56)
	_banner_fade.tween_callback(_banner.hide)


func show_end(title: String, line: String) -> void:
	$EndPanel/Lines/Title.text = title
	$EndPanel/Lines/Line.text = line
	_end.show()


func clear_messages() -> void:
	if _banner_fade:
		_banner_fade.kill()
	_banner.hide()
	_end.hide()


## A collected banana arcs from `from` (screen position) to the counter.
func fly_banana(from: Vector2) -> void:
	var fruit: Node2D = GlowingBanana.instantiate()
	fruit.position = from
	fruit.rotation = -0.5
	fruit.scale = Vector2.ONE * 0.6
	_flyers.add_child(fruit)
	var to := Vector2(_bananas.get_global_rect().get_center().x, _bar.size.y + 0.4 * Staff.STEP)
	var flight := fruit.create_tween()
	flight.tween_method(func(k: float) -> void:
		fruit.position = from.lerp(to, smoothstep(0.0, 1.0, k)) - Vector2(0.0, sin(PI * k) * 2.0 * Staff.STEP),
		0.0, 1.0, 0.7)
	flight.tween_callback(fruit.queue_free)


func _toggle(button: Button, changed: Signal) -> void:
	button.toggled.connect(func(on: bool) -> void:
		button.text = "on" if on else "off"
		changed.emit(on))


func _on_tempo(value: float) -> void:
	_tempo_value.text = "%d BPM" % value
	show_tempo(value)
	tempo_changed.emit(value)


func _on_overlay_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		start_pressed.emit()
