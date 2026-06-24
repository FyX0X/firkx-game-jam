extends StaticBody3D

var spin_reactor: SpinReactor
@onready var inventory: Inventory = $Inventory

@onready var attention_grabber: AttentionGrabber = $AttentionGrabber
var already_interacted: bool = false

func get_inventory() -> Inventory:
	if not already_interacted:
		already_interacted = true
		attention_grabber.queue_free()
	return inventory

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
