class_name AttentionGrabber
extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var bobbing_amplitude: float = 0.2
@export var bobbing_speed: float = 2
var time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	mesh.position.y = bobbing_amplitude * sin(time * bobbing_speed)
