extends Building

@export var science_values : Dictionary = {
	"iron": 1
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	super._process(delta)
	if get_inventory().is_empty():
		return
		
	if is_hologram:
		return
	
	buffer += process_speed * delta
	if (buffer >= 1):
		_consume_item()
		buffer -= 1

func _consume_item() -> void:
	var inventory = get_inventory()
	var item = inventory.get_all_items().keys()[0]
	if science_values.get(item):
		GlobalSignals.science_generated.emit(science_values[item])
		inventory.remove_item(item,1)
	else:
		print(item + " not in dico science")
