extends Control

@onready var difficulty_selector: OptionButton = $VBoxContainer/DifficulySelector
@onready var settings_menu: Control = $SettingsMenu
@onready var instructions: Control = $InstructionsUI
@onready var credits_menu: Control = $Credits
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_populate_difficulty()
	settings_menu.hide()
	instructions.hide()
	credits_menu.hide()


func _populate_difficulty() -> void:
	difficulty_selector.clear()
	
	for difficulty in GameSettings.Difficulty.keys():
		# Capitalize the string nicely for the UI (e.g., "Warrior")
		var display_name = difficulty.capitalize() 
		
		# Get the corresponding integer value of the enum
		var enum_value = GameSettings.Difficulty[difficulty]
		
		# Add the item to the dropdown, using the enum value as its ID
		difficulty_selector.add_item(display_name, enum_value)
	difficulty_selector.select(GameSettings.difficulty)
	

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_options_button_pressed() -> void:
	settings_menu.show()

func _on_instruction_button_pressed() -> void:
	instructions.show()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_difficuly_selector_item_selected(index: int) -> void:
	# Get the ID of the selected item, which matches our enum value
	var selected_id = difficulty_selector.get_item_id(index)
	
	# Cast it back to the enum type
	var difficulty: GameSettings.Difficulty = selected_id as GameSettings.Difficulty
	GameSettings.difficulty = difficulty


func _on_credits_button_pressed() -> void:
	credits_menu.show()
