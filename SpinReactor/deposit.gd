extends StaticBody3D

var spin_reactor: SpinReactor
@onready var inventory: Inventory = $Inventory

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func get_inventory() -> Inventory:
	return inventory
