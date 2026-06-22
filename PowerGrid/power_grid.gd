class_name PowerGrid
extends RefCounted

var grid_id : int 
var energy : int = 0

var connected_buildings : Array[Building] = []

func _init(id : int):
	grid_id = id

func add_building(building : Building):
	if not connected_buildings.has(building):
		connected_buildings.append(building)
		building.current_grid = self
		_recalculate_power()

func _recalculate_power():
	energy = 0
	for building in connected_buildings:
		energy += building.energy
	var powered = energy >= 0
	for building in connected_buildings:
		building.set_powered(powered)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
