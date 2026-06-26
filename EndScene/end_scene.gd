class_name EndScene
extends Control

@onready var end_sound_player: AudioStreamPlayer = $EndSound
@onready var title_label: Label = $Label
@onready var quit_button: Button = $VBoxContainer/QuitButton

@export var title: String = "You Win !"
@export var quit_button_text: String = "Quit"
@export var cinematic: VideoStreamTheora = null
@export var sound: AudioStream = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(sound != null)
	title_label.text = title
	quit_button.text = quit_button_text
	end_sound_player.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
