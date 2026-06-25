extends Control

@onready var challenge_toggle: CheckBox = $ChallengeToggle
@onready var settings_menu: Control = $SettingsMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_options_button_pressed() -> void:
	settings_menu.show()

func _on_instruction_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_challenge_toggle_toggled(toggled_on: bool) -> void:
	GameSettings.challenge_mode = toggled_on
