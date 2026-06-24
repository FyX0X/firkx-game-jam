class_name Placement
extends Node3D

signal building_selection_changed(building: Building)
signal building_placed(building: Building)
var win_sent: bool = false

@onready var camera: Camera3D = get_parent().get_node("SpringArm3D/Camera3D")
@onready var ray: RayCast3D = get_parent().get_node("SpringArm3D/Camera3D/RayCast3D")
@onready var player: Player = get_parent()
var hologram: Building = null
var current_object_index: int = 0
var grid_size: float = 0.005

var objects: Array[PackedScene] = []

var red_material: Material = preload("res://assets/Material/red_holo.tres")
var blue_material: Material = preload("res://assets/Material/blue_holo.tres")

var preview_cables : Array[MeshInstance3D] = []

var hud_layer : HUD
func _ready() -> void:
	objects.append(preload("res://Buildings/Drills/drill.tscn"))
	objects.append(preload("res://Buildings/Factory/factory.tscn"))
	objects.append(preload("res://Buildings/WindTurbine/wind_turbine.tscn"))
	objects.append(preload("res://Buildings/Pole/pole.tscn"))
	
	hud_layer = get_tree().get_first_node_in_group("hud")
	
	assert(player is Player and player != null)
	assert(not objects.is_empty())

func _process(_delta: float) -> void:
	if player.get_state() != Player.State.BUILDING:
		return

	if hologram == null:
		spawn_hologram()
		return

	_update_hologram()
	_update_preview_cables()


func is_placeable(hologram : Building) -> bool:
	if hologram == null:
		return false
	var location : bool = true
	if  (hologram is Drill and not ray.get_collider() is BigOre):
		location = false
	if (hologram is not Drill and ray.get_collider() and not ray.get_collider().is_in_group("ground")):
		location = false
	var ressources : bool = has_enough_resources()
	var science = _enough_science(hologram)
	return hologram.is_not_clipping() and location and ressources and science

func _update_hologram() -> void:
	if ray.is_colliding():
		var snap_pos = snap_to_grid(ray.get_collision_point()) + Vector3(0,-0.05,0)
		hologram.global_position = hologram.global_position.lerp(snap_pos, 0.2)
	else:
		hologram.global_position = ray.to_global(ray.target_position)

	if hologram is Drill:
		_update_drill_type(hologram)

	if Input.is_action_just_pressed("attack"):
		if is_placeable(hologram):
			_place_building()
		elif not _enough_science(hologram):
			hud_layer.show_popup_message("Not enough Science Points")
		elif not has_enough_resources():
			hud_layer.show_popup_message("Not enough Resources")
	if Input.is_action_just_pressed("rotate"):
		hologram.rotate_y(deg_to_rad(90))



func _update_preview_cables() -> void:
	clear_preview_cables()
	if hologram == null or not hologram.is_in_group("electrical"):
		return
	
	var pos_new = PowerManager.get_hook(hologram)
	var all_nodes = get_tree().get_nodes_in_group("electrical")
	var best_per_grid : Dictionary = {}
	for node in all_nodes:
		if node is Building and node.is_hologram:
			continue
		var pos_b = PowerManager.get_hook(node)
		var dist = pos_new.distance_to(pos_b)
 
		if dist <= PowerManager.max_distance:
			var score = PowerManager.max_distance - dist
			if node is Pole:
				score += 100.0
			var target_grid_id = node.current_grid.grid_id
 
			if not best_per_grid.has(target_grid_id) or score > best_per_grid[target_grid_id]["score"]:
				best_per_grid[target_grid_id] = { "node": node, "score": score }
 
	for target_data in best_per_grid.values():
		PowerManager.create_visual_cable(hologram, target_data["node"], true, preview_cables)

func clear_preview_cables():
	for cable in preview_cables:
		if is_instance_valid(cable):
			cable.queue_free()
	preview_cables.clear()

func _update_drill_type(drill: Drill) -> void:
	var collider = ray.get_collider()
	if collider is not BigOre:
		return

	var ore: BigOre = collider
	var new_type: String = ""
	match ore.type:
		BigOre.OreType.IRON:      new_type = "iron"
		BigOre.OreType.TITANIUM:  new_type = "titanium"
		BigOre.OreType.TUNGSTEN:  new_type = "tungsten"
		BigOre.OreType.COPPER : new_type = "copper"
		_:
			print("Error: unknown ore type")
			return

	if drill.type == new_type:
		return  # no change, skip emit

	drill.set_type(new_type)
	building_selection_changed.emit(drill)

func has_enough_resources() -> bool:
	if hologram == null:
		return false
	var inventory = get_parent().get_node("Inventory")
	for item in hologram.cost:
		if not inventory.has_item(item, hologram.cost[item]):
			return false
	return true

func _enough_science(building: Building) -> bool:
	if building is not Drill:
		return true
	if ray.get_collider() is not BigOre:
		return false
	return player.science_points >= ScienceTable.science_needed[building.type]

func _place_building() -> void:
	print("tried placing building")
	var instance: Building = objects[current_object_index].instantiate()
	
	get_parent().get_parent().add_child(instance)
	# _enough_science(instance) done in update drill_type
	
	instance.global_position = snap_to_grid(hologram.global_position)
	instance.global_rotation = hologram.global_rotation
	
	if instance is Drill:
		_update_drill_type(instance)
	
	instance.place()
	building_placed.emit(instance)
	
	hologram.queue_free()
	hologram = null

func spawn_hologram() -> void:
	hologram = objects[current_object_index].instantiate()
	get_parent().add_child(hologram)
	hologram.global_position = ray.get_collision_point()
	hologram.set_hologram_mode(true)

func object_change(direction: int) -> void:
	if hologram:
		clear_preview_cables()
		hologram.queue_free()
		hologram = null
	current_object_index = posmod(current_object_index + direction, objects.size())
	print(current_object_index)
	spawn_hologram()
	building_selection_changed.emit(hologram)

func snap_to_grid(position: Vector3) -> Vector3:
	return Vector3(
		round(position.x / grid_size) * grid_size,
		round(position.y / grid_size) * grid_size,
		round(position.z / grid_size) * grid_size
	)

func clear_hologram() -> void:
	if hologram:
		clear_preview_cables()
		print("clear hologram")
		hologram.queue_free()
		hologram = null
