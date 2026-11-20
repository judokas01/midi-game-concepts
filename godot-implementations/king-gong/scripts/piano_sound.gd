extends Node
## A sampled acoustic piano: recordings of a real one (the Salamander Grand Piano, see
## art/CREDITS.md), one every minor third from A0 to C8, pitched up or down a semitone for the
## notes between. A struck note rings and dies away as the recording does; let go, it fades out
## in RELEASE_S, like a piano without the pedal.
##
## Each voice is an AudioStreamPlayer, so Godot mixes them, and smooths a voice's volume over
## each mix block: the release fades without steps. A voice starts at the next mix block and is
## heard an output latency later, which heard_ms() says. A frame can only start notes at the
## next mix block, so a note due at some moment starts in the frame that has it heard nearest
## to that moment (due_now()). Notes always start at the beginning of their recording:
## Godot's Ogg seek doesn't land inside the first page of audio.

const DIR := "res://sounds/piano/"
const LOWEST := 21     # A0, the lowest recording
const HIGHEST := 108   # C8, the highest
const EVERY := 3       # semitones from one recording to the next
const SAMPLE_NAMES := ["C", "", "", "Ds", "", "", "Fs", "", "", "A", "", ""]   # by pitch class
const VOICES := 32
const RELEASE_S := 0.25
const RELEASE_DB := 40.0   # how far the release fades before the voice stops
const MAX_FRAME_MS := 20.0  # due_now(): the next frame is expected this soon at most
const MAX_BLOCK_MS := 12.0  # and a mix block lasts this long at most

@export var volume_db := 0.0   # this piano's level, before each note's loudness
@export var bus := &"Master"   # where its voices play: set before it enters the tree

var started := 0   # voices started so far, for the dev checks

static var _samples := {}   # sampled midi -> AudioStream
static var _block_ms := 10.0   # the longest wait for the next mix block seen: about a block

var _voices: Array[AudioStreamPlayer] = []
var _ids: Array[int] = []        # by voice: the id of the note it plays, 0 for none yet
var _fades: Array[Tween] = []    # by voice: its release, if one runs
var _next_id := 1


## The recordings, loaded once for every piano.
static func sample_count() -> int:
	_load()
	return _samples.size()


## The recorded note that plays `midi`: the nearest, within the keyboard's.
static func sample_for(midi: int) -> int:
	return clampi(LOWEST + EVERY * roundi((midi - LOWEST) / float(EVERY)), LOWEST, HIGHEST)


## When a voice started now is heard, in ms on the clock Time.get_ticks_usec() counts.
static func heard_ms() -> float:
	return Time.get_ticks_usec() / 1000.0 + (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()) * 1000.0


## Whether a note to be heard at `due_ms` should start in this frame, `frame_s` after the last:
## starting now, it is heard at heard_ms(); waiting, a frame and up to a mix block later. The
## line between them is halfway, so it is never more than about half a frame and a block off.
static func due_now(due_ms: float, frame_s: float) -> bool:
	_block_ms = maxf(_block_ms, clampf(AudioServer.get_time_to_next_mix() * 1000.0, 0.0, MAX_BLOCK_MS))
	var frame_ms := minf(frame_s * 1000.0, MAX_FRAME_MS)   # a slow frame says nothing of the next
	return due_ms <= heard_ms() + (frame_ms + _block_ms) / 2.0


static func _load() -> void:
	if not _samples.is_empty():
		return
	for m in range(LOWEST, HIGHEST + 1, EVERY):
		_samples[m] = load("%s%s%d.ogg" % [DIR, SAMPLE_NAMES[m % 12], floori(m / 12.0) - 1])


func _ready() -> void:
	_load()
	for k in VOICES:
		var voice := AudioStreamPlayer.new()
		voice.bus = bus
		add_child(voice)
		_voices.append(voice)
		_ids.append(0)
		_fades.append(null)


## Starts note `midi` now, as loud as MIDI `velocity` (1 to 127) plays it. The id lets it go.
## With every voice busy, the one struck longest ago plays it.
func strike(midi: int, velocity: int) -> int:
	var k := _free_voice()
	if _fades[k]:
		_fades[k].kill()
		_fades[k] = null
	var sample := sample_for(midi)
	var voice := _voices[k]
	voice.stream = _samples[sample]
	voice.pitch_scale = pow(2.0, (midi - sample) / 12.0)
	voice.volume_db = volume_db + linear_to_db(clampi(velocity, 1, 127) / 127.0)
	voice.play()
	_ids[k] = _next_id
	_next_id += 1
	started += 1
	return _ids[k]


## Lets note `id` go: it fades out over RELEASE_S. A voice that has gone on to another note
## since is left alone.
func release(id: int) -> void:
	var k := _ids.find(id)
	if k < 0 or _fades[k] or not _voices[k].playing:
		return
	var voice := _voices[k]
	_fades[k] = create_tween()
	_fades[k].tween_property(voice, "volume_db", voice.volume_db - RELEASE_DB, RELEASE_S)
	_fades[k].tween_callback(func() -> void:
		voice.stop()
		_fades[k] = null)


## Every voice stops, at once.
func silence() -> void:
	for k in VOICES:
		if _fades[k]:
			_fades[k].kill()
			_fades[k] = null
		_voices[k].stop()


## Voices sounding, fading ones too.
func sounding() -> int:
	return _voices.filter(func(v: AudioStreamPlayer) -> bool: return v.playing).size()


## A silent voice, or else the one struck longest ago.
func _free_voice() -> int:
	var oldest := 0
	for k in VOICES:
		if not _voices[k].playing:
			return k
		if _ids[k] < _ids[oldest]:
			oldest = k
	return oldest
