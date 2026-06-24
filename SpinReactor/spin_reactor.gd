class_name SpinReactor
extends StaticBody3D

signal spin_reactor_built
signal deposit_changed
signal powered_changed

@onready var deposit: StaticBody3D = $Deposit
@onready var inventory: Inventory = $Deposit/Inventory
@onready var computer: StaticBody3D = $Computer


@export var process_speed: float = 10.0
var progress: float = 0
@export var construction_cost: Dictionary = {
	"iron" : 100,
	"titanium" : 80,
	"copper" : 60,
	"tungsten" : 50
}
var deposited: Dictionary = {
	"iron" : 0,
	"titanium" : 0,
	"copper" : 0,
	"tungsten" : 0
}
@export var electricity_consumption: float = 100
@export var energy : int = -10
var is_powered : bool = false
var current_grid : PowerGrid = null
var connected_cables : Array[Node3D] = []

var has_material: bool = false
var is_complete: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_grid = PowerManager.create_new_grid()
	current_grid.add_building(self)
	PowerManager.connection(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if inventory.is_empty():
		return
		
	progress += process_speed * delta
	if (progress >= 1):
		_consume_item()
		progress = 0
	
	if has_material and is_powered and not is_complete:
		is_complete = true
		spin_reactor_built.emit()
		print("spin reactor is complete : electricity not yet implemented")

func _consume_item() -> void:
	# if Audioscience and not Audioscience.playing:
	# 	Audioscience.play()
	
	var allowed_items: Array = construction_cost.keys()
	
	for item in _get_missing_materials():
		if inventory.has_item(item):
			inventory.remove_item(item, 1)
			deposited[item] += 1
			deposit_changed.emit()
			_update_material()
			return

func _get_missing_materials() -> Array:
	
	var allowed_items: Array = construction_cost.keys()
	var missing: Array = []
	for item in allowed_items:
		if deposited[item] < construction_cost[item]:
			missing.append(item)
	return missing

func _update_material() -> void:
	has_material = _get_missing_materials().is_empty()



func set_powered(powered : bool) -> void:

	print("spin_reactor: Is powered : " + str(powered))
	is_powered = powered
	powered_changed.emit()
	var light = self.find_child("Light", true, false)
	if light:
		print("Light found")
		if is_powered:
			print("spin reactor: set powered WIP")
			# _override_mat(light, green_elec)
		else:
			print("spin reactor: set powered WIP")
			# _override_mat(light, red_elec)
