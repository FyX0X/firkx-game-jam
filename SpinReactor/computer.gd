extends StaticBody3D

signal spin_reactor_open_ui

@onready var attetion: AttentionGrabber = $AttentionGrabber
var already_interacted: bool = false

func interact(player: Player) -> void:
	spin_reactor_open_ui.emit()
	if not already_interacted:
		already_interacted = true
		attetion.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
