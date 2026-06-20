extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var mouse_sensitivity: float = 0.003

@onready var placement: Placement = $Placement

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	placement.building_placed.connect(_on_building_placed)

func _on_building_placed(building: Building) -> void:
	var inventory = $Inventory
	for item in building.cost:
		inventory.remove_item(item, building.cost[item])
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


# Camera and escape.
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

func _input(event):
	if event.is_action_pressed("build"):
		placement.building_mode = not placement.building_mode
		if placement.building_mode:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			placement.clear_hologram()

	if placement.building_mode:
		if event.is_action_pressed("scroll_up"):
			placement.object_change(1)
		elif event.is_action_pressed("scroll_down"):
			placement.object_change(-1)

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
