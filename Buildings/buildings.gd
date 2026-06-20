class_name Building
extends StaticBody3D

var size : float;
var process_speed : float;
var buffer : float;
var cost : Dictionary;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buffer = 0.0
	pass # Replace with function body.


func _on_interact() -> void:
	#self.open_inventory();
	pass

func _on_destroyed() -> void :
	pass
