extends CanvasLayer
## Everything drawn over the game: the top bar (settings and score), the start overlay, why
## you fell, the end panel, the legend or the little keyboard, and bananas flying to the
## counter. The two menus, the start overlay and the end panel, can also be worked from the
## MIDI keyboard: each button has a note, written on it.

signal start_pressed
signal restart_pressed
signal tempo_changed(bpm: float)
signal labels_toggled(on: bool)
signal tick_toggled(on: bool)
signal mode_chosen(mode: Mode)
signal song_chosen(song: int)
signal style_chosen(clef: Song.Clef, chords: bool, by_itself: bool)
signal hint_chosen(hint: ChordLog.Hint)
signal kinds_chosen(kinds: Array)
signal practice_toggled(on: bool)
signal piano_toggled(on: bool)
signal menu_pressed

## What the start screen offers: play a song, learn one, or drill chords.
enum Mode { PLAY, LEARN, DRILL }

const Song := preload("res://scripts/song.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const Staff := preload("res://scripts/staff.gd")
const Piano := preload("res://scripts/piano.gd")
const GlowingBanana := preload("res://scenes/glowing_banana.tscn")
const SOURCE_COLOURS := {"keyboard": Color("3a3f49"), "MIDI": Color("2e8b57")}
const TUNE_COLOUR := Color("f2c230")   # the next note on the little keyboard; a chord's is its log's
# The note that picks each button, by its path under the menu; on the start screen any other
# note starts the game. Buttons never shown together can share a note.
const START_KEYS := {"Song/Previous": 48, "Song/Next": 50, "Mode/Play": 52, "Mode/Learn": 53, "Mode/Drill": 55,
	"Clef/Treble": 60, "Clef/Bass": 62, "Clef/Chords": 64, "Clef/ChordsOnly": 65,
	"Kinds/Major": 60, "Kinds/Minor": 62, "Kinds/Sevenths": 64, "Kinds/DimAug": 65,
	"Hint/Name": 67, "Hint/Bass": 69, "Practice": 71, "PianoHint": 71}
const LEARN_BODY := """[center][b]Learn a song before you play it.[/b] The five long bushes are the staff lines and every branch sits on a note. The gorilla waits on its branch until you play the next one's note, as long as it takes: nothing is timed and you can't fall.

The little keyboard at the bottom lights the key to play. Turn it off to practise reading the notes alone.[/center]"""
const DRILL_BODY := """[center][b]Learn the chords.[/b] The gorilla climbs a made-up tune by itself and stops at every log. Play the chord on the log's sign to knock it down: its notes in any octave and any order.

The little keyboard at the bottom lights the chord's keys. Pick which chords to practise; every round brings 16 new ones.[/center]"""
const CHORD_RULES := {
	Mode.PLAY: "[center]A coloured log stands wherever the chord changes. [b]Play its chord in the left hand[/b], below middle C, together with the branch's note, and the gorilla kicks the log down. Leave it standing and you bounce off.[/center]",
	Mode.LEARN: "[center]A coloured log stands wherever the chord changes. [b]Play its chord in the left hand[/b], below middle C, and the branch's note in the right: the gorilla waits for both.[/center]",
}
const CHORDS_ONLY_RULES := {
	Mode.PLAY: "[center]The gorilla plays the tune by itself. A coloured log stands wherever the chord changes: [b]play its chord[/b], anywhere on the keyboard, as the gorilla reaches it, and it kicks the log down. Too early or too late and it bounces off.[/center]",
	Mode.LEARN: "[center]The gorilla plays the tune by itself and [b]waits at every log until you play its chord[/b], anywhere on the keyboard.[/center]",
}
const END_KEYS := {"Again": 60, "Menu": 62}
const END_DEAF_MS := 800   # the end panel ignores notes this long, so a note still being played can't pick

var _banner_fade: Tween
var _end_listens_at := 0
var _play_body := ""   # the start screen's text for playing, as in the scene
var _chord_from := 48  # the C the chord's keys start on

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
@onready var _body: RichTextLabel = $Overlay/Center/Box/Body
@onready var _chord_rule: RichTextLabel = $Overlay/Center/Box/ChordRule
@onready var _hint: Control = $Overlay/Center/Box/Hint
@onready var _kinds: Control = $Overlay/Center/Box/Kinds
@onready var _banner: Label = $Banner
@onready var _legend: Label = $Legend
@onready var _keys: Label = $Keys
@onready var _piano: Control = $Piano
@onready var _chord_keys: Piano = $Piano/Panel/Row/Chord/Keys
@onready var _tune_keys: Piano = $Piano/Panel/Row/Tune/Keys
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
	_on_chosen($Overlay/Center/Box/Mode/Play, func() -> void: mode_chosen.emit(Mode.PLAY))
	_on_chosen($Overlay/Center/Box/Mode/Learn, func() -> void: mode_chosen.emit(Mode.LEARN))
	_on_chosen($Overlay/Center/Box/Mode/Drill, func() -> void: mode_chosen.emit(Mode.DRILL))
	_on_chosen($Overlay/Center/Box/Clef/Treble, func() -> void: style_chosen.emit(Song.Clef.TREBLE, false, false))
	_on_chosen($Overlay/Center/Box/Clef/Bass, func() -> void: style_chosen.emit(Song.Clef.BASS, false, false))
	_on_chosen($Overlay/Center/Box/Clef/Chords, func() -> void: style_chosen.emit(Song.Clef.TREBLE, true, false))
	_on_chosen($Overlay/Center/Box/Clef/ChordsOnly, func() -> void: style_chosen.emit(Song.Clef.TREBLE, true, true))
	_on_chosen($Overlay/Center/Box/Hint/Name, func() -> void: hint_chosen.emit(ChordLog.Hint.NAME))
	_on_chosen($Overlay/Center/Box/Hint/Bass, func() -> void: hint_chosen.emit(ChordLog.Hint.BASS_CLEF))
	var kind_buttons: Array[Button] = [$Overlay/Center/Box/Kinds/Major, $Overlay/Center/Box/Kinds/Minor,
		$Overlay/Center/Box/Kinds/Sevenths, $Overlay/Center/Box/Kinds/DimAug]   # in Drill.Kind order
	for button in kind_buttons:
		button.toggled.connect(func(_on: bool) -> void:
			var kinds := range(kind_buttons.size()).filter(func(k: int) -> bool: return kind_buttons[k].button_pressed)
			if kinds.is_empty():
				button.set_pressed_no_signal(true)   # one kind at least
				return
			kinds_chosen.emit(kinds))
	$Overlay/Center/Box/Practice.toggled.connect(func(on: bool) -> void: practice_toggled.emit(on))
	$Overlay/Center/Box/PianoHint.toggled.connect(func(on: bool) -> void: piano_toggled.emit(on))
	_play_body = _body.text
	_chord_keys.fold = true
	$EndPanel/Lines/Buttons/Again.pressed.connect(func() -> void: restart_pressed.emit())
	$EndPanel/Lines/Buttons/Menu.pressed.connect(func() -> void: menu_pressed.emit())
	for menu: Array in [[_start_menu, START_KEYS], [_end_menu, END_KEYS]]:
		for path: String in menu[1]:
			var button: Button = menu[0].get_node(path)
			button.text += " · " + Song.note_name(menu[1][path])
	_overlay.gui_input.connect(_on_overlay_input)
	# own copy, so recolouring it does not touch the scene's shared style
	_source.add_theme_stylebox_override("normal", _source.get_theme_stylebox("normal").duplicate())


## `bananas` < 0: they never run out, in practice mode. `progress`, "branch 3/42", and
## `misses`, "falls 2", as they are shown.
func show_stats(bananas: int, progress: String, misses: String) -> void:
	_banana_count.text = str(bananas) if bananas >= 0 else "∞"
	_progress.text = progress
	_falls.text = misses


func show_source(source: String) -> void:
	_source.text = source
	(_source.get_theme_stylebox("normal") as StyleBoxFlat).bg_color = SOURCE_COLOURS[source]
	_show_floor()


## What the computer keys play, on the start screen and under the floor. `chords` is what the
## chord keys play, "Z = C  V = F  B = G", or "" without chords.
func show_key_notes(names: String, chords: String) -> void:
	_keys.text = "keys  A S D F G H J K  =  " + names
	var overlay := "No MIDI? Keys [b]A S D F G H J K[/b] = %s." % names
	if chords != "":
		_keys.text += "   ·   chords  " + chords
		overlay += " Chords: [b]%s[/b]." % chords
	_overlay_keys.text = "[center]%s[/center]" % overlay


## The start screen for `mode`: songs and how to play them, or the chord drill's kinds of
## chord. It explains the logs and offers the chord hints only with `chords`; `by_itself`, the
## gorilla plays the tune.
func show_options(mode: Mode, chords: bool, by_itself: bool) -> void:
	var drill := mode == Mode.DRILL
	_body.text = {Mode.PLAY: _play_body, Mode.LEARN: LEARN_BODY, Mode.DRILL: DRILL_BODY}[mode]
	$Overlay/Center/Box/Song.visible = not drill
	$Overlay/Center/Box/Clef.visible = not drill
	_chord_rule.visible = chords and not drill
	if _chord_rule.visible:
		_chord_rule.text = (CHORDS_ONLY_RULES if by_itself else CHORD_RULES)[mode]
	_hint.visible = chords and not drill
	_kinds.visible = drill
	$Overlay/Center/Box/Practice.visible = mode == Mode.PLAY
	$Overlay/Center/Box/PianoHint.visible = mode != Mode.PLAY


## The little keyboard: the chord's two octaves from the C `chord_from`, and the tune's keys
## from `tune_lo` to `tune_hi` with the computer `letters` on them (midi -> key). -1 leaves a
## part out; without either the legend shows instead.
func set_piano(chord_from: int, tune_lo: int, tune_hi: int, letters := {}) -> void:
	var chord_part: Control = _chord_keys.get_parent()
	var tune_part: Control = _tune_keys.get_parent()
	chord_part.visible = chord_from >= 0
	tune_part.visible = tune_lo >= 0
	_piano.visible = chord_part.visible or tune_part.visible
	if chord_part.visible:
		_chord_from = chord_from
		_chord_keys.set_range(chord_from, chord_from + 23)
	if tune_part.visible:
		_tune_keys.set_range(tune_lo, tune_hi)
		_tune_keys.letters = letters
	$Piano/Panel/Row/Chord/Caption.text = "chord · left hand" if tune_part.visible else "chord"
	$Piano/Panel/Row/Tune/Caption.text = "note · right hand" if chord_part.visible else "next note"
	_show_floor()


## Lights what to play next on the little keyboard: `chord`, in root position, and the tune's
## `note`, either null. `left` and `right` are the notes held down in each hand, `wrong_left`
## and `wrong_right` those of them that are wrong.
func light_piano(chord: Song.Chord, note: Song.Note, left: Array, right: Array, wrong_left: Array, wrong_right: Array) -> void:
	if not _piano.visible:
		return
	var lit := {}
	if chord:
		# as the bass-clef hint writes it, moved by octaves onto the keys
		var shift := 0
		while chord.midi[0] + shift < _chord_from:
			shift += 12
		while chord.midi[-1] + shift > _chord_from + 23:
			shift -= 12
		for k in chord.midi.size():
			lit[chord.midi[k] + shift] = [ChordLog.colour_of(chord), chord.tones[k]]
	_chord_keys.show_keys(lit, left, wrong_left)
	_tune_keys.show_keys({note.midi: [TUNE_COLOUR, note.name]} if note else {}, right, wrong_right)


## Under the floor: the little keyboard, or the legend and, on the computer keyboard, its keys.
func _show_floor() -> void:
	_legend.visible = not _piano.visible
	_keys.visible = _source.text == "keyboard" and not _piano.visible


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
	var path: Variant = null
	for shown: String in keys:
		if keys[shown] == m:
			path = shown
			if menu.get_node(shown).is_visible_in_tree():
				break
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
