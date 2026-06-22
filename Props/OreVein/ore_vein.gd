class_name OreVein
extends Ore

signal resource_yielded(ore_type: Ore.OreType, amount: int)

@export var total_yield: int = 8

var remaining_yield: int

func _ready() -> void:
	super()
	remaining_yield = total_yield
	add_to_group("minable")

func yield_resource() -> void:
	if remaining_yield <= 0:
		return
	remaining_yield -= 1
	resource_yielded.emit(_get_string(type), 1)
	if remaining_yield <= 0:
		_deplete()

func _deplete() -> void:
	# override to do something before freeing
	print("Vein exhausted")
	super()
