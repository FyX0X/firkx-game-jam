class_name Player
extends CharacterBody3D

signal interacted(target: Node)
signal interaction_target_changed(target: Node)  # null when nothing in sight
var _current_target: Node = null

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity: float = 0.003

@onready var inventory: Inventory = $Inventory
@onready var raycast: RayCast3D = $RayCast3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	if raycast.is_colliding():
		var interactable = raycast.get_collider()
		if interactable != null and interactable.is_in_group("interactable"):
			if interactable != _current_target:
				_current_target = interactable
				interaction_target_changed.emit(_current_target)
			return

	if _current_target != null:
		_current_target = null
		interaction_target_changed.emit(null)



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


# Camera and escape.
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

func get_inventory() -> Inventory:
	return inventory
