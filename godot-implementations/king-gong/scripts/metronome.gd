extends Node
## The beat tick, the game's only sound: the player hears their own instrument. The ticks are
## sine blips, like the spike's Web Audio ones, pushed through a generator so each lands on an
## exact sample frame.

var _player: AudioStreamPlayer
var _gen: AudioStreamGeneratorPlayback
var _rate := 0.0
var _capacity := 0
var _pushed := 0               # frames handed to the generator so far
var _ticks: Array[Dictionary] = []   # {frame, clip}, in time order
var _tick_lo := PackedVector2Array()
var _tick_hi := PackedVector2Array()
var _silence := PackedVector2Array()


func _ready() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate_mode = AudioStreamGenerator.MIX_RATE_OUTPUT
	gen.buffer_length = 0.1
	_player = AudioStreamPlayer.new()
	_player.stream = gen
	add_child(_player)
	_player.play()
	_gen = _player.get_stream_playback()
	_rate = AudioServer.get_mix_rate()
	_capacity = _gen.get_frames_available()
	_silence.resize(_capacity)
	_silence.fill(Vector2.ZERO)
	_tick_lo = _blip(900.0, 0.05, 0.09)
	_tick_hi = _blip(1250.0, 0.05, 0.16)


func _process(_delta: float) -> void:
	_fill()


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


func cancel_ticks() -> void:
	_ticks.clear()
	if _player == null:
		return
	# A playing generator can't be cleared, so drop what is already queued by restarting it.
	_player.stop()
	_player.play()
	_gen = _player.get_stream_playback()
	_pushed = 0


func _queue_tick(t_ms: float, clip: PackedVector2Array) -> void:
	var frame := _frame_at(t_ms)
	if frame >= _pushed:
		_ticks.append({frame = frame, clip = clip})


## The generator frame that will be heard at `t_ms` (same clock as Time.get_ticks_usec).
func _frame_at(t_ms: float) -> int:
	var queued := _capacity - _gen.get_frames_available()
	var heard_now := _pushed - queued - int(AudioServer.get_output_latency() * _rate)
	return heard_now + int((t_ms - Time.get_ticks_usec() / 1000.0) * _rate / 1000.0)


func _fill() -> void:
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


## Web Audio's tone() at one pitch: 5 ms exponential attack from silence, exponential decay
## back to silence at `dur`.
func _blip(freq: float, dur: float, vol: float) -> PackedVector2Array:
	var n := int(dur * _rate)
	var attack := int(0.005 * _rate)
	var up := pow(vol / 0.0001, 1.0 / attack)
	var down := pow(0.0001 / vol, 1.0 / (n - attack))
	var out := PackedVector2Array()
	out.resize(n)
	var g := 0.0001
	for i in n:
		var v := g * sin(TAU * freq * i / _rate)
		out[i] = Vector2(v, v)
		g *= up if i < attack else down
	return out
