extends CanvasLayer
## The top bar (settings and score) and the start overlay.

signal start_pressed
signal restart_pressed
signal tempo_changed(bpm: float)
signal labels_toggled(on: bool)
signal tick_toggled(on: bool)
signal synth_toggled(on: bool)

const View := preload("res://scripts/view.gd")
const SOURCE_COLOURS := {"keyboard": Color("3a3f49"), "MIDI": Color("2e8b57")}

@onready var _bar: Control = $Bar
@onready var _tempo: HSlider = $Bar/Row/Tempo/Slider
@onready var _tempo_value: Label = $Bar/Row/Tempo/Value
@onready var _source: Label = $Bar/Row/Source
@onready var _bananas: Control = $Bar/Row/Bananas
@onready var _banana_icon: Control = $Bar/Row/Bananas/Icon
@onready var _banana_count: Label = $Bar/Row/Bananas/Count
@onready var _progress: Label = $Bar/Row/Progress
@onready var _falls: Label = $Bar/Row/Falls
@onready var _overlay: Control = $Overlay


func _ready() -> void:
	_tempo.value_changed.connect(_on_tempo)
	_toggle($Bar/Row/Labels/Toggle, labels_toggled)
	_toggle($Bar/Row/Tick/Toggle, tick_toggled)
	_toggle($Bar/Row/Synth/Toggle, synth_toggled)
	$Bar/Row/Restart.pressed.connect(func() -> void: restart_pressed.emit())
	_overlay.gui_input.connect(_on_overlay_input)
	_banana_icon.draw.connect(_draw_banana_icon)
	# own copy, so recolouring it does not touch the scene's shared style
	_source.add_theme_stylebox_override("normal", _source.get_theme_stylebox("normal").duplicate())


func bar_height() -> float:
	return _bar.size.y


func banana_anchor() -> Vector2:
	return _bananas.get_global_rect().get_center()


func show_stats(bananas: int, done: int, total: int, falls: int) -> void:
	_banana_count.text = str(bananas)
	_progress.text = "branch %d/%d" % [done, total]
	_falls.text = "falls %d" % falls


func show_source(source: String) -> void:
	_source.text = source
	(_source.get_theme_stylebox("normal") as StyleBoxFlat).bg_color = SOURCE_COLOURS[source]


func hide_overlay() -> void:
	_overlay.hide()


func _toggle(button: Button, changed: Signal) -> void:
	button.toggled.connect(func(on: bool) -> void:
		button.text = "on" if on else "off"
		changed.emit(on))


func _on_tempo(value: float) -> void:
	_tempo_value.text = "%d BPM" % value
	tempo_changed.emit(value)


func _on_overlay_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		start_pressed.emit()


func _draw_banana_icon() -> void:
	var pts := View.banana_polygon(_banana_icon.size / 2.0 + Vector2(0.0, -2.0), 7.0, 0.0)
	_banana_icon.draw_colored_polygon(pts, View.BANANA)
	pts.append(pts[0])
	_banana_icon.draw_polyline(pts, View.BANANA, 1.0, true)
