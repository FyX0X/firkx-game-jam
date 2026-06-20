extends Building

@export var recipe : Dictionary ={} #ie my_recipe = {"input" : {ITEMS}, "output" : {ITEMS}, "time" : FLOAT}
var inputs : Dictionary
var outputs : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _can_process():
		buffer += delta * process_speed
		if (buffer >= recipe["time"]):
			_finish_processing()

func _can_process() -> bool:
	for item in recipe["input"]:
		var amount_needed = recipe["input"][item]
		if not inventory.get_all_items().has(item) or inventory.get_all_items()[item] < amount_needed:
			return false
	return true

func _finish_processing() -> void:
	for item in recipe["input"]:
		inventory.remove([item], recipe["input"][item])
	
	for item in recipe["output"]:
		inventory.add_item(item, recipe["output"][item])
	buffer -= recipe["time"]
