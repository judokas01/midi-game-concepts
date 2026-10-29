extends CanvasLayer
## Everything drawn over the game: the top bar (settings and score), the start overlay, why
## you fell, the end panel, the legend, and bananas flying to the counter. The two menus, the
## start overlay and the end panel, can also be worked from the MIDI keyboard: each button
## has a note, written on it.

signal start_pressed
signal restart_pressed
signal tempo_changed(bpm: float)
signal labels_toggled(on: bool)
signal tick_toggled(on: bool)
signal song_chosen(song: int)
signal style_chosen(clef: Song.Clef, chords: bool)
signal hint_chosen(hint: ChordLog.Hint)
signal practice_toggled(on: bool)
signal menu_pressed

const Song := preload("res://scripts/song.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const Staff := preload("res://scripts/staff.gd")
const GlowingBanana := preload("res://scenes/glowing_banana.tscn")
const SOURCE_COLOURS := {"keyboard": Color("3a3f49"), "MIDI": Color("2e8b57")}
# the note that picks each button, by its path under the menu; on the start screen any other
# note starts the game
const START_KEYS := {"Song/Previous": 48, "Song/Next": 50, "Clef/Treble": 60, "Clef/Bass": 62, "Clef/Chords": 64,
	"Hint/Name": 65, "Hint/Bass": 67, "Practice": 69}
const END_KEYS := {"Again": 60, "Menu": 62}
const END_DEAF_MS := 800   # the end panel ignores notes this long, so a note still being played can't pick

var _banner_fade: Tween
var _end_listens_at := 0

@onready var _bar: Control = $Bar
@onready var _tempo: HSlider = $Bar/Row/Tempo/Slider
@onready var _tempo_value: Label = $Bar/Row/Tempo/Value
@onready var _source: Label = $Bar/Row/Source
@onready var _bananas: Control = $Bar/Row/Bananas
@onready var _banana_count: Label = $Bar/Row/Bananas/Count
@onready var _progress: Label = $Bar/Row/Progress
@onready var _falls: Label = $Bar/Row/Falls
@onready var _overlay: Control = $Overlay
@onready var _start_menu: Control = $Overlay/Center/Box
@onready var _song: OptionButton = $Overlay/Center/Box/Song/Pick
@onready var _end_menu: Control = $EndPanel/Lines/Buttons
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
	for song: Dictionary in Song.library():
		_song.add_item(song.name)
	_song.item_selected.connect(func(i: int) -> void: song_chosen.emit(i))
	$Overlay/Center/Box/Song/Previous.pressed.connect(_next_song.bind(-1))
	$Overlay/Center/Box/Song/Next.pressed.connect(_next_song.bind(1))
	_on_chosen($Overlay/Center/Box/Clef/Treble, func() -> void: style_chosen.emit(Song.Clef.TREBLE, false))
	_on_chosen($Overlay/Center/Box/Clef/Bass, func() -> void: style_chosen.emit(Song.Clef.BASS, false))
	_on_chosen($Overlay/Center/Box/Clef/Chords, func() -> void: style_chosen.emit(Song.Clef.TREBLE, true))
	_on_chosen($Overlay/Center/Box/Hint/Name, func() -> void: hint_chosen.emit(ChordLog.Hint.NAME))
	_on_chosen($Overlay/Center/Box/Hint/Bass, func() -> void: hint_chosen.emit(ChordLog.Hint.BASS_CLEF))
	$Overlay/Center/Box/Practice.toggled.connect(func(on: bool) -> void: practice_toggled.emit(on))
	$EndPanel/Lines/Buttons/Again.pressed.connect(func() -> void: restart_pressed.emit())
	$EndPanel/Lines/Buttons/Menu.pressed.connect(func() -> void: menu_pressed.emit())
	for menu: Array in [[_start_menu, START_KEYS], [_end_menu, END_KEYS]]:
		for path: String in menu[1]:
			var button: Button = menu[0].get_node(path)
			button.text += " · " + Song.note_name(menu[1][path])
	_overlay.gui_input.connect(_on_overlay_input)
	# own copy, so recolouring it does not touch the scene's shared style
	_source.add_theme_stylebox_override("normal", _source.get_theme_stylebox("normal").duplicate())


## `bananas` < 0: they never run out, in practice mode.
func show_stats(bananas: int, done: int, total: int, falls: int) -> void:
	_banana_count.text = str(bananas) if bananas >= 0 else "∞"
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


func show_overlay() -> void:
	_overlay.show()


## The start screen or the end panel is up.
func menu_up() -> bool:
	return _overlay.visible or _end.visible


## Picks the button on MIDI note `m` in the menu that is up, as a click would. True if `m` is
## one of that menu's notes, even when its button is hidden.
func choose(m: int) -> bool:
	var menu := _start_menu
	var keys := START_KEYS
	if not _overlay.visible:
		if not _end.visible or Time.get_ticks_msec() < _end_listens_at:
			return false
		menu = _end_menu
		keys = END_KEYS
	var path: Variant = keys.find_key(m)
	if path == null:
		return false
	var button: Button = menu.get_node(path)
	if not button.is_visible_in_tree():
		return true
	if not button.toggle_mode:
		button.pressed.emit()
	elif button.button_group:
		button.button_pressed = true
	else:
		button.button_pressed = not button.button_pressed
	return true


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
	clear_messages()
	$EndPanel/Lines/Title.text = title
	$EndPanel/Lines/Line.text = line
	_end.show()
	_end_listens_at = Time.get_ticks_msec() + END_DEAF_MS


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


## The song `by` places down the list (up if negative), round from the end to the start.
func _next_song(by: int) -> void:
	_song.select(posmod(_song.selected + by, _song.item_count))
	song_chosen.emit(_song.selected)


## `picked` runs when `button`, one of a group, becomes the chosen one: clicked or played.
func _on_chosen(button: Button, picked: Callable) -> void:
	button.toggled.connect(func(on: bool) -> void:
		if on:
			picked.call())


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
