class_name Building
extends StaticBody3D

var health : int
var process_speed : float = 0.5 #base_speed
var buffer : float = 0.0
var cost : Dictionary
@onready var inventory : Inventory = $Inventory


@onready var model: MeshInstance3D = $MeshInstance3D
@onready var collision_shape : CollisionShape3D = $CollisionShape3D
@onready var clipping_hitbox: Area3D = $ClippingHitbox
@onready var floating_hitbox: Area3D = $FloatingHitbox

var red_material: Material = preload("res://assets/Material/red.tres")
var blue_material: Material = preload("res://assets/Material/blue.tres")

var can_place: bool = false
var is_hologram: bool = false

func is_placeable():
	return clipping_hitbox.get_overlapping_bodies().is_empty() and not floating_hitbox.get_overlapping_bodies().is_empty()
	

func _process(_delta: float) -> void:
	# Uniquement actif pendant le mode hologramme
	if not is_hologram:
		return
	can_place = is_placeable()
	model.material_override = blue_material if can_place else red_material

func set_hologram_mode(enabled: bool) -> void:
	is_hologram = enabled
	collision_shape.disabled = enabled
	clipping_hitbox.monitoring = enabled
	floating_hitbox.monitoring = enabled

func place() -> void:
	set_hologram_mode(false)
	model.material_override = null
	clipping_hitbox.queue_free()
	floating_hitbox.queue_free()
	
func get_inventory() -> Inventory:
	return inventory;


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
