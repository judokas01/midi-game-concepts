extends RefCounted
## The run being played: the settings it started with and every input the game took in it,
## timed from its start. Each new run (Start, Restart song, Enter, Play again, a new drill
## round) starts it afresh, so it only ever holds the one. Nothing is written unless the
## player reports a bug from the pause menu: then write() puts it in a file, with what they say
## happened and how the game stood. dev_replay.gd plays such a file back.
##
## The file is JSON:
##   report     the player's words
##   saved      when, local time
##   settings   song (its name) and song_number (in Song.library()), or in the drill
##              drill: {chords, count, beats, entries}, the round as it was dealt; mode, clef,
##              chords, by_itself, practice, bpm, tick, backing, labels, hint, keyboard_hint,
##              and input, the one that played last ("MIDI" or "keyboard")
##   at_report  how the game stood: state, branch, done_up_to, falls, bananas, misses,
##              progress, and message, the last thing it said (why you fell, what was wrong)
##   level      each branch as the run laid it out, "G4 2 rest 1 [C]": a replay can tell the
##              song has changed since
##   events     one a line, [ms from the start, what, ...]:
##                [t, "on", 60, "HANG", 4]   a note played, its MIDI number, at the time it was
##                [t, "off", 60, "AIR", 4]   stamped with; or let go of. With the game's state and
##                                           branch as it came, before the game took it
##                [t, "pause", "HANG", 10]   Esc, and the state and branch it paused in
##                [t, "resume"]              Continue
##                [t, "bpm", 65.0]           a setting changed in the pause menu ("bpm", "practice",
##                                           "tick", "backing", "labels", "hint"), or the input that
##                                           played ("source"), with its new value
##              Notes that worked a menu are left out: the game didn't take them

const VERSION := 1
const DIR := "res://bug-reports"            # the project folder, as the game runs from source
const EXPORTED_DIR := "user://bug-reports"  # an exported game can't write to its own

var settings := {}
var level: Array = []
var events: Array = []
var start_ms := 0.0   # Game.now_ms() at the run's start


## A new run, starting at `at_ms`: everything of the last one goes.
func begin(run_settings: Dictionary, branches: Array, at_ms: float) -> void:
	settings = run_settings
	level = branches
	events = []
	start_ms = at_ms


## Something that happened at `at_ms`, `kind`, with its `values` (see the events above).
func add(at_ms: float, kind: String, values: Array = []) -> void:
	events.append([_since(at_ms), kind] + values)


## Writes the run with the player's `text` and how the game stood, `at_report`, to a new file.
## Its path, or "" if it couldn't be written.
func write(text: String, at_report: Dictionary) -> String:
	var dir := EXPORTED_DIR if OS.has_feature("template") else DIR
	DirAccess.make_dir_recursive_absolute(dir)
	if not FileAccess.file_exists(dir + "/.gdignore"):
		FileAccess.open(dir + "/.gdignore", FileAccess.WRITE)   # the editor leaves the reports alone
	var saved := Time.get_datetime_string_from_system(false, true)
	var stem := "%s/%s_%s" % [dir, saved.replace(":", "-").replace(" ", "_"), _slug()]
	var path := stem + ".json"
	var n := 2
	while FileAccess.file_exists(path):
		path = "%s-%d.json" % [stem, n]
		n += 1
	var head := {report = text, saved = saved, version = VERSION, settings = settings, at_report = at_report}
	var body := JSON.stringify(head, "\t", false).strip_edges()
	body = body.substr(0, body.length() - 1).strip_edges(false, true)   # the closing brace, for the lists
	body += ",\n" + _list("level", level) + ",\n" + _list("events", events) + "\n}\n"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("bug report: can't write %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return ""
	file.store_string(body)
	file.close()
	return path


## A report written by write(); empty if it can't be read.
static func read(path: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}


func _since(t: float) -> float:
	return snappedf(t - start_ms, 0.1)


## The song's name, or the drill, fit for a file name: "skákal-pes".
func _slug() -> String:
	var name: String = "chord drill" if settings.has("drill") else settings.get("song", "song")
	return name.validate_filename().to_lower().replace(" ", "-").replace("'", "")


## `items` as the JSON list `key`, one item a line.
func _list(key: String, items: Array) -> String:
	if items.is_empty():
		return "\t\"%s\": []" % key
	return "\t\"%s\": [\n\t\t%s\n\t]" % [key, ",\n\t\t".join(items.map(func(item: Variant) -> String: return JSON.stringify(item)))]
