class_name DamageZone
extends Area3D

@export var damage_per_second: float = 20.0
@export var grace_period: float = 10.0

@export var zone_type: Type = Type.HOT
@export var biome_name: String = "biome name"
@export var biome_description: String = "biome description"

@export var min_ambience_delay := 2.0
@export var max_ambience_delay := 7.0
@export var ambience_sounds: Array[AudioStream]
@onready var ambience_timer: Timer = $AmbienceTimer
@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer

enum Type{
	HOT,
	COLD
}

var player_inside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ambience_timer.timeout.connect(_on_ambience_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	print(str(self))
	print("entered by : " + str(body))
	if body is Player:
		body.enter_zone(self)
		player_inside = true
		_schedule_next_ambience()
	else: # should never happen since checks on layer 2 = Player
		print(self, "Unexepected Body entry was not player")

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.exit_zone(self)
		player_inside = false
		ambience_timer.stop()
		fade_out_audio(ambience_player)

func _on_ambience_timeout():
	if !player_inside:
		return

	if ambience_sounds.size() > 0:
		ambience_player.stream = ambience_sounds.pick_random()
		ambience_player.play()

	_schedule_next_ambience()

func _schedule_next_ambience():
	ambience_timer.start(
		randf_range(min_ambience_delay, max_ambience_delay)
	)

func fade_out_audio(player: AudioStreamPlayer, duration: float = 2.0):
	var tween = create_tween()

	tween.tween_property(
		player,
		"volume_db",
		-80.0,
		duration
	)

	tween.finished.connect(func():
		player.stop()
		player.volume_db = 0.0 # Reset for next play
	)
