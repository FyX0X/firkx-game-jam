class_name Building
extends StaticBody3D


var health : int
var process_speed : float = 0.5 #base_speed
var buffer : float = 0.0
var cost : Dictionary
@onready var inventory : Inventory = $Inventory



func _on_interact() -> void:
	inventory.show()

func _on_destroyed(player_inventory : Inventory) -> void :
	for item in inventory.get_all_items():
		player_inventory.add_item(item, inventory.get_all_items()[item])
	for item in cost :
		player_inventory.add_item(item, cost[item])
	print("Batiment detruit")
	queue_free()

func _on_hit(damage : int, player_inventory : Inventory):
	health -= damage
	if health <= 0:
		_on_destroyed(player_inventory)
	print("Building Damaged " + str(health))

func set_speed(new_speed : float):
	process_speed = new_speed
