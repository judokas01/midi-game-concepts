extends Node
## Every sound is generated in code, mirroring the spike's Web Audio graph: the note synth,
## the one-shot effects and the beat tick. Notes and effects are rendered once into
## AudioStreamWAVs; the tick runs through a generator so it lands on exact sample frames.

const RATE := 44100            # effects
const NOTE_RATE := 22050       # held notes: a triangle up to C6 needs no more
const NOTE_PEAK := 0.2
const NOTE_SUSTAIN := 0.07
const NOTE_RELEASE_S := 0.08
const PRERENDER := [60, 72]    # C4..C5, so the first press of a song note doesn't hitch
const WIN_NOTES: Array[float] = [523.0, 659.0, 784.0, 1047.0]

var synth_on := true

var _notes: AudioStreamPlaybackPolyphonic
var _sfx: AudioStreamPlaybackPolyphonic
var _note_streams := {}        # midi -> AudioStreamWAV
var _sfx_streams := {}         # name -> AudioStreamWAV
var _voices := {}              # midi -> stream id on _notes

var _tick_player: AudioStreamPlayer
var _gen: AudioStreamGeneratorPlayback
var _gen_rate := 0.0
var _gen_capacity := 0
var _pushed := 0               # frames handed to the generator so far
var _ticks: Array[Dictionary] = []   # {frame, clip}, in time order
var _tick_lo := PackedVector2Array()
var _tick_hi := PackedVector2Array()
var _silence := PackedVector2Array()


func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	_notes = _polyphonic_player(24)
	_sfx = _polyphonic_player(16)
	for m in range(PRERENDER[0], PRERENDER[1] + 1):
		_note_stream(m)
	var fanfare := []
	for i in WIN_NOTES.size():
		fanfare.append([_tone(&"triangle", WIN_NOTES[i], WIN_NOTES[i], 0.3, 0.15), 0.12 * i])
	_sfx_streams = {
		&"grab": _mix([_hiss(0.07, 900.0, &"bandpass", 0.25, 1.5)]),
		&"creak": _mix([_tone(&"saw", 95.0, 70.0, 0.4, 0.05), _hiss(0.35, 420.0, &"bandpass", 0.2, 9.0)]),
		&"crack": _mix([_hiss(0.14, 1800.0, &"highpass", 0.5), _tone(&"sine", 140.0, 60.0, 0.15, 0.3)]),
		&"fall": _mix([_tone(&"sine", 520.0, 130.0, 0.6, 0.15)]),
		&"thud": _mix([_tone(&"sine", 90.0, 45.0, 0.2, 0.5), _hiss(0.15, 300.0, &"lowpass", 0.3)]),
		&"magic": _mix([_tone(&"sine", 220.0, 880.0, 0.55, 0.2), _tone(&"triangle", 330.0, 1320.0, 0.55, 0.08)]),
		&"boing": _mix([_tone(&"sine", 160.0, 420.0, 0.3, 0.2)]),
		&"collect": _mix([_tone(&"sine", 1047.0, 1047.0, 0.12, 0.15), [_tone(&"sine", 1319.0, 1319.0, 0.18, 0.15), 0.08]]),
		&"win": _mix(fanfare),
	}
	_start_tick_generator()
	print("Synth ready in %d ms" % (Time.get_ticks_msec() - t0))


func _process(_delta: float) -> void:
	_fill_ticks()


# ---------------------------------------------------------------- public

func sfx(effect: StringName) -> void:
	_sfx.play_stream(_sfx_streams[effect])


func play_note(midi: int) -> void:
	if not synth_on:
		return
	stop_note(midi)
	_voices[midi] = _notes.play_stream(_note_stream(midi))


func stop_note(midi: int) -> void:
	if not _voices.has(midi):
		return
	var id: int = _voices[midi]
	_voices.erase(midi)
	var fade := create_tween()   # linear fade, as in the spike
	fade.tween_method(func(v: float) -> void: _notes.set_stream_volume(id, linear_to_db(maxf(v, 0.0001))),
		1.0, 0.0, NOTE_RELEASE_S)
	fade.tween_callback(func() -> void: _notes.stop_stream(id))


func stop_all_notes() -> void:
	for midi: int in _voices.keys():
		stop_note(midi)


## Ticks count the beats of the branch just grabbed (held for `hold` beats, then `rest` beats
## of rest), from that grab. When a rest follows, the let-go gets a tick even off the beat. The
## last (higher) one is the moment to grab the next branch.
func schedule_ticks(grab_ms: float, beat_ms: float, hold: float, rest: float) -> void:
	cancel_ticks()
	var lo: Array[float] = []
	for k in range(1, ceili(hold + rest)):
		lo.append(float(k))
	if rest > 0.0 and not lo.has(hold):
		lo.append(hold)
		lo.sort()
	for beat in lo:
		_queue_tick(grab_ms + beat * beat_ms, _tick_lo)
	_queue_tick(grab_ms + (hold + rest) * beat_ms, _tick_hi)


func _queue_tick(t_ms: float, clip: PackedVector2Array) -> void:
	var frame := _frame_at(t_ms)
	if frame >= _pushed:
		_ticks.append({frame = frame, clip = clip})


func cancel_ticks() -> void:
	_ticks.clear()
	if _tick_player == null:
		return
	# A playing generator can't be cleared, so drop what is already queued by restarting it.
	_tick_player.stop()
	_tick_player.play()
	_gen = _tick_player.get_stream_playback()
	_pushed = 0


# ---------------------------------------------------------------- beat tick

func _start_tick_generator() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate_mode = AudioStreamGenerator.MIX_RATE_OUTPUT
	gen.buffer_length = 0.1
	_tick_player = AudioStreamPlayer.new()
	_tick_player.stream = gen
	add_child(_tick_player)
	_tick_player.play()
	_gen = _tick_player.get_stream_playback()
	_gen_rate = AudioServer.get_mix_rate()
	_gen_capacity = _gen.get_frames_available()
	_silence.resize(_gen_capacity)
	_silence.fill(Vector2.ZERO)
	_tick_lo = _stereo(_tone(&"sine", 900.0, 900.0, 0.05, 0.09, _gen_rate))
	_tick_hi = _stereo(_tone(&"sine", 1250.0, 1250.0, 0.05, 0.16, _gen_rate))


## The generator frame that will be heard at `t_ms` (same clock as Time.get_ticks_usec).
func _frame_at(t_ms: float) -> int:
	var queued := _gen_capacity - _gen.get_frames_available()
	var heard_now := _pushed - queued - int(AudioServer.get_output_latency() * _gen_rate)
	return heard_now + int((t_ms - Time.get_ticks_usec() / 1000.0) * _gen_rate / 1000.0)


func _fill_ticks() -> void:
	var room := _gen.get_frames_available()
	while room > 0:
		var take := room
		if not _ticks.is_empty():
			var clip: PackedVector2Array = _ticks[0].clip
			var offset: int = _pushed - _ticks[0].frame
			if offset >= clip.size():
				_ticks.pop_front()
				continue
			if offset >= 0:
				take = mini(room, clip.size() - offset)
				_gen.push_buffer(clip.slice(offset, offset + take))
				_pushed += take
				room -= take
				continue
			take = mini(room, -offset)
		_gen.push_buffer(_silence.slice(0, take))
		_pushed += take
		room -= take


# ---------------------------------------------------------------- rendering

func _polyphonic_player(voices: int) -> AudioStreamPlaybackPolyphonic:
	var stream := AudioStreamPolyphonic.new()
	stream.polyphony = voices
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	return player.get_stream_playback()


## Triangle: 10 ms linear attack to 0.2, exponential decay to 0.07 at 0.5 s, then held.
## The held part loops over a whole number of periods; the pitch is nudged by a fraction
## of a cent so that number comes out exact and the loop has no seam.
func _note_stream(midi: int) -> AudioStreamWAV:
	if _note_streams.has(midi):
		return _note_streams[midi]
	var f := 440.0 * pow(2.0, (midi - 69) / 12.0)
	var periods := 1
	var best := 1.0
	for k in range(1, 400):
		var err := absf(k * NOTE_RATE / f - roundf(k * NOTE_RATE / f))
		if err < best:
			best = err
			periods = k
		if err < 0.02:
			break
	var loop_len := int(roundf(periods * NOTE_RATE / f))
	f = periods * float(NOTE_RATE) / loop_len
	var head := int(0.5 * NOTE_RATE)
	var attack := int(0.01 * NOTE_RATE)
	var decay := pow(NOTE_SUSTAIN / NOTE_PEAK, 1.0 / (head - attack))
	var out := PackedFloat32Array()
	out.resize(head + loop_len)
	var env := NOTE_PEAK
	for i in out.size():
		var p := fmod(i * f / NOTE_RATE, 1.0)
		var g: float
		if i < attack:
			g = NOTE_PEAK * i / attack
		elif i < head:
			g = env
			env *= decay
		else:
			g = NOTE_SUSTAIN
		out[i] = g * (1.0 - 4.0 * absf(p - 0.5))
	var wav := _wav(out, NOTE_RATE)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = head
	wav.loop_end = out.size()
	_note_streams[midi] = wav
	return wav


## Web Audio's tone(): exponential pitch sweep over `dur`, 5 ms exponential attack from
## silence, exponential decay back to silence at `dur`.
func _tone(wave: StringName, f0: float, f1: float, dur: float, vol: float, rate := float(RATE)) -> PackedFloat32Array:
	var n := int(dur * rate)
	var attack := int(0.005 * rate)
	var f_mul := pow(f1 / f0, 1.0 / n)
	var up := pow(vol / 0.0001, 1.0 / attack)
	var down := pow(0.0001 / vol, 1.0 / (n - attack))
	var out := PackedFloat32Array()
	out.resize(n)
	var f := f0
	var g := 0.0001
	var p := 0.0
	for i in n:
		var v: float
		match wave:
			&"sine": v = sin(TAU * p)
			&"triangle": v = 1.0 - 4.0 * absf(p - 0.5)
			_: v = 2.0 * p - 1.0   # saw
		out[i] = g * v
		p = fmod(p + f / rate, 1.0)
		f *= f_mul
		g *= up if i < attack else down
	return out


## Web Audio's hiss(): white noise through a biquad, decaying exponentially from `vol`.
## Like Web Audio, lowpass/highpass read Q in dB and bandpass reads it as a plain ratio.
func _hiss(dur: float, freq: float, type: StringName, vol: float, q := 1.0) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var w0 := TAU * freq / RATE
	var cw := cos(w0)
	var alpha := sin(w0) / (2.0 * (q if type == &"bandpass" else pow(10.0, q / 20.0)))
	var b := [alpha, 0.0, -alpha]
	if type == &"lowpass":
		b = [(1.0 - cw) / 2.0, 1.0 - cw, (1.0 - cw) / 2.0]
	elif type == &"highpass":
		b = [(1.0 + cw) / 2.0, -(1.0 + cw), (1.0 + cw) / 2.0]
	var a0 := 1.0 + alpha
	var b0: float = b[0] / a0
	var b1: float = b[1] / a0
	var b2: float = b[2] / a0
	var a1 := -2.0 * cw / a0
	var a2 := (1.0 - alpha) / a0
	var x1 := 0.0
	var x2 := 0.0
	var y1 := 0.0
	var y2 := 0.0
	var g := vol
	var down := pow(0.0001 / vol, 1.0 / n)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var x := randf() * 2.0 - 1.0
		var y := b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
		x2 = x1
		x1 = x
		y2 = y1
		y1 = y
		out[i] = y * g
		g *= down
	return out


## Sums parts into one effect. A part is a buffer, or [buffer, start_seconds].
func _mix(parts: Array) -> AudioStreamWAV:
	var placed := parts.map(func(part: Variant) -> Array:
		return [part, 0] if part is PackedFloat32Array else [part[0], int(part[1] * RATE)])
	var length := 0
	for p: Array in placed:
		length = maxi(length, p[1] + p[0].size())
	var out := PackedFloat32Array()
	out.resize(length)
	out.fill(0.0)
	for p: Array in placed:
		var buf: PackedFloat32Array = p[0]
		var at: int = p[1]
		for i in buf.size():
			out[at + i] += buf[i]
	return _wav(out, RATE)


func _wav(samples: PackedFloat32Array, rate: int) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav


func _stereo(samples: PackedFloat32Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(samples.size())
	for i in samples.size():
		out[i] = Vector2(samples[i], samples[i])
	return out
