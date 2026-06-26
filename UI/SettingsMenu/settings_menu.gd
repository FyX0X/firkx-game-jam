extends Control

@onready var master_volume_slider: HSlider = $VBoxContainer/MasterSlider
@onready var music_volume_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sfx_volume_slider: HSlider = $VBoxContainer/SFXSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	master_volume_slider.value = GameSettings.get_master_volume()
	music_volume_slider.value = GameSettings.get_music_volume()
	sfx_volume_slider.value = GameSettings.get_sfx_volume()


func _on_exit_button_pressed() -> void:
	hide()


func _on_master_slider_value_changed(value: float) -> void:
	GameSettings.set_master_volume(value)


func _on_music_slider_value_changed(value: float) -> void:
	GameSettings.set_music_volume(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	GameSettings.set_sfx_volume(value)
