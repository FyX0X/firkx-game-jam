class_name Building
extends StaticBody3D

@export var max_health: float = 100
@export var regen: float = 2
@export var is_breakable: bool = true
var health : float
var process_speed : float = 0.5 #base_speed
var buffer : float = 0.0
@export var cost : Dictionary = {}
@onready var inventory : Inventory = $Inventory

@onready var model : Node3D = $Mesh
@onready var collision_shape : Array[CollisionShape3D]
@onready var clipping_hitbox: Area3D = $ClippingHitbox
@onready var floating_hitbox: Area3D = $FloatingHitbox

var red_material: Material = preload("res://assets/Material/red_holo.tres")
var blue_material: Material = preload("res://assets/Material/blue_holo.tres")
var orange_material : Material = preload("res://assets/Material/orange_holo.tres")

var green_elec : Material = preload("res://assets/Material/green_elec.tres")
var red_elec : Material = preload("res://assets/Material/red_elec.tres")

var can_place: bool = false
var is_hologram: bool = false

@export var energy : int = 0
var is_powered : bool = true
var current_grid : PowerGrid = null
var connected_cables : Array[Node3D] = []

func is_placed() -> bool:
	return not is_hologram

func is_not_clipping():
	return clipping_hitbox.get_overlapping_bodies().is_empty() and not floating_hitbox.get_overlapping_bodies().is_empty()

func _ready() -> void:
	health = max_health
	print(health)
	for child in get_children():
		if child is CollisionShape3D:
			collision_shape.append(child)
	
	if is_breakable:
		add_to_group("breakable")

func _process(delta: float) -> void:
	health = minf(health + delta * regen, max_health)
	# Uniquement actif pendant le mode hologramme
	if not is_hologram:
		return
	can_place = get_parent().get_node("Placement").is_placeable(self)
	var science = get_parent().get_node("Placement")._enough_science(self)
	var ressources = get_parent().get_node("Placement").has_enough_resources()
	if not can_place:
		_override_mat(model, red_material)
	elif not science or not ressources:
		_override_mat(model, orange_material)
	else:
		_override_mat(model, blue_material)

func set_hologram_mode(enabled: bool) -> void:
	is_hologram = enabled
	for collision in collision_shape:
		collision.disabled = enabled
	clipping_hitbox.monitoring = enabled
	floating_hitbox.monitoring = enabled

func _override_mat(node : Node3D, mat : Material) -> void:
	if node == null:
		return
	if node is MeshInstance3D:
		node.material_override = mat
		if (mat != red_material and mat != blue_material):
			print("Application du mat: ", mat, " sur le node: ", node.name)
	for child in node.get_children():
		if child is Node3D:
			_override_mat(child,mat)

func place() -> void:
	set_hologram_mode(false)
	_override_mat(model, null)
	clipping_hitbox.queue_free()
	floating_hitbox.queue_free()
	current_grid = PowerManager.create_new_grid()
	current_grid.add_building(self)
	PowerManager.connection(self)
	
func get_inventory() -> Inventory:
	return inventory;

func set_powered(powered : bool) -> void:
	if is_hologram:
		return
	print("Is powered : " + str(powered))
	is_powered = powered
	var light = self.find_child("Light", true, false)
	if light:
		print("Light found")
		if is_powered:
			_override_mat(light, green_elec)
		else:
			_override_mat(light, red_elec)

func _on_destroyed(player_inventory : Inventory) -> void :
	for item in inventory.get_all_items():
		player_inventory.add_item(item, inventory.get_all_items()[item])
	for item in cost :
		player_inventory.add_item(item, cost[item])
	print("Batiment detruit")
	if self.is_in_group("electrical"):
		PowerManager.remove_building(self)
	queue_free()

func take_damage(damage : float, player_inventory : Inventory):
	if not is_breakable:
		return
	health -= damage
	if health <= 0:
		_on_destroyed(player_inventory)
	#print("Building Damaged " + str(health))

func set_speed(new_speed : float):
	process_speed = new_speed
