extends Node

enum Difficulty {
	EASY,
	NORMAL,
	HARDCORE
}

const time_limit: Dictionary = {
	Difficulty.EASY: -1,
	Difficulty.NORMAL: 600,
	Difficulty.HARDCORE: 300
}
const hologram_msg: Dictionary = {
	Difficulty.EASY: "Please proceed to activate the spin reactor.",
	Difficulty.NORMAL: "Please proceed to activate the spin reactor. Corporate doesn't like to wait.",
	Difficulty.HARDCORE: "Please proceed to activate the spin reactor. Do NOT disapoint corporate."
}

var difficulty: Difficulty = Difficulty.NORMAL
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
