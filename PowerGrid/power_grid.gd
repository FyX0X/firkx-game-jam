class_name PowerGrid
extends RefCounted

var grid_id : int 
var energy : int = 0

var demand: int = 0
var production: int = 0
var operational: bool = false

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
	assert(energy == (production - demand))
	operational = energy >= 0
	for building in connected_buildings:
		building.set_powered(operational)

func get_power_grid_info_string() -> String:
	var info: String = "Power Grid Status : "
	info += "Operational" if operational else "Underpowered"
	info += " (%d/%d)" % [demand, production]
	return info
