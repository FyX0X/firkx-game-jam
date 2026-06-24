class_name PowerGrid
extends RefCounted

var grid_id : int 
var energy : int = 0

var connected_buildings : Array[Node3D] = []

func _init(id : int):
	grid_id = id

func add_building(building : Node3D):
	if not connected_buildings.has(building):
		connected_buildings.append(building)
		building.current_grid = self
		_recalculate_power()

func _recalculate_power():
	energy = 0
	for building in connected_buildings:
		energy += building.energy
	var powered = energy > 0
	for building in connected_buildings:
		building.set_powered(powered)
