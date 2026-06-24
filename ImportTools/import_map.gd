@tool
extends EditorScenePostImport

func _post_import(scene : Node):
	var bigs : Array[Node] = scene.find_children("Big*","",true,false)
	var veins : Array[Node] = scene.find_children("Vein*","",true,false)
	
	var big_scene = preload("res://Props/BigOre/big_ore.tscn")
	var vein_scene = preload("res://Props/OreVein/ore_vein.tscn")
	
	var regex = RegEx.new()
	regex.compile("[0-9_]")
	
	if not bigs :
		push_error("No big nodes found !")
	if not veins:
		push_error("No veins nodes found")
	for big in bigs:
		if big is not MeshInstance3D:
			continue
		var type = regex.sub(big.name.substr(4),"",true)
		print(type)
		
		var new_big = big_scene.instantiate()
		new_big.transform = big.transform
		
		var string = type.to_lower()
		
		new_big._set_type(string)
		
		var parent = big.get_parent()
		parent.remove_child(big)
		big.owner = null
		parent.add_child(new_big)
		new_big.owner = scene
		
		new_big.add_child(big)
		big.transform = Transform3D.IDENTITY
		big.owner = scene
		
		var collision_node = CollisionShape3D.new()
		collision_node.shape = big.mesh.create_trimesh_shape()
		new_big.add_child(collision_node)
		collision_node.owner = scene
	
	for vein in veins:
		if vein is not MeshInstance3D:
			continue
		var type = regex.sub(vein.name.substr(5),"",true)
		print(type)
		
		var new_vein = vein_scene.instantiate()
		new_vein.transform = vein.transform
		
		var string = type.to_lower()
		new_vein._set_type(string)
		
		var parent = vein.get_parent()
		parent.remove_child(vein)
		vein.owner = null
		parent.add_child(new_vein)
		new_vein.owner = scene
		
		new_vein.add_child(vein)
		vein.transform = Transform3D.IDENTITY
		vein.owner = scene
		
		var collision_node = CollisionShape3D.new()
		collision_node.shape = vein.mesh.create_trimesh_shape()
		new_vein.add_child(collision_node)
		collision_node.owner = scene
	
	for node in scene.get_children(true):
		if not node.name.begins_with("Big") and not node.name.begins_with("Vein"):
			_add_collisions(node,scene)
	return scene

func _add_collisions(node : Node, scene : Node):
	if node is MeshInstance3D and node.mesh != null:
		var corps = StaticBody3D.new()
		node.add_child(corps)
		corps.owner = scene
		
		var collision = CollisionShape3D.new()
		collision.shape = node.mesh.create_trimesh_shape()
		corps.add_child(collision)
		collision.owner = scene
