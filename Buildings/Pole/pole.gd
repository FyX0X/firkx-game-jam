class_name Pole
extends Building


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func interact(player: Player) -> void:
	# doing nothing prevent inventory from opening
	pass

func get_custom_interaction_message() -> String:
	return current_grid.get_power_grid_info_string()
