class_name EndScene
extends Control

@onready var end_sound_player: AudioStreamPlayer = $EndSound
@onready var cinematic_player: VideoStreamPlayer = $CinematicPlayer

@export var title: String = "You Win !"
@export var quit_button_text: String = "Quit"
@export var cinematic: VideoStreamTheora = null
@export var sound: AudioStream = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(cinematic != null)
	assert(sound != null)
	cinematic_player.stream = cinematic
	end_sound_player.stream = sound
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	cinematic_player.show()
	


func _on_failed_video_finished() -> void:
	cinematic_player.hide()
	end_sound_player.play()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/MainMenu/main_menu.tscn")


func _on_rage_quit_button_pressed() -> void:
	get_tree().quit()
