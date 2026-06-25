extends Control

@onready var master_volume_slider: HSlider = $VBoxContainer/VolumeSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	master_volume_slider.value = GameSettings.get_master_volume()

func _on_volume_slider_value_changed(value: float) -> void:
	GameSettings.set_master_volume(value)


func _on_exit_button_pressed() -> void:
	hide()
