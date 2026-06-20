class_name Building
extends StaticBody3D


var health : int
var process_speed : float
var buffer : float
var cost : Dictionary
var inventory : Inventory


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buffer = 0.0
	inventory = $Inventory


func _on_interact() -> void:
	inventory.show()
	pass

func _on_destroyed(player_inventory : Inventory) -> void :
	for item in inventory.get_all_items():
		player_inventory.add_item(item, inventory.get_all_items()[item])
	for item in cost :
		player_inventory.add_item(item, cost[item])
	print("Batiment detruit")
	queue_free()
