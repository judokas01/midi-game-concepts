extends SceneTree
## Not part of the game: plays one song of the library on the game's piano, its tune and
## chords, at 80 BPM (or --bpm=<n>), for checking a song by ear. Each bar prints as it starts,
## its chords in brackets, so a wrong note can be named by its bar. The song is picked by its
## number in the library (--list prints them) or by part of its name, accents optional.
## play-song.cmd runs it:
##   play-song 57            play-song "skakal pes"     play-song 57 60      play-song 57 80 tune
##   play-song list
## or by hand, from the project folder:
##   Godot_v4.7.2-stable_win64_console.exe --path . --display-driver headless --audio-driver WASAPI
##     --script res://scripts/play_song.gd -- --song=<number or name> [--bpm=<n>] [--tune] [--list]

const Song := preload("res://scripts/song.gd")
const SongPlayer := preload("res://scripts/song_player.gd")
const BPM := 80.0
const LEAD_MS := 800.0    # before the first beat
const RING_MS := 2000.0   # after the last, for the last chord to fade
# letters typed without their accent still find the song
const FOLD := {"á": "a", "č": "c", "ď": "d", "é": "e", "ě": "e", "í": "i", "ň": "n", "ó": "o",
	"ř": "r", "š": "s", "ť": "t", "ú": "u", "ů": "u", "ý": "y", "ž": "z", "ä": "a", "ö": "o",
	"ü": "u", "ß": "ss", "à": "a", "è": "e", "ì": "i", "ò": "o", "ù": "u", "ç": "c", "ñ": "n",
	"ʻ": "'", "’": "'"}

var _player: SongPlayer
var _bars: Array = []   # {beat, text}: each bar's first beat, and what it plays
var _shown := 0         # bars printed so far
var _first_beat := 0.0
var _start_ms := 0.0
var _beat_ms := 0.0
var _end_ms := 0.0


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	var pick := ""
	var bpm := BPM
	var tune_only := false
	for arg in OS.get_cmdline_user_args():
		if arg == "--list":
			_list()
			quit()
			return
		elif arg.begins_with("--song="):
			pick = arg.trim_prefix("--song=")
		elif arg.begins_with("--bpm="):
			bpm = float(arg.trim_prefix("--bpm="))
		elif arg == "--tune":
			tune_only = true
	var song := _find(pick)
	if song < 0:
		quit(1)
		return
	var entry: Dictionary = Song.library()[song]
	var notes := Song.parse(song, Song.Clef.TREBLE, true)
	var lines := Song.bar_lines(song, notes)
	var bar := "its own bar lines" if entry.has("bars") else "%d beats a bar" % entry.get("meter", 4)
	print("%d  %s  (%s, difficulty %s/5, key %s, %s%s), %d BPM%s" % [song, entry.name, entry.category,
		entry.get("difficulty", "-"), entry.get("key", "C"), bar,
		", pickup %s" % entry.pickup if entry.has("pickup") else "", bpm, ", the tune alone" if tune_only else ""])
	_bars = _bars_of(notes, lines, entry.has("pickup"))
	_beat_ms = 60000.0 / bpm
	_first_beat = notes[0].beat
	_start_ms = Time.get_ticks_usec() / 1000.0 + LEAD_MS
	_end_ms = _start_ms + (notes[-1].beat + notes[-1].beats - _first_beat) * _beat_ms + RING_MS
	_player = SongPlayer.new()
	root.add_child(_player)
	_player.load_song(notes, true, not tune_only, lines)
	_player.play(_beat_ms, _start_ms)


func _process(_delta: float) -> bool:
	if _player == null:
		return false
	var now := Time.get_ticks_usec() / 1000.0
	var beat := _first_beat + (now - _start_ms) / _beat_ms
	while _shown < _bars.size() and beat >= _bars[_shown].beat:
		print(_bars[_shown].text)
		_shown += 1
	if now >= _end_ms:
		print("end")
		quit()
	return false


## The song numbered or named `pick`, or -1, saying why.
func _find(pick: String) -> int:
	var songs := Song.library()
	if pick.is_valid_int():
		if int(pick) >= 0 and int(pick) < songs.size():
			return int(pick)
		printerr("No song %s: they are 0 to %d (play-song list)." % [pick, songs.size() - 1])
		return -1
	var wanted := _fold(pick)
	var found: Array[int] = []
	for k in songs.size():
		var name := _fold(songs[k].name)
		if name == wanted:
			return k
		if wanted != "" and wanted in name:
			found.append(k)
	if found.size() == 1:
		return found[0]
	if found.is_empty():
		printerr("No song's name has \"%s\" in it (play-song list)." % pick)
	else:
		printerr("%d songs match \"%s\": play one by its number." % [found.size(), pick])
		for k in found:
			printerr("  %3d  %s" % [k, songs[k].name])
	return -1


## Every song, by number: its difficulty, category and name.
func _list() -> void:
	var songs := Song.library()
	for k in songs.size():
		print("%3d  %s  %-22s  %s" % [k, songs[k].get("difficulty", "-"), songs[k].category, songs[k].name])


## The bars of `notes`, split at `lines`: "bar 3:  [C] E4 D4 C4  [G] D4 -". A rest is "-".
func _bars_of(notes: Array[Song.Note], lines: Array, pickup: bool) -> Array:
	var starts: Array = [notes[0].beat]
	starts.append_array(lines)
	var out := []
	for k in starts.size():
		var number := k if pickup else k + 1
		out.append({beat = float(starts[k]), text = ("pickup:" if number == 0 else "bar %d:" % number)})
	var bar := 0
	for n in notes:
		while bar + 1 < starts.size() and n.beat >= float(starts[bar + 1]) - 0.001:
			bar += 1
		var text := ""
		if n.chord:
			text += "  [%s]" % n.chord.name
		text += " " + n.name
		if n.rest_after > 0.0:
			text += " -"
		out[bar].text += text
	return out


func _fold(text: String) -> String:
	var out := text.to_lower().strip_edges()
	for letter: String in FOLD:
		out = out.replace(letter, FOLD[letter])
	return out
