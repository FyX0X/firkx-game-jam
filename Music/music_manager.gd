extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer

@export var idle_delay_min: float = 5.0   # min silence before next random track
@export var idle_delay_max: float = 15.0  # max silence before next random track

var _current_stream: AudioStream = null
var _playlist: Array[AudioStream] = []


func _ready() -> void:
	audio_player.finished.connect(_schedule_next)
	timer.timeout.connect(_play_next_random)
	
	# load playlist
	_playlist.append(preload("res://assets/audio/Audiodrill.wav"))
	_playlist.append(preload("res://assets/audio/desert/desert1.wav"))
	_playlist.append(preload("res://assets/audio/gameover.wav"))
	_playlist.append(preload("res://assets/audio/miningsound.wav"))
	
	
	# start random playlist
	_schedule_next()


func play(stream: AudioStream, fade_in: float = 0.0) -> void:
	if stream == _current_stream:
		return  # already playing this track, do nothing
	
	_current_stream = stream
	audio_player.stream = stream
	audio_player.play()
	
	if fade_in > 0.0:
		audio_player.volume_db = -80.0
		var tween := create_tween()
		tween.tween_property(audio_player, "volume_db", 0.0, fade_in)

func stop(fade_out: float = 0.0) -> void:
	if fade_out > 0.0:
		var tween := create_tween()
		tween.tween_property(audio_player, "volume_db", -80.0, fade_out)
		tween.tween_callback(audio_player.stop)
	else:
		audio_player.stop()
	_current_stream = null

func crossfade(stream: AudioStream, duration: float = 1.0) -> void:
	if stream == _current_stream:
		return
	stop(duration / 2.0)
	await get_tree().create_timer(duration / 2.0).timeout
	play(stream, duration / 2.0)

# --- Internals ---

func _schedule_next() -> void:
	print("schedule next")
	_current_stream = null
	var delay := randf_range(idle_delay_min, idle_delay_max)
	timer.start(delay)

func _play_next_random() -> void:
	if _playlist.is_empty():
		return
	# Pick a random track, avoiding immediate repeat
	var next: AudioStream
	if _playlist.size() == 1:
		next = _playlist[0]
	else:
		var candidates := _playlist.filter(func(t): return t != _current_stream)
		next = candidates.pick_random()
	play(next)
