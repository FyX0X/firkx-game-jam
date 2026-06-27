extends Control

@onready var master_volume_slider: HSlider = $HBoxContainer/MarginContainer/Sound/MasterSlider
@onready var music_volume_slider: HSlider = $HBoxContainer/MarginContainer/Sound/MusicSlider
@onready var sfx_volume_slider: HSlider = $HBoxContainer/MarginContainer/Sound/SFXSlider
@onready var crosshair_button: CheckButton = $HBoxContainer/Accessibility/CrosshairCheckButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	master_volume_slider.value = GameSettings.get_master_volume()
	music_volume_slider.value = GameSettings.get_music_volume()
	sfx_volume_slider.value = GameSettings.get_sfx_volume()
	crosshair_button.button_pressed = GameSettings.crosshair_enabled
	


func _on_exit_button_pressed() -> void:
	hide()


func _on_master_slider_value_changed(value: float) -> void:
	GameSettings.set_master_volume(value)


func _on_music_slider_value_changed(value: float) -> void:
	GameSettings.set_music_volume(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	GameSettings.set_sfx_volume(value)


func _on_crosshair_check_button_toggled(toggled_on: bool) -> void:
	GameSettings.set_crosshair(toggled_on)
