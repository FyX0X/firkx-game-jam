class_name Placement
extends Node3D

signal building_placed(building: Building)
signal win_triggered
var win_sent: bool = false

@onready var camera: Camera3D = get_parent().get_node("SpringArm3D/Camera3D")
@onready var ray: RayCast3D = get_parent().get_node("SpringArm3D/Camera3D/RayCast3D")

var building_mode: bool = false
var hologram: Building = null
var current_object_index: int = 0
var grid_size: float = 0.1

var objects: Array[PackedScene] = []

var red_material: Material = preload("res://assets/Material/red.tres")
var blue_material: Material = preload("res://assets/Material/blue.tres")


func _ready() -> void:
	objects.append(preload("res://Buildings/Drills/drill.tscn"))
	objects.append(preload("res://Buildings/Factory/factory.tscn"))
	objects.append(preload("res://Buildings/Science/science_table.tscn"))
	objects.append(preload("res://Buildings/Science/research_table.tscn"))
	objects.append(preload("res://Buildings/SpinReactor/spin_reactor.tscn"))


func _process(_delta: float) -> void:
	if not building_mode or objects.is_empty():
		return

	if hologram == null:
		spawn_hologram()
		return

	_update_hologram()

func is_placeable(hologram : Building):
	if hologram == null:
		return
	var location : bool = true
	if  (hologram is Drill and not ray.get_collider() is BigOre):
		location = false
	if (hologram is not Drill and ray.get_collider() and not ray.get_collider().is_in_group("ground")):
		location = false
	var ressources : bool = has_enough_resources()
	print(ray.get_collider())
	return hologram.is_not_clipping() and location and ressources

func _update_hologram() -> void:
	if ray.is_colliding():
		var snap_pos := snap_to_grid(ray.get_collision_point())
		hologram.global_position = hologram.global_position.lerp(snap_pos, 0.1)
	else:
		var snap_pos = ray.to_global(ray.target_position)
		hologram.global_position = hologram.global_position.lerp(snap_pos, 0.1)

	#if Input.is_action_just_pressed("rotate"):
		#hologram.rotation.y += deg_to_rad(90)

	if Input.is_action_just_pressed("attack") and is_placeable(hologram):
		_place_building()


func has_enough_resources() -> bool:
	if hologram == null:
		return false
	var inventory = get_parent().get_node("Inventory")
	for item in hologram.cost:
		if not inventory.has_item(item, hologram.cost[item]):
			return false
	return true


func _place_building() -> void:
	print("tried placing building")
	var instance: Building = objects[current_object_index].instantiate()
	
	get_parent().get_parent().add_child(instance)
	
	instance.global_position = snap_to_grid(hologram.global_position)
	instance.global_rotation = hologram.global_rotation
	
	instance.place()
	building_placed.emit(instance)
	if instance.is_in_group("win_condition") and not win_sent:
		win_sent = true
		win_triggered.emit()
	
	hologram.queue_free()
	print(hologram)
	hologram = null
	print(hologram)



func spawn_hologram() -> void:
	hologram = objects[current_object_index].instantiate()
	get_parent().add_child(hologram)
	hologram.global_position = ray.get_collision_point()
	hologram.set_hologram_mode(true)


func object_change(direction: int) -> void:
	if hologram:
		hologram.queue_free()
		hologram = null
	current_object_index = posmod(current_object_index + direction, objects.size())
	print(current_object_index)
	spawn_hologram()


func snap_to_grid(position: Vector3) -> Vector3:
	return Vector3(
		round(position.x / grid_size) * grid_size,
		round(position.y / grid_size) * grid_size,
		round(position.z / grid_size) * grid_size
	)

func clear_hologram() -> void:
	if hologram:
		hologram.queue_free()
		hologram = null
