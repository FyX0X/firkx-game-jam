class_name DamageZone
extends Area3D

@export var damage_per_second: float = 20.0
@export var grace_period: float = 5

@export var zone_type: Type = Type.HOT
@export var biome_name: String = "biome name"
@export var biome_description: String = "biome description"

enum Type{
	HOT,
	COLD
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	print(str(self))
	print("entered by : " + str(body))
	if body is Player:
		body.enter_zone(self)
	else: # should never happen since checks on layer 2 = Player
		print(self, "Unexepected Body entry was not player")

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.exit_zone(self)
