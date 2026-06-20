class_name BaseProp
extends StaticBody3D


@export var display_name: String = "Unknown"
@export var health: float = 100.0
@export var interact_label: String = "Interact"
@export var respawn_time: float = 30.0
@export var loot_table: Resource  # your custom LootTable resource

signal interacted(player)
signal destroyed

func interact(player) -> void:
	interacted.emit(player)

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		_on_destroyed()

func _on_destroyed() -> void:
	destroyed.emit()
	# spawn loot, play VFX, hide mesh, start respawn timer
	queue_free()
	
