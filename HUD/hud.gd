class_name HUD
extends CanvasLayer

@onready var popup_message: Label = $PopupMessage
@onready var popup_timer: Timer = $PopupMessage/PopupTimer 
@onready var intro_video: VideoStreamPlayer = $IntroVideo
@onready var debug_panel: Control = $DebugPanel
@onready var inventory_hud: Control = $InventoryHUD

var intro_end_callable: Callable = Callable()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_popup_message()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_intro_cinematic(end_observer: Callable) -> void:
	popup_message.hide()
	inventory_hud.hide()
	debug_panel.hide()
	intro_video.show()
	intro_video.play()
	intro_end_callable = end_observer
	
func skip_intro() -> void:
	intro_video.stop()
	_on_intro_video_finished()
	
	
func show_popup_message(message: String, time: float = -1) -> void:
	popup_message.text = message
	if (time > 0):
		popup_timer.start(time)
		

func clear_popup_message() -> void:
	popup_message.text = ""


func _on_intro_video_finished() -> void:
	if (intro_end_callable.is_valid()):
		intro_end_callable.call()
		intro_end_callable = Callable()
	popup_message.show()
	inventory_hud.show()
	debug_panel.show()
	intro_video.hide()
