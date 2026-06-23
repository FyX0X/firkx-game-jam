@tool
extends EditorScenePostImport

func _post_import(scene):
	print("In the Import tool")
	var science_table : MeshInstance3D = scene.find_child("ScienceTable", true, false)
	var research_table : MeshInstance3D = scene.find_child("ResearchTable", true, false)
	
	if science_table :
		var science_scene = preload("res://Buildings/Science/science_table.tscn")
		var new_science = science_scene.instantiate()
		new_science.transform = science_table.transform
		
		var parent = science_table.get_parent()
		parent.remove_child(science_table)
		parent.add_child(new_science)
		new_science.owner = scene
		
		new_science.add_child(science_table)
		science_table.transform = Transform3D.IDENTITY
		science_table.owner = scene
		
		var collision_node = CollisionShape3D.new()
		collision_node.shape = science_table.mesh.create_convex_shape(true,true)
		new_science.add_child(collision_node)
		collision_node.owner = scene
	
	if research_table :
		var research_scene = preload("res://Buildings/Science/research_table.tscn")
		var new_research = research_scene.instantiate()
		new_research.transform = research_table.transform
		
		var parent = research_table.get_parent()
		parent.remove_child(research_table)
		parent.add_child(new_research)
		new_research.owner = scene
		
		new_research.add_child(research_table)
		research_table.transform = Transform3D.IDENTITY
		research_table.owner = scene
		
		var collision_node = CollisionShape3D.new()
		collision_node.shape = research_table.mesh.create_convex_shape(true,true)
		new_research.add_child(collision_node)
		collision_node.owner = scene
	
	for node in scene.get_children(true):
		if node != science_table and node != research_table:
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
