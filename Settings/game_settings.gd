extends Node

var challenge_mode: bool = false
var _master_volume: float = 1

func get_master_volume() -> float:
	return _master_volume

func set_master_volume(value: float) -> void:
	_master_volume = value
	_apply_audio()

func _apply_audio():
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(_master_volume)
	)
