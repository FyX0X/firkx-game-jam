extends Building

@export var type : String = "iron"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_speed = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if is_hologram:
		return
	
	buffer += process_speed * delta
	if (buffer >= 1):
		inventory.add_item(type, 1)
		buffer -= 1

func set_type(new_type : String):
	type = new_type
