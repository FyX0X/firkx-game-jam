extends StaticBody3D

var spin_reactor: SpinReactor
@onready var inventory: Inventory = $Inventory

@onready var attetion: AttentionGrabber = $AttentionGrabber
var already_interacted: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func get_inventory() -> Inventory:
	if not already_interacted:
		already_interacted = true
		attetion.queue_free()
	return inventory
