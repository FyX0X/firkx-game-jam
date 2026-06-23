extends Node

var grids : Array[PowerGrid] = []
var next_grid_id : int = 0
const max_distance : float = 20 #distance max d'auto connexion auw grids

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_new_grid() -> PowerGrid:
	var new_grid = PowerGrid.new(next_grid_id)
	print(new_grid)
	next_grid_id += 1
	grids.append(new_grid)
	return new_grid

func merge_grids(grids_to_merge : Array):
	if grids_to_merge.size() <= 1:
		return
	var sub_array = grids_to_merge.slice(1)
	for grid in sub_array :
		for building in grid.connected_buildings:
			grids_to_merge[0].add_building(building)
		grids.erase(grid)

func connection(new_building: Building) -> void:
	var best_per_grid : Dictionary = {}
	
	var all_nodes = get_tree().get_nodes_in_group("electrical")
	var pos_new = get_hook(new_building)
	
	for node : Building in all_nodes:
		if node == new_building or node.is_hologram:
			continue
		print(node, new_building)
		var pos_b = get_hook(node)
		var dist = pos_new.distance_to(pos_b)
		
		if dist <= max_distance:
			var score = max_distance - dist
			if node is Pole:
				score += 100.0 #nombre sans sigification doit etre plus grand que max_distance
			var target_grid_id = node.current_grid.grid_id
			
			if not best_per_grid.has(target_grid_id) or score > best_per_grid[target_grid_id]["score"]:
				best_per_grid[target_grid_id] = { "node": node, "score": score }
	for target_data in best_per_grid.values():
		var target_node = target_data["node"]
		if new_building.current_grid == target_node.current_grid:
			continue
		var array = [new_building.current_grid,target_node.current_grid]
		merge_grids(array)
		create_visual_cable(new_building, target_node)
			

func get_hook(building: Building) -> Vector3:
	if building.has_node("Mesh") and building.get_node("Mesh").has_node("ElectricalHook"):
		return building.get_node("Mesh").get_node("ElectricalHook").global_position
	return building.global_position

func create_visual_cable(node_a: Building, node_b: Building, preview : bool = false, preview_cables : Array[MeshInstance3D] = []) -> void:
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.05
	cylinder_mesh.bottom_radius = 0.05
	
	var pos_a = get_hook(node_a)
	var pos_b = get_hook(node_b)
	
	var dist = pos_a.distance_to(pos_b)
	cylinder_mesh.height = dist
	mesh_instance.mesh = cylinder_mesh
	
	if preview :
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.2, 0.6, 1.0, 0.5)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mesh_instance.material_override = mat
	
	get_tree().current_scene.add_child(mesh_instance)
	
	var mid_point = (pos_a + pos_b) / 2.0
	mesh_instance.global_position = mid_point
	
	var up_vector = Vector3.UP
	if abs(pos_a.x - pos_b.x) < 0.001 and abs(pos_a.z - pos_b.z) < 0.001:
		up_vector = Vector3.FORWARD
		
	mesh_instance.look_at(pos_b, up_vector)
	
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI/2.0)
	if not preview :
		node_a.connected_cables.append(mesh_instance)
		node_b.connected_cables.append(mesh_instance)
	else:
		preview_cables.append(mesh_instance)

func remove_building(building_to_remove: Building) -> void:
	building_to_remove.remove_from_group("electrical")
	var old_grid = building_to_remove.current_grid
	if old_grid == null:
		return
	
	old_grid.connected_buildings.erase(building_to_remove)
	
	for cable in building_to_remove.connected_cables:
		if is_instance_valid(cable):
			cable.queue_free()
	building_to_remove.connected_cables.clear()
	
	if old_grid.connected_buildings.size() == 0:
		grids.erase(old_grid)
		return
		
	var surviving_buildings = old_grid.connected_buildings.duplicate()
	
	grids.erase(old_grid)
	
	for b in surviving_buildings:
		for cable in b.connected_cables:
			if is_instance_valid(cable):
				cable.queue_free()
		b.connected_cables.clear()
		b.current_grid = create_new_grid()
		b.current_grid.add_building(b)
	for b in surviving_buildings:
		connection(b)
