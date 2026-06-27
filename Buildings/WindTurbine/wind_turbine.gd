class_name WindTurbin
extends Building

@onready var anim : AnimationPlayer = find_child("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	# energy = 5 in export

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if not is_hologram and not anim.is_playing():
		anim.play("Windturbine")
	pass

func interact(player: Player) -> void:
	# doing nothing prevent inventory from opening
	pass

func get_custom_interaction_message() -> String:
	return current_grid.get_power_grid_info_string()
