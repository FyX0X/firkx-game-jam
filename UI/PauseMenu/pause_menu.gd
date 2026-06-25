class_name PauseMenu
extends Control

signal unpaused

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_button_pressed() -> void:
	_unpause()


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_unpause()

func _unpause() -> void:
	hide()
	unpaused.emit()
