@tool
extends ResourceImporterScene

func _post_import(scene : Node):
	var bigs : Array[Node] = scene.find_children("Big*","",true,false)
	var veins : Array[Node] = scene.find_children("Vein*","",true,false)
	
	var big_scene = preload("res://Props/BigOre/big_ore.tscn")
	var vein_scene = preload("res://Props/OreVein/ore_vein.tscn")
	
	if not bigs :
		push_error("No big nodes found !")
	if not veins:
		push_error("No veins nodes found")
	for big in bigs:
		var type = big.name.substr(4)
		print(type)
		
		var new_big = big_scene.instantiate()
		new_big.transform = big.transform
		
		var parent = big.get_parent()
		parent.remove_child(big)
		parent.add_child(new_big)
		new_big.owner = scene
		
		new_big.add_child(big)
		big.transform = Transform3D.IDENTITY
		big.owner = scene
		
		var collision_node = CollisionShape3D.new()
		collision_node.shape = big.mesh.create_convex_shape(true,true)
		new_big.add_child(collision_node)
		collision_node.owner = scene
	
	for vein in veins:
		var type = vein.name.substr(4)
		print(type)
		
		var new_vein = vein_scene.instantiate()
		new_vein.transform = vein.transform
		
		var parent = vein.get_parent()
		parent.remove_child(vein)
		parent.add_child(new_vein)
		new_vein.owner = scene
		
		new_vein.add_child(vein)
		vein.transform = Transform3D.IDENTITY
		vein.owner = scene
		
		var collision_node = CollisionShape3D.new()
		collision_node.shape = vein.mesh.create_convex_shape(true,true)
		new_vein.add_child(collision_node)
		collision_node.owner = scene
	
	for node in scene.get_children(true):
		if node.name.substr(0,2) != "Big" and node.name.substr(0,3) != "Vein":
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
