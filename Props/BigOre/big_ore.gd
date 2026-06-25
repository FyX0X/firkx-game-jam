@tool #Dont touch it is for the map import
class_name BigOre
extends Ore

## Do not assign onready in this file use the ready function !!

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set parent class mesh instance
	mesh_instance = $Big/Big_Copper
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
