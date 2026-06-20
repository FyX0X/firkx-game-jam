extends Building

var type : String = "iron"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_speed = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	buffer += process_speed * delta
	if (buffer >= 1):
		inventory.add_item(type, 1)
		buffer -= 1
		print("Drill :" + str(inventory.get_all_items()[type]))

func set_type(new_type : String):
	type = new_type
