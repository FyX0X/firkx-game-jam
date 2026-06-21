class_name HUD
extends CanvasLayer

@onready var popup_message: Label = $PopupMessage
@onready var popup_timer: Timer = $PopupMessage/PopupTimer 
@onready var cinematic_player: VideoStreamPlayer = $CinematicPlayer
@onready var debug_panel: Control = $DebugPanel
@onready var inventory_hud: Control = $InventoryHUD

var intro_video: VideoStreamTheora
var outro_video: VideoStreamTheora
var _is_intro: bool = true
var end_callable: Callable = Callable()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_popup_message()
	intro_video = preload("res://assets/video/gamejam_animation_debut.ogv")
	outro_video = preload("res://assets/video/gamejam_animation_outro.ogv")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_cinematic(is_intro: bool, end_observer: Callable) -> void:
	_is_intro = is_intro
	popup_message.hide()
	inventory_hud.hide()
	debug_panel.hide()
	cinematic_player.show()
	if is_intro:
		cinematic_player.stream = intro_video
	else:
		cinematic_player.stream = outro_video
	cinematic_player.play()
	end_callable = end_observer
	
func skip_intro() -> void:
	cinematic_player.stop()
	_on_cinematic_player_finished()
	
	
func show_popup_message(message: String, time: float = -1) -> void:
	popup_message.text = message
	if (time > 0):
		popup_timer.start(time)
		

func clear_popup_message() -> void:
	popup_message.text = ""


func _on_cinematic_player_finished() -> void:
	if (end_callable.is_valid()):
		end_callable.call()
		end_callable = Callable()
	if not _is_intro:
		print("hud: _on_cinematic_player_finished: outro finished keeps video shown")
		return
	popup_message.show()
	inventory_hud.show()
	debug_panel.show()
	cinematic_player.hide()
