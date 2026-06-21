class_name LootBag
extends BaseProp

@onready var inventory: Inventory = $Inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_inventory() -> Inventory:
	return inventory
