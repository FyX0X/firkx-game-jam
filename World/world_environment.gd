class_name SpaceSkyEnvironment
extends WorldEnvironment

@export var max_rotation_speed: float = 0.02 # The target speed
@export var rotation_axis: Vector3 = Vector3.LEFT
@export var spin_up_time: float = 3.0 # How many seconds to take to reach max speed

# Start at 0 so it doesn't move initially
var current_speed: float = 0.0
var is_rotating: bool = false

func _process(delta: float) -> void:
	if not is_rotating:
		return

	if environment and environment.sky:
		var current_basis = Basis.from_euler(environment.sky_rotation)
		# Use current_speed here instead of a static speed
		var rotation_step = Basis.from_euler(rotation_axis * current_speed * delta)
		environment.sky_rotation = (current_basis * rotation_step).get_euler()

func start_rotation() -> void:
	if is_rotating:
		return # Already rotating or transitioning
		
	is_rotating = true
	
	# Create a tween to smoothly transition current_speed to max_rotation_speed
	var tween = create_tween()
	
	# Set the transition to ease-in so it starts extra smooth
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Interpolate the 'current_speed' property to 'max_rotation_speed' over 'spin_up_time' seconds
	tween.tween_property(self, "current_speed", max_rotation_speed, spin_up_time)
