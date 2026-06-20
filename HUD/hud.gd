extends CanvasLayer

@onready var popup_message: Label = $PopupMessage
@onready var popup_timer: Timer = $PopupMessage/PopupTimer 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_popup_message()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_popup_message(message: String, time: float = -1) -> void:
	popup_message.text = message
	if (time > 0):
		popup_timer.start(time)
		

func clear_popup_message() -> void:
	popup_message.text = ""
