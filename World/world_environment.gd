extends WorldEnvironment

@export var rotation_speed: float = 0.02 # Speed of rotation
@export var rotation_axis: Vector3 = Vector3.RIGHT

func _process(delta: float) -> void:
	if environment and environment.sky:
			# 1. Convert the current sky rotation (Vector3) into a Basis matrix
			var current_basis = Basis.from_euler(environment.sky_rotation)
			
			# 2. Calculate the incremental rotation step for this frame
			var rotation_step = Basis.from_euler(rotation_axis * rotation_speed * delta)
			
			# 3. Combine them and convert back to Euler angles for the sky
			environment.sky_rotation = (current_basis * rotation_step).get_euler()
