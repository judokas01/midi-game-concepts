extends CanvasLayer
## Everything drawn over the game: the counters (the progress line along the top, and the pill
## with bananas and falls), the main menu and the chord drill's chord grid, the pause menu, why
## you fell, the end panel, the little keyboard, and bananas flying to the counter. Of the
## menus only the chord grid listens to the MIDI keyboard.

signal start_pressed
signal restart_pressed
signal tempo_changed(bpm: float)
signal labels_toggled(on: bool)
signal tick_toggled(on: bool)
signal mode_chosen(mode: Mode)
signal song_chosen(song: int)
signal style_chosen(clef: Song.Clef, chords: bool, by_itself: bool)
signal hint_chosen(hint: ChordLog.Hint)
signal drill_chosen(chords: Array, count: int, beats: int)
signal practice_toggled(on: bool)
signal piano_toggled(on: bool)
signal menu_pressed
signal continue_pressed

## What the main menu's boards play: a song, learning one, or the chord drill.
enum Mode { PLAY, LEARN, DRILL }

const Song := preload("res://scripts/song.gd")
const ChordLog := preload("res://scripts/chord_log.gd")
const Staff := preload("res://scripts/staff.gd")
const Piano := preload("res://scripts/piano.gd")
const ChordMenu := preload("res://scripts/chord_menu.gd")
const MainMenu := preload("res://scripts/main_menu.gd")
const PauseMenu := preload("res://scripts/pause_menu.gd")
const ProgressLine := preload("res://scripts/progress_line.gd")
const GlowingBanana := preload("res://scenes/glowing_banana.tscn")
const TUNE_COLOUR := Color("f2c230")   # the next note on the little keyboard; a chord's is its log's
const MODES := {MainMenu.Page.PLAY: Mode.PLAY, MainMenu.Page.LEARN: Mode.LEARN, MainMenu.Page.DRILL: Mode.DRILL}

var _banner_fade: Tween
var _chord_from := 48         # the C the chord's keys start on
var _piano_wanted := false    # the little keyboard has something to show, once no menu covers it

@onready var _progress: ProgressLine = $Progress
@onready var _pill: Control = $Pill
@onready var _banana_icon: Control = $Pill/Row/Bananas/Icon
@onready var _banana_count: Label = $Pill/Row/Bananas/Count
@onready var _falls: Label = $Pill/Row/Falls
@onready var _menu: MainMenu = $MainMenu
@onready var _chord_menu: ChordMenu = $ChordMenu
@onready var _pause: PauseMenu = $PauseMenu
@onready var _banner: Label = $Banner
@onready var _piano: Control = $Piano
@onready var _chord_keys: Piano = $Piano/Panel/Row/Chord/Keys
@onready var _tune_keys: Piano = $Piano/Panel/Row/Tune/Keys
@onready var _end: Control = $EndPanel
@onready var _flyers: Node2D = $Flyers


func _ready() -> void:
	_menu.page_opened.connect(func(page: MainMenu.Page) -> void: mode_chosen.emit(MODES[page]))
	_menu.start_pressed.connect(func() -> void: start_pressed.emit())
	_menu.song_chosen.connect(func(i: int) -> void: song_chosen.emit(i))
	_menu.style_chosen.connect(func(clef: Song.Clef, chords: bool, by_itself: bool) -> void: style_chosen.emit(clef, chords, by_itself))
	_menu.hint_chosen.connect(func(hint: ChordLog.Hint) -> void: hint_chosen.emit(hint))
	_menu.practice_toggled.connect(func(on: bool) -> void: practice_toggled.emit(on))
	_menu.piano_toggled.connect(func(on: bool) -> void: piano_toggled.emit(on))
	_menu.drill_changed.connect(func(_count: int, _beats: int) -> void: _choose_drill())
	_menu.chords_requested.connect(open_chords)
	_menu.kind_toggled.connect(func(quality: String, on: bool) -> void:
		_chord_menu.set_kind(quality, on)
		_show_picked()
		_choose_drill())
	_chord_menu.closed.connect(func(_chords: Array) -> void:
		_menu.show()
		_show_picked()
		_choose_drill())
	_show_picked()
	_pause.continue_pressed.connect(func() -> void: continue_pressed.emit())
	_pause.restart_pressed.connect(func() -> void: restart_pressed.emit())
	_pause.menu_pressed.connect(func() -> void: menu_pressed.emit())
	_pause.tempo_changed.connect(func(bpm: float) -> void: tempo_changed.emit(bpm))
	_pause.tick_toggled.connect(func(on: bool) -> void: tick_toggled.emit(on))
	_pause.labels_toggled.connect(func(on: bool) -> void: labels_toggled.emit(on))
	_pause.practice_toggled.connect(func(on: bool) -> void:
		_menu.set_practice(on)   # the Play song board's says the same
		practice_toggled.emit(on))
	_chord_keys.fold = true
	$EndPanel/Lines/Buttons/Again.pressed.connect(func() -> void: restart_pressed.emit())
	$EndPanel/Lines/Buttons/Menu.pressed.connect(func() -> void: menu_pressed.emit())
	_progress.keep_clear = _pill
	_menu.visibility_changed.connect(_show_layers)
	_chord_menu.visibility_changed.connect(_show_layers)
	_show_layers()


## `bananas` < 0: they never run out, in practice mode. `missed`, "falls 2", as it is shown.
func show_stats(bananas: int, missed: String) -> void:
	_banana_count.text = str(bananas) if bananas >= 0 else "∞"
	_falls.text = missed
	_progress.queue_redraw()   # the pill may have changed width, and the percentage keeps clear of it


## The progress line: `share` of the level done, 0 to 1.
func show_progress(share: float) -> void:
	_progress.show_progress(share)


## The Chord sign choice on the song boards is for a part with `chords` only.
func show_style(chords: bool) -> void:
	_menu.show_style(chords)


## The little keyboard: the chord's two octaves from the C `chord_from`, and the tune's keys
## from `tune_lo` to `tune_hi` with the computer `letters` on them (midi -> key). -1 leaves a
## part out; without either it is hidden.
func set_piano(chord_from: int, tune_lo: int, tune_hi: int, letters := {}) -> void:
	var chord_part: Control = _chord_keys.get_parent()
	var tune_part: Control = _tune_keys.get_parent()
	chord_part.visible = chord_from >= 0
	tune_part.visible = tune_lo >= 0
	_piano_wanted = chord_part.visible or tune_part.visible
	_show_layers()
	if chord_part.visible:
		_chord_from = chord_from
		_chord_keys.set_range(chord_from, chord_from + 23)
	if tune_part.visible:
		_tune_keys.set_range(tune_lo, tune_hi)
		_tune_keys.letters = letters
	$Piano/Panel/Row/Chord/Caption.text = "chord · left hand" if tune_part.visible else "chord"
	$Piano/Panel/Row/Tune/Caption.text = "note · right hand" if chord_part.visible else "next note"


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


func hide_main_menu() -> void:
	_menu.hide()


## The main menu, on the page it was left on.
func show_main_menu() -> void:
	_menu.show()


## A board of the main menu is up: Space starts from it.
func on_board() -> bool:
	return _menu.on_board()


## Esc on the main menu: from a board back to the main page.
func menu_back() -> void:
	if _menu.visible:
		_menu.back()


## The main menu, the chord grid, the end panel or the pause menu is up.
func menu_up() -> bool:
	return _menu.visible or _chord_menu.visible or _end.visible or _pause.visible


## The pause menu, showing the game's settings as they are.
func open_pause(play_mode: bool, practice: bool, bpm: float, tick: bool, labels: bool) -> void:
	_pause.open(play_mode, practice, bpm, tick, labels)


func close_pause() -> void:
	_pause.close()


## The chord grid (More options on the drill board), in place of the main menu until it is closed.
func open_chords() -> void:
	_menu.hide()
	_chord_menu.open()


func chords_open() -> bool:
	return _chord_menu.visible


func close_chords() -> void:
	_chord_menu.close()


## The chord grid's button on MIDI note `m`, picked as a click would. False when the chord grid
## isn't up: no other menu listens to notes.
func choose(m: int) -> bool:
	if not _chord_menu.visible:
		return false
	_chord_menu.play(m)
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
	var to := _banana_icon.get_global_rect().get_center()
	var flight := fruit.create_tween()
	flight.tween_method(func(k: float) -> void:
		fruit.position = from.lerp(to, smoothstep(0.0, 1.0, k)) - Vector2(0.0, sin(PI * k) * 2.0 * Staff.STEP),
		0.0, 1.0, 0.7)
	flight.tween_callback(fruit.queue_free)


## The chord grid's picks on the drill board: named, and the kinds lit.
func _show_picked() -> void:
	_menu.show_picked(_chord_menu.picked(), _chord_menu.kinds())


## The drill as the chord grid and the drill board have it.
func _choose_drill() -> void:
	drill_chosen.emit(_chord_menu.picked(), _menu.count, _menu.beats)


## The counters and the little keyboard hide while the main menu or the chord grid is up.
func _show_layers() -> void:
	var covered := _menu.visible or _chord_menu.visible
	_progress.visible = not covered
	_pill.visible = not covered
	_piano.visible = _piano_wanted and not covered
