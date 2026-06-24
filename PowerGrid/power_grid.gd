class_name PowerGrid
extends RefCounted

var grid_id : int 
var energy : int = 0

var demand: int = 0
var production: int = 0

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
	production = 0
	demand = 0
	for building in connected_buildings:
		energy += building.energy
		production += maxi(building.energy, 0)
		demand += maxi(-building.energy, 0)
	print("energy: %d, demand: %d, production: %d" % [energy, demand, production])
	assert(energy == (production - demand))
	var powered = energy >= 0
	for building in connected_buildings:
		building.set_powered(powered)
