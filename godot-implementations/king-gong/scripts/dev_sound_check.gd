extends SceneTree
## Dev check, not part of the game: the piano, and the song player that plays a song (or the
## part of it the player doesn't play) on it, tried headless.
##   Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://scripts/dev_sound_check.gd
## Prints "sound check: ok", or an error for each rule broken.

const PianoSound := preload("res://scripts/piano_sound.gd")
const SongPlayer := preload("res://scripts/song_player.gd")
const Song := preload("res://scripts/song.gd")
const Hud := preload("res://scripts/hud.gd")
const Drill := preload("res://scripts/drill.gd")

var _failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# the samples: the whole keyboard, every note within a semitone of one
	_expect(PianoSound.sample_count() == 30, "30 samples load, not %d" % PianoSound.sample_count())
	for midi in range(21, 109):
		_expect(absi(midi - PianoSound.sample_for(midi)) <= 1, "note %d plays from a sample a semitone away at most, not %d" % [midi, PianoSound.sample_for(midi)])

	# the voices: chords and more at once, a let-go fades, silence is at once
	var piano := PianoSound.new()
	root.add_child(piano)
	await process_frame
	var ids: Array[int] = []
	for k in 20:
		ids.append(piano.strike(48 + k, 96))
	_expect(piano.sounding() == 20, "20 notes sound at once, not %d" % piano.sounding())
	piano.release(ids[0])
	await create_timer(0.35).timeout
	_expect(piano.sounding() == 19, "a released note has faded out after 0.35 s: %d sounding" % piano.sounding())
	for k in 40:
		piano.strike(40 + k, 80)
	_expect(piano.sounding() == PianoSound.VOICES, "40 notes take over the oldest voices: %d sounding" % piano.sounding())
	piano.silence()
	_expect(piano.sounding() == 0, "silence stops every voice at once: %d sounding" % piano.sounding())
	piano.queue_free()

	# the game never sounds what the player plays: their own instrument does
	var game: Node = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	_expect(not game.has_node("YourNotes") and not "own_notes" in game, "the game has no piano for the player's own notes")

	# Listen stops for a key or a click, not for the volume keys, a modifier or the wheel
	game.listen()
	for code: Key in [KEY_VOLUMEUP, KEY_VOLUMEDOWN, KEY_VOLUMEMUTE, KEY_MEDIAPLAY, KEY_SHIFT, KEY_ALT]:
		var key := InputEventKey.new()
		key.keycode = code
		key.pressed = true
		game._input(key)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	game._input(wheel)
	_expect(game.listening, "the volume keys, Shift, Alt and the wheel leave Listen playing")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	game._input(click)
	_expect(not game.listening, "a click stops Listen")
	game.listen()
	var q := InputEventKey.new()
	q.keycode = KEY_Q
	q.pressed = true
	game._input(q)
	_expect(not game.listening, "any other key stops Listen")

	# backing: the game plays the part you don't, by the part, with one switch
	game.set_song(0)
	game.set_style(Song.Clef.TREBLE, false)
	_expect(game.backing_part() == "chords" and _row(game, "Backing"), "Treble clef: the chords, the Backing row shown")
	game.set_style(Song.Clef.BASS, false)
	_expect(game.backing_part() == "chords", "Bass clef: the chords")
	game.set_style(Song.Clef.TREBLE, true)
	_expect(game.backing_part() == "" and not _row(game, "Backing"), "Treble + chords: nothing, the row hidden")
	game.set_style(Song.Clef.TREBLE, true, true)
	_expect(game.backing_part() == "tune" and _row(game, "Backing"), "Chords only: the tune")
	game.set_style(Song.Clef.TREBLE, false)
	game.set_song(8)
	_expect(game.backing_part() == "" and not _row(game, "Backing"), "a song without chords: nothing, the row hidden")
	game.set_mode(Hud.Mode.DRILL)
	_expect(game.backing_part() == "tune" and not game.has_node("Arpeggio"), "the drill: the tune on its branches, nothing it doesn't show")
	game.set_mode(Hud.Mode.PLAY)
	game.set_song(0)
	game.start()
	game.set_backing(false)
	_expect(not game.hud.get_node("MainMenu/Drill/Board/Rows/Grid/Backing/Toggle").button_pressed, "the boards show Backing off")
	game._grab(0, Time.get_ticks_usec() / 1000.0, false)
	await process_frame
	_expect(game.song_player.played.is_empty(), "Backing off: a grab sounds nothing")
	game.set_backing(true)
	game._grab(0, Time.get_ticks_usec() / 1000.0, false)
	await process_frame
	_expect(game.song_player.played.size() == 1 and game.song_player.played[0].chord, "Backing on: a grab sounds its chord")
	game.show_menu()

	# the song player: chords below the tune, the sounds a song makes, played from a grab
	_expect(SongPlayer.voiced(Song.parse_chord("F"), 41) == [29, 33, 36], "F under F2 goes down an octave: %s" % [SongPlayer.voiced(Song.parse_chord("F"), 41)])
	_expect(SongPlayer.voiced(Song.parse_chord("C"), 60) == [48, 52, 55], "C under C4 stays where it is written")
	_expect(SongPlayer.voiced(Song.parse_chord("C"), 55) == [48, 52, 55], "a chord note level with the tune is not above it")
	_expect(SongPlayer.voiced(Song.parse_chord("C"), 50) == [36, 40, 43], "C under D3 goes down an octave")
	var player: SongPlayer = SongPlayer.new()
	root.add_child(player)
	var twinkle := Song.parse(0, Song.Clef.TREBLE, true)
	player.load_song(twinkle)
	var tune := player.sounds.filter(func(x: SongPlayer.Sound) -> bool: return not x.chord)
	var chords := player.sounds.filter(func(x: SongPlayer.Sound) -> bool: return x.chord)
	var changes := twinkle.filter(func(n: Song.Note) -> bool: return n.chord != null)
	_expect(tune.size() == twinkle.size(), "a tune sound per branch: %d for %d" % [tune.size(), twinkle.size()])
	_expect(chords.size() == changes.size(), "a chord sound per chord: %d for %d" % [chords.size(), changes.size()])
	_expect(is_equal_approx(chords[0].beats, changes[1].beat - changes[0].beat), "a chord rings until the next: %s beats" % chords[0].beats)
	_expect(tune.all(func(x: SongPlayer.Sound) -> bool: return x.beats == twinkle[x.branch].beats), "a tune note rings its own beats")
	player.load_song(Song.parse(8, Song.Clef.TREBLE, true))
	_expect(player.sounds.all(func(x: SongPlayer.Sound) -> bool: return not x.chord), "a song without chords plays its tune alone")
	player.load_song(twinkle, false, true)
	_expect(player.sounds.all(func(x: SongPlayer.Sound) -> bool: return x.chord) and player.sounds.size() == changes.size(), "the chords alone, for a tune the player plays")
	player.load_song(twinkle, true, false)
	_expect(player.sounds.all(func(x: SongPlayer.Sound) -> bool: return not x.chord) and player.sounds.size() == twinkle.size(), "the tune alone, for chords the player plays")
	player.load_song(twinkle)
	var now := Time.get_ticks_usec() / 1000.0
	player.grab(0, now - 5000.0, 500.0)   # long due: it starts at once
	await process_frame
	await process_frame
	_expect(_branches(player) == [0] and player.played.size() == 2, "a grab sounds its own branch, chord and note, and nothing ahead: %s" % [_branches(player)])
	_expect(player.sounding() == 4, "the chord's three voices and the note's: %d" % player.sounding())
	player.expect(1, now - 4500.0)
	await process_frame
	_expect(_branches(player) == [0, 1] and player.played.size() == 3, "the next branch, expected, sounds at its time: %s" % [_branches(player)])
	player.grab(1, now - 4500.0, 500.0)
	await process_frame
	_expect(player.played.size() == 3, "its grab at that time doesn't sound it twice: %d sounds" % player.played.size())
	player.grab(0, now - 100.0, 500.0)
	await process_frame
	_expect(player.played.size() == 5, "a branch grabbed again sounds again: %d sounds" % player.played.size())
	player.let_go()
	await create_timer(0.35).timeout
	_expect(player.sounding() == 0, "let go, it fades out: %d sounding" % player.sounding())
	player.stop()
	_expect(player.sounding() == 0, "stop silences it at once: %d" % player.sounding())
	player.play(500.0, Time.get_ticks_usec() / 1000.0 - 60000.0)
	player.stop()
	await process_frame
	_expect(player.sounding() == 0, "after stop nothing more starts: %d" % player.sounding())
	player.play(500.0, Time.get_ticks_usec() / 1000.0 - 60000.0)   # outside a level: the whole song from its start
	await process_frame
	_expect(player.played.size() == tune.size() + chords.size() + 5, "played from its start, every sound comes due: %d" % player.played.size())
	player.stop()
	# a chord let go (a fall, a pause, Backing off and on) comes back at the next grab, even in
	# the middle of it; while it rings, a grab there adds nothing
	player.load_song(twinkle, false, true)
	var mid: int = range(1, twinkle.size()).filter(func(j: int) -> bool: return twinkle[j].chord == null)[0]
	now = Time.get_ticks_usec() / 1000.0
	player.grab(0, now - 3000.0, 500.0)
	await process_frame
	player.grab(mid, now - 2000.0, 500.0)
	await process_frame
	_expect(player.played.size() == 1, "a grab in the middle of a ringing chord adds nothing: %d sounds" % player.played.size())
	player.let_go()
	player.grab(mid, now - 1000.0, 500.0)
	await process_frame
	_expect(player.played.size() == 2 and player.played[1].chord, "after a fall, the chord comes back at the next grab: %d sounds" % player.played.size())
	player.stop()
	player.grab(mid, now - 500.0, 500.0)
	await process_frame
	_expect(player.played.size() == 3, "after a pause too: %d sounds" % player.played.size())
	player.stop()
	# a chord that stays sounds again at each bar line: on the branch that starts the bar, or,
	# where the bar line falls in a held note or a rest, at its beat from the branch before;
	# not where the chord changes, nor before the first chord
	var bars := [4.0, 8.0, 12.0, 16.0]
	var held := Song.parse_entries([["C4", 1, "C"], ["E4", 1], ["G4", 2], ["E4", 2], ["r", 4], ["D4", 2, "G"], ["B3", 4], ["C4", 4, "C"]], Song.Clef.TREBLE, true)
	player.load_song(held, false, true)
	_expect(_chords(player) == [[0.0, 0], [10.0, 4], [16.0, 6]], "with no bar lines, a chord only where it changes: %s" % [_chords(player)])
	player.load_song(held, false, true, bars)
	_expect(_chords(player) == [[0.0, 0], [4.0, 3], [8.0, 3], [10.0, 4], [12.0, 5], [16.0, 6]], "the chord again at each bar line it stays over: %s" % [_chords(player)])
	_expect(player.sounds[2].midi == SongPlayer.voiced(Song.parse_chord("C"), held[3].midi) and player.sounds[4].midi == SongPlayer.voiced(Song.parse_chord("G"), held[5].midi),
		"each voiced below the note of its branch: %s, %s" % [player.sounds[2].midi, player.sounds[4].midi])
	var rings := player.sounds.map(func(x: SongPlayer.Sound) -> float: return x.beats)
	_expect(rings == [4.0, 4.0, 2.0, 2.0, 4.0, 4.0], "each rings to the next: %s" % [rings])
	player.load_song(Song.parse_entries([["G4", 1], ["E4", 4], ["C4", 4, "C"], ["E4", 4]], Song.Clef.TREBLE, true), false, true, [1.0, 5.0, 9.0])
	_expect(_chords(player) == [[5.0, 2], [9.0, 3]], "no chord again before the first chord: %s" % [_chords(player)])
	player.load_song(held, true, true, bars)
	player.play(500.0, Time.get_ticks_usec() / 1000.0 - 60000.0)
	await process_frame
	var heard := player.played.filter(func(p: Dictionary) -> bool: return p.chord).map(func(p: Dictionary) -> float: return p.get("beat", -1.0))
	_expect(heard == [0.0, 4.0, 8.0, 10.0, 12.0, 16.0], "played from its start, each chord in its turn: %s" % [heard])
	player.stop()
	player.load_song(held, false, true, bars)
	now = Time.get_ticks_usec() / 1000.0
	player.grab(3, now - 100.0, 500.0)
	await process_frame
	var waiting := player._pending.map(func(p: Dictionary) -> float: return p.due - now)
	_expect(player.played.size() == 1 and player.played[0].get("beat", -1.0) == 4.0, "a grab of the bar's first branch sounds its chord at once: %s" % [player.played])
	_expect(waiting.size() == 1 and is_equal_approx(waiting[0], 1900.0), "and the one in its rest four beats after the grab: due in %s ms" % [waiting])
	player.stop()
	player.load_song(held, false, true, bars)
	player.expect(3, now + 1000.0)
	waiting = player._pending.map(func(p: Dictionary) -> float: return p.due - now)
	_expect(waiting.size() == 2 and is_equal_approx(waiting[0], 1000.0) and is_equal_approx(waiting[1], 3000.0), "expected, both wait for their beats: due in %s ms" % [waiting])
	player.stop()

	# the drill's tune, which backing plays: the branches before each log are its chord, low to
	# high, all as long; each log's own branch is its chord's root
	var c := Song.parse_chord("C")
	var g := Song.parse_chord("G")
	_expect(Drill.arpeggio(g, 4) == [["D4", 1.0], ["G4", 1.0], ["B4", 1.0]], "G, a chord every 4 beats: three quarters: %s" % [Drill.arpeggio(g, 4)])
	_expect(Drill.arpeggio(c, 4) == [["C4", 0.5], ["E4", 0.5], ["G4", 0.5], ["C5", 0.5]], "C every 4: four eighths: %s" % [Drill.arpeggio(c, 4)])
	_expect(Drill.arpeggio(g, 8) == [["D4", 2.0], ["G4", 2.0], ["B4", 2.0]], "G every 8: half notes: %s" % [Drill.arpeggio(g, 8)])
	_expect(Drill.arpeggio(c, 8) == [["C4", 1.0], ["E4", 1.0], ["G4", 1.0], ["C5", 1.0]], "C every 8: quarters: %s" % [Drill.arpeggio(c, 8)])
	_expect(Drill.arpeggio(c, 2) == [["E4", 0.5], ["G4", 0.5], ["C5", 0.5]], "C every 2: its top three, eighths: %s" % [Drill.arpeggio(c, 2)])
	_expect(Drill.arpeggio(Song.parse_chord("C7"), 3) == [["C4", 0.5], ["E4", 0.5], ["G4", 0.5], ["Bb4", 0.5], ["C5", 0.5]], "C7 every 3: five eighths: %s" % [Drill.arpeggio(Song.parse_chord("C7"), 3)])
	_expect(Drill.arpeggio(c, 1).is_empty(), "a chord every beat: nothing between the logs")
	for beats in range(Drill.BEATS_MIN, Drill.BEATS_MAX + 1):
		var drill := Song.parse_entries(Drill.entries(Drill.all_chords(), 24, beats), Song.Clef.TREBLE, true)
		var logs := range(drill.size()).filter(func(i: int) -> bool: return drill[i].chord != null)
		_expect(logs.size() == 24 and range(24).all(func(k: int) -> bool: return is_equal_approx(drill[logs[k]].beat, k * beats)), "a chord every %d beats, 24 of them" % beats)
		for k in logs.size():
			var at := drill[logs[k]]
			_expect(posmod(at.midi - at.chord.midi[0], 12) == 0 and at.midi >= 60 and at.midi <= 71, "the log of %s is on its root, %s" % [at.chord.name, at.name])
			var run := drill.slice(logs[k] + 1, logs[k + 1] if k + 1 < logs.size() else drill.size())
			if k + 1 == logs.size():
				_expect(run.is_empty() and at.beats == beats, "the last log holds the round's last %d beats" % beats)
				continue
			var next := drill[logs[k + 1]].chord
			var want := Drill.arpeggio(next, beats)
			_expect(run.map(func(n: Song.Note) -> Array: return [n.name, n.beats]) == want, "every %d beats, before %s: %s" % [beats, next.name, want])
			_expect(want.size() >= 2 or (beats == 1 and want.is_empty()), "an arpeggio has two notes at least: %s every %d" % [next.name, beats])
			for i in run.size():
				_expect(Array(next.midi).any(func(m: int) -> bool: return posmod(run[i].midi - m, 12) == 0) and run[i].midi >= 60 and run[i].midi <= 72
					and (i == 0 or run[i].midi > run[i - 1].midi) and run[i].beats == run[0].beats and at.beats >= run[0].beats,
					"before %s, every %d beats: %s is its note, low to high, as long as the others, no longer than the log's" % [next.name, beats, run[i].name])

	print("sound check: ok" if not _failed else "sound check: failed")
	quit()


## Whether the song board's row `name` shows.
func _row(game: Node, name: String) -> bool:
	return game.hud.get_node("MainMenu/Songs/Board/Rows/Grid/" + name).visible


## The player's chord sounds, each as [beat, branch].
func _chords(player: SongPlayer) -> Array:
	return player.sounds.filter(func(x: SongPlayer.Sound) -> bool: return x.chord).map(func(x: SongPlayer.Sound) -> Array: return [x.beat, x.branch])


## The branches whose sounds have started, in order.
func _branches(player: SongPlayer) -> Array:
	var out := []
	for x: Dictionary in player.played:
		if not x.branch in out:
			out.append(x.branch)
	return out


func _expect(ok: bool, what: String) -> void:
	if not ok:
		_failed = true
		push_error("sound: not so: " + what)
