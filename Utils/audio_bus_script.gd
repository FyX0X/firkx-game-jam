@tool
extends EditorScript

func _run() -> void:
	var scene = EditorInterface.get_edited_scene_root()  # fix deprecation warning
	_set_bus(scene, "SFX", ["AudioStreamPlayer"])  # exclude by node name

func _set_bus(node: Node, bus: String, exclude_names: Array) -> void:
	if (node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D) \
	and node.name not in exclude_names:
		node.bus = bus
		print("set bus: ", node.name)
	for child in node.get_children():
		_set_bus(child, bus, exclude_names)
