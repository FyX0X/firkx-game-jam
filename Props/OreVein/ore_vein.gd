class_name OreVein
extends BaseProp

signal resource_yielded(ore_type: String, amount: int)

@export var ore_type: String = "iron"
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
	resource_yielded.emit(ore_type, 1)
	if remaining_yield <= 0:
		_deplete()

func _deplete() -> void:
	# override to do something before freeing
	print("Vein exhausted")
	super()
