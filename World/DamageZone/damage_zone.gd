class_name DamageZone
extends Area3D

@export var damage_per_second: float = 20.0
@export var zone_type: String = "desert"  # just a label for UI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.enter_zone(self)

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.exit_zone(self)
