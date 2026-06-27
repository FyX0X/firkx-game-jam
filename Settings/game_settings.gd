extends Node

enum Difficulty {
	EASY,
	NORMAL,
	HARDCORE
}

const time_limit: Dictionary = {
	Difficulty.EASY: -1,
	Difficulty.NORMAL: 600,
	Difficulty.HARDCORE: 400
}
const hologram_msg: Dictionary = {
	Difficulty.EASY: "Please proceed to activate the spin reactor.",
	Difficulty.NORMAL: "Please proceed to activate the spin reactor. Corporate doesn't like to wait.",
	Difficulty.HARDCORE: "Please proceed to activate the spin reactor. Do NOT disapoint corporate."
}

var difficulty: Difficulty = Difficulty.NORMAL
var _master_volume: float = 1
var _music_volume: float = 0.25
var _sfx_volume: float = 1

var crosshair_enabled: bool = false

func _ready() -> void:
	_apply_audio()

func get_master_volume() -> float:
	return _master_volume

func set_master_volume(value: float) -> void:
	_master_volume = value
	_apply_audio()

func get_music_volume() -> float:
	return _music_volume

func set_music_volume(value: float) -> void:
	_music_volume = value
	_apply_audio()

func get_sfx_volume() -> float:
	return _sfx_volume

func set_sfx_volume(value: float) -> void:
	_sfx_volume = value
	_apply_audio()

func set_crosshair(toggled_on: bool) -> void:
	crosshair_enabled = toggled_on
	var crosshair: ColorRect = get_tree().get_first_node_in_group("crosshair")
	if crosshair:
		crosshair.visible = crosshair_enabled

func _apply_audio():
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(_master_volume)
	)
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(_music_volume)
	)
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(_sfx_volume)
	)
