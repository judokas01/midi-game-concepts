extends SceneTree
## Dev check, not part of the game: the songs' categories and difficulties, the order and
## filters the library uses, and the library page, tried headless.
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://scripts/dev_library_check.gd
## Prints "library: ok", or an error for each rule broken.

const Song := preload("res://scripts/song.gd")
const MainMenu := preload("res://scripts/main_menu.gd")
const MenuCursor := preload("res://scripts/menu_cursor.gd")
const Act := MenuCursor.Act
const BOX := "Center/Board/Box/"

var _failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# the built-in songs alone: the counts and places below are theirs, whatever the song book
	# (dev_songbook_check.gd checks it) or songs/ holds
	Song._library = Song.SONGS.duplicate()
	Song._sorted = []
	Song._matching = {}
	_check_songs()
	await _check_page()
	print("library: ok" if not _failed else "library: failed")
	quit()


## Every song has a category and a difficulty; the library sorts and filters by them.
func _check_songs() -> void:
	var want := {
		"Twinkle Twinkle": ["Children's songs", 2], "Mary's Lamb": ["Children's songs", 1],
		"Ducklings": ["Children's songs", 1], "Lightly Row": ["Children's songs", 2],
		"Ode to Joy": ["Classical", 2], "Jingle Bells": ["Christmas", 2],
		"Mary's Lamb in D": ["Children's songs", 2], "Ode to Joy in F": ["Classical", 2],
		"Mountain King in C minor": ["Classical", 3], "Für Elise in F minor": ["Classical", 4],
	}
	for song: Dictionary in Song.SONGS:
		_expect(Song.song_errors(song, false).is_empty(), "%s is valid: %s" % [song.name, Song.song_errors(song, false)])
		_expect(want.has(song.name) and [song.get("category"), song.get("difficulty")] == want[song.name],
			"%s is %s, not %s" % [song.name, want.get(song.name), [song.get("category"), song.get("difficulty")]])
	_expect(Song.CATEGORIES.size() == 11 and Song.CATEGORIES[0] == "Children's songs" and Song.CATEGORIES[-1] == Song.YOUR_SCORES,
		"eleven categories, Children's songs first, Your scores last")
	var bad := [
		[{name = "x", difficulty = 2}, false, "no category"],
		[{name = "x", category = "Pop", difficulty = 2}, false, "an unknown category"],
		[{name = "x", category = Song.YOUR_SCORES, difficulty = 2}, false, "Your scores on a built-in song"],
		[{name = "x", category = "Classical"}, false, "no difficulty"],
		[{name = "x", category = "Classical", difficulty = 0}, false, "difficulty 0"],
		[{name = "x", category = "Classical", difficulty = 6}, false, "difficulty 6"],
		[{name = "x", category = "Classical", difficulty = 2.5}, false, "difficulty 2.5"],
	]
	for b: Array in bad:
		_expect(not Song.song_errors(b[0], b[1]).is_empty(), "%s is an error" % b[2])
	_expect(Song.song_errors({name = "x", category = Song.YOUR_SCORES}, true).is_empty(), "an imported score needs no difficulty")
	_expect(Song.sorted() == [2, 1, 5, 3, 6, 4, 7, 0, 8, 9], "all songs, by difficulty then name: %s" % [Song.sorted()])
	_expect(is_same(Song.sorted(), Song.sorted()), "sorted once, not on every call (the Song row asks each frame)")
	_expect(Song.categories_used() == ["Children's songs", "Christmas", "Classical"], "the categories with songs, in order: %s" % [Song.categories_used()])
	_expect(Song.levels_used() == [1, 2, 3, 4], "the difficulties with songs: %s" % [Song.levels_used()])
	_expect(Song.matching("", 0) == Song.sorted(), "no filter: every song")
	_expect(Song.matching("Children's songs", 0) == [2, 1, 3, 6, 0], "a category: %s" % [Song.matching("Children's songs", 0)])
	_expect(Song.matching("", 2) == [5, 3, 6, 4, 7, 0], "a difficulty, exactly: %s" % [Song.matching("", 2)])
	_expect(Song.matching("Classical", 2) == [4, 7], "both: %s" % [Song.matching("Classical", 2)])
	_expect(Song.matching("Christmas", 4).is_empty(), "both, with no song: none")
	var with_score: Array = Song.SONGS + [{name = "Aaa", category = Song.YOUR_SCORES, notes = []}]
	_expect(Song.sorted_of(with_score)[-1] == 10, "an imported score comes after the rated songs")
	_expect(Song.stars(2) == "★★☆☆☆" and Song.stars(5) == "★★★★★" and Song.stars(0) == "", "stars: %s, %s" % [Song.stars(2), Song.stars(0)])
	_expect(Song.bars_of({}, 10.0) == [4.0, 8.0], "4/4 by default: a bar line every 4 beats: %s" % [Song.bars_of({}, 10.0)])
	_expect(Song.bars_of({meter = 3, pickup = 1}, 11.0) == [1.0, 4.0, 7.0, 10.0], "3/4 after a one-beat pickup: %s" % [Song.bars_of({meter = 3, pickup = 1}, 11.0)])
	_expect(Song.bars_of({meter = 2}, 6.0) == [2.0, 4.0], "2/4: %s" % [Song.bars_of({meter = 2}, 6.0)])
	_expect(Song.bars_of({bars = [1, 4, 7]}, 6.0) == [1, 4], "a song's own bar lines, before its end")


## The library page, worked as a player would: from the Song row, by the six keys' acts.
func _check_page() -> void:
	var game: Node = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var hud: Node = game.hud
	var menu: Node = hud.get_node("MainMenu")
	var lib: Node = hud.get_node("Library")
	var cursor: MenuCursor = hud.cursor
	var song_row: Control = menu.get_node("Songs/Board/Rows/Grid/Song")
	var name: Button = song_row.get_node("Name")
	var category: Control = lib.get_node(BOX + "Filters/Category")
	var difficulty: Control = lib.get_node(BOX + "Filters/Difficulty")
	var back: Button = lib.get_node(BOX + "Foot/Back")
	menu.open(MainMenu.Page.PLAY)
	await process_frame
	_expect(name.text == "★★☆☆☆  Twinkle Twinkle", "the Song row names the song with its stars: %s" % name.text)
	_expect(song_row.has_node("Browse") and song_row.get_node("Browse").text == "Browse…", "the Song row has a Browse… button")
	await _act(hud, Act.DOWN)
	_expect(cursor.selected() == song_row and _lit(cursor) == "CDEFAB", "D from Start wraps to the Song row, A lit there: %s" % _lit(cursor))
	await _act(hud, Act.PRESS)
	_expect(lib.visible and not menu.visible and hud.menu_up(), "A on the Song row opens the library over the board")
	_expect(lib.filter() == {category = "", difficulty = 0} and lib.selected_song() == 0 and lib.at == 7,
		"it opens on every song, on the song picked: %s at %d" % [lib.filter(), lib.at])
	_expect(category.get_node("Value").text == Song.ALL_SONGS and difficulty.get_node("Value").text == "Any"
		and category.get_node("Count").text == "10 songs", "the filters say All songs, Any, 10 songs")
	_expect(lib.top == 0 and cursor.selected() == lib.line(7) and _lit(cursor) == "CDEFAB", "the cursor on the song's line, all six lit: %s" % _lit(cursor))
	await _act(hud, Act.DOWN)
	await _act(hud, Act.DOWN)
	_expect(lib.at == 9 and cursor.selected() == lib.line(9), "D moves down the list")
	await _act(hud, Act.DOWN)
	_expect(cursor.selected() == back and lib.at == 9, "D past the last song leaves the list, for Back")
	await _act(hud, Act.DOWN)
	_expect(cursor.selected() == category, "D from Back wraps round to the Category row")
	await _act(hud, Act.DOWN)
	await _act(hud, Act.DOWN)
	_expect(cursor.selected() == lib.line(9), "D down the filters comes into the list on its selection")
	await _act(hud, Act.RIGHT)
	_expect(lib.filter().category == "Children's songs" and lib.selected_song() == 0 and category.get_node("Value").text == "Children's songs",
		"F on the list changes the category, on the song picked, which is there")
	for k in 5:
		await _act(hud, Act.UP)
	_expect(lib.at == 0 and cursor.selected() == difficulty, "C up the list and past its first song: the Difficulty row")
	await _act(hud, Act.RIGHT)
	_expect(lib.filter() == {category = "Children's songs", difficulty = 1} and difficulty.get_node("Value").text == "★☆☆☆☆"
		and lib.get_node(BOX + "Songs/List").visible and lib.selected_song() == 2, "F: one star exactly, Ducklings first: %s" % [lib.filter()])
	await _act(hud, Act.DOWN)
	await _act(hud, Act.RIGHT)
	_expect(lib.filter().category == "Christmas" and not lib.get_node(BOX + "Songs/List").visible, "F on the list to Christmas, no one-star song")
	_expect(cursor.selected() == category and _lit(cursor) == "CDEFB", "the list gone, the cursor goes to Category, where F still works: %s" % _lit(cursor))
	lib.line(0).pressed.emit()
	_expect(lib.visible, "a stray click on an empty list picks nothing")
	await _act(hud, Act.LEFT)
	await _act(hud, Act.DOWN)
	_expect(lib.filter().category == "Children's songs" and cursor.selected() == difficulty, "E back to Children's songs, D to Difficulty")
	await _act(hud, Act.RIGHT)
	_expect(lib.selected_song() == 0 and category.get_node("Count").text == "3 songs", "two stars: Twinkle Twinkle there again, 3 songs")
	await _act(hud, Act.RIGHT)
	_expect(not lib.get_node(BOX + "Songs/List").visible and lib.get_node(BOX + "Songs/Empty").visible and category.get_node("Count").text == "0 songs",
		"three stars, no children's song: the list says none")
	await _act(hud, Act.DOWN)
	_expect(cursor.selected() == back, "D skips the empty list")
	await _act(hud, Act.UP)
	await _act(hud, Act.RIGHT)
	await _act(hud, Act.RIGHT)
	_expect(lib.filter().difficulty == 0 and difficulty.get_node("Value").text == "Any", "F past the last level wraps round to Any")
	await _act(hud, Act.UP)
	await _act(hud, Act.RIGHT)
	await _act(hud, Act.RIGHT)
	_expect(lib.filter().category == "Classical" and lib.selected_song() == 4, "F on Category: Christmas, then Classical, on its first song")
	await _act(hud, Act.DOWN)
	await _act(hud, Act.DOWN)
	await _act(hud, Act.DOWN)
	await _act(hud, Act.PRESS)
	_expect(not lib.visible and menu.visible and game.song == 7 and menu.filter == {category = "Classical", difficulty = 0},
		"A picks Ode to Joy in F: song %d, %s" % [game.song, menu.filter])
	_expect(name.text == "★★☆☆☆  Ode to Joy in F" and cursor.selected() == song_row, "the board names it, the cursor back on the Song row")
	await _act(hud, Act.RIGHT)
	_expect(game.song == 8, "F on the board steps within Classical, to Mountain King: %d" % game.song)
	await _act(hud, Act.LEFT)
	await _act(hud, Act.LEFT)
	_expect(game.song == 4, "E steps back within it: %d" % game.song)
	song_row.get_node("Browse").pressed.emit()
	await process_frame
	_expect(lib.visible and lib.filter().category == "Classical" and lib.selected_song() == 4, "Browse… opens it too, on the filter the song was picked with")
	await _act(hud, Act.LEFT)
	await _act(hud, Act.BACK)
	_expect(not lib.visible and menu.visible and game.song == 4 and menu.filter.category == "Classical", "B closes, the song and its filter kept")
	_expect(cursor.selected() == song_row, "the cursor back on the Song row")
	# a long list: the selection never at the edge, the marks say there is more
	lib.open(0, {category = "", difficulty = 0}, range(25).map(func(k: int) -> int: return k % 10))
	await process_frame
	for k in 12:
		await _act(hud, Act.DOWN)
	var line: int = lib.at - lib.top
	_expect(lib.at == 12 and line >= 1 and line <= lib.LINES - 2, "after 12 D on a list of 25 the selection is off the edge: line %d" % line)
	_expect(lib.get_node(BOX + "Above/Mark").visible and lib.get_node(BOX + "Below/Mark").visible, "the marks show songs above and below")
	for k in 12:
		await _act(hud, Act.DOWN)
	_expect(lib.at == 24 and lib.top == 15 and not lib.get_node(BOX + "Below/Mark").visible, "at the end the last line, nothing below")
	for k in 24:
		await _act(hud, Act.UP)
	_expect(lib.at == 0 and lib.top == 0 and not lib.get_node(BOX + "Above/Mark").visible, "C back to the top, the view with it")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	for k in 3:
		lib.get_node(BOX + "Songs/List").gui_input.emit(wheel)
	_expect(lib.top == 3 and lib.at >= lib.top and lib.at < lib.top + lib.LINES, "the wheel scrolls, the selection kept in view: top %d at %d" % [lib.top, lib.at])
	lib.line(4).mouse_entered.emit()
	_expect(lib.at == lib.top + 4 and cursor.selected() == lib.line(4), "pointing at a line selects it")
	lib.line(4).pressed.emit()
	_expect(not lib.visible and game.song == (lib.top + 4) % 10, "a click picks it: song %d" % game.song)
	await _check_preview(lib)
	game.queue_free()
	await process_frame


## The song the selection rests on plays its first 10 seconds at 80 BPM, on its own bus,
## fading out over the last; moving, closing or picking stops it at once.
func _check_preview(lib: Node) -> void:
	lib.open(0, {category = "", difficulty = 0})
	var player: Node = lib.get_node("Preview")
	var bus := AudioServer.get_bus_index(&"Preview")
	await create_timer(0.3).timeout
	_expect(lib.previewing() == -1 and player.played.is_empty(), "no preview before the selection has rested 0.6 s")
	await create_timer(0.7).timeout
	_expect(lib.previewing() == 0 and not player.played.is_empty() and player.sounding() > 0, "resting on Twinkle, it plays: %d sounds" % player.played.size())
	_expect(is_equal_approx(player._beat_ms, 750.0), "at 80 BPM, whatever the game's tempo: a beat of %.0f ms" % player._beat_ms)
	_expect(bus >= 0 and player.bus == &"Preview" and player.get_child(0).get_child(0).bus == &"Preview", "on the Preview bus")
	_expect(player.played.filter(func(p: Dictionary) -> bool: return p.chord).size() > 0, "the chords too")
	lib.move(-1)
	_expect(lib.previewing() == -1 and player.sounding() == 0, "a move stops it at once: %d sounding" % player.sounding())
	await create_timer(1.0).timeout
	_expect(lib.previewing() == lib.selected_song(), "the next song plays once the selection rests again")
	lib._preview_from -= 9500.0   # as if 9.5 s in
	await process_frame
	await process_frame
	_expect(AudioServer.get_bus_volume_db(bus) < -1.0, "in its last second it fades: %.1f dB" % AudioServer.get_bus_volume_db(bus))
	lib._preview_from -= 1000.0   # 10.5 s in
	await process_frame
	await process_frame
	_expect(lib.previewing() == -1 and player.sounding() == 0 and AudioServer.get_bus_volume_db(bus) < -1.0,
		"after 10 s it stops, the bus still down while the voices die (no click): %d sounding, %.1f dB" % [player.sounding(), AudioServer.get_bus_volume_db(bus)])
	await create_timer(0.2).timeout
	_expect(is_equal_approx(AudioServer.get_bus_volume_db(bus), 0.0), "a moment later the bus is back at 0 dB: %.1f dB" % AudioServer.get_bus_volume_db(bus))
	await create_timer(1.0).timeout
	_expect(lib.previewing() == -1, "it plays once per rest, not again")
	lib.move(-1)
	await create_timer(1.0).timeout
	lib.close()
	_expect(lib.previewing() == -1 and player.sounding() == 0, "closing stops it")
	lib.open(0, {category = "", difficulty = 0})
	await create_timer(1.0).timeout
	lib.line(lib.at - lib.top).pressed.emit()
	_expect(lib.previewing() == -1 and player.sounding() == 0, "picking stops it")


func _act(hud: Node, a: int) -> void:
	hud.menu_key(a)
	await process_frame


func _lit(cursor: MenuCursor) -> String:
	return "".join(cursor.lit().map(func(a: int) -> String: return "CDEFAB"[a]))


func _expect(ok: bool, what: String) -> void:
	if not ok:
		_failed = true
		push_error("library: not so: " + what)
