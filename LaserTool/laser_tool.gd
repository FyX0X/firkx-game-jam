extends Node3D

@export var damage_per_second: float = 30.0
@export var resource_tick: float = 1.5

@onready var player: Player = get_parent()   # adjust path if needed
@onready var beam: MeshInstance3D = $Beam
@onready var pickup_audio: AudioStreamPlayer3D = $Beam/pickup_audio
@onready var laser_audio: AudioStreamPlayer3D = $Beam/laser_audio

var _tick_timer: float = 0.0
var _connected_target: Node  = null

func _process(delta: float) -> void:
	if Input.is_action_pressed("attack"):
		_do_laser(delta)
	else:
		_stop_laser()

func _do_laser(delta: float) -> void:
	if player.get_state() != Player.State.NORMAL:
		_stop_laser()
		return
		
	var target = player._current_target
	if target == null or not (target.is_in_group("minable") or target.is_in_group("breakable")):
		_stop_laser()
		return
	
	# connect signal if target changed
	if target != _connected_target:
		_disconnect_target()
		_connected_target = target
		if target.has_signal("resource_yielded"):
			target.resource_yielded.connect(_on_resource_yielded)
			
	beam.visible = true
	
	if laser_audio and not laser_audio.playing:
		laser_audio.play()
	
	
	if target.is_in_group("breakable"):
		target.take_damage(damage_per_second * delta, player.get_inventory())

	_tick_timer += delta
	if _tick_timer >= resource_tick:
		_tick_timer = 0.0
		if target.has_method("yield_resource"):
			target.yield_resource()

# Nouvelle fonction centralisée pour éteindre le laser et son audio
func _stop_laser() -> void:
	beam.visible = false
	_tick_timer = 0.0
	_disconnect_target()
	if laser_audio and laser_audio.playing:
		laser_audio.stop()

func _disconnect_target() -> void:
	if _connected_target != null:
		if _connected_target.has_signal("resource_yielded"):
			if _connected_target.resource_yielded.is_connected(_on_resource_yielded):
				_connected_target.resource_yielded.disconnect(_on_resource_yielded)
		_connected_target = null

func _on_resource_yielded(ore_type: String, amount: int) -> void:
	print("_on_resource_yielded()")
	player.pickup_resource(ore_type, amount)
	if pickup_audio:
		if pickup_audio.playing:
			pickup_audio.stop()
		pickup_audio.play()
