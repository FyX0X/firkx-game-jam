class_name SpinReactor
extends StaticBody3D

signal spin_reactor_built
signal deposit_changed

@onready var deposit: StaticBody3D = $Deposit
@onready var inventory: Inventory = $Deposit/Inventory
@onready var computer: StaticBody3D = $Computer


@export var process_speed: float = 10.0
var progress: float = 0
@export var electricity_consumption: float = 100
@export var construction_cost: Dictionary = {
	"iron" : 100,
	"titanium" : 80,
	"silicium" : 60,
	"tungsten" : 50
}
var deposited: Dictionary = {
	"iron" : 0,
	"titanium" : 0,
	"silicium" : 0,
	"tungsten" : 0
}

var is_built: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if inventory.is_empty():
		return
		
	progress += process_speed * delta
	if (progress >= 1):
		_consume_item()
		progress = 0
	
	if _get_missing_materials().is_empty() and not is_built:
		spin_reactor_built.emit()
		is_built = true
		print("spin reactor is built : electricity not yet implemented")

func _consume_item() -> void:
	# if Audioscience and not Audioscience.playing:
	# 	Audioscience.play()
	
	var allowed_items: Array = construction_cost.keys()
	
	for item in _get_missing_materials():
		if inventory.has_item(item):
			inventory.remove_item(item, 1)
			deposited[item] += 1
			deposit_changed.emit()
			return

func _get_missing_materials() -> Array:
	
	var allowed_items: Array = construction_cost.keys()
	var missing: Array = []
	for item in allowed_items:
		if deposited[item] < construction_cost[item]:
			missing.append(item)
	return missing
	
