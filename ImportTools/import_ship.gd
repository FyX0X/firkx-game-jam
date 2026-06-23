@tool
extends EditorScenePostImport

func _post_import(scene):
	var science_table : MeshInstance3D = scene.find_child("ScienceTable", true, false)
	var research_table : MeshInstance3D= scene.find_child("ResearchTable", true, false)
	
	if science_table :
		var science_scene = preload("res://Buildings/Science/science_table.tscn")
		var new_science = science_scene.instantiate()
		new_science.add_child(science_table)
		science_table.owner = scene
		
		var collision_node = CollisionShape3D.new()
		collision_node.shape = science_table.mesh.create_convex_shape(true,true)
		collision_node.owner = new_science
		
		var parent = science_table.get_parent()
		parent.add_child(new_science)
		
		var research_scene = preload("res://Buildings/Science/research_table.tscn")
		var new_research = research_scene.instantiate()
		new_research.add_child(research_table)
		research_table.owner = scene
		
		var collision_node1 = CollisionShape3D.new()
		collision_node1.shape = research_table.mesh.create_convex_shape(true,true)
		collision_node1.owner = new_research
		
		var parent1 = research_table.get_parent()
		parent1.add_child(new_research)
		
	return scene
