class_name Player
extends CharacterBody3D

signal interacted(target: Node)
signal interaction_target_changed(target: Node)  # null when nothing in sight
var _current_target: Node = null

@onready var inventory: Inventory = $Inventory
@onready var camera_arm: SpringArm3D = $SpringArm3D
@onready var raycast: RayCast3D = $SpringArm3D/Camera3D/RayCast3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity: float = 0.003
@export var tilt_limit = deg_to_rad(75)

var fly_debug: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if fly_debug:
		_process_debug_flying(delta)
	else:
		_process_movement(delta)
	move_and_slide()
	
	raycast_check()

func _process_movement(delta: float) -> void:
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


func raycast_check() -> void:
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

func _input(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_arm.rotation.x -= event.screen_relative.y * mouse_sensitivity
		# Prevent the camera from rotating too far up or down.
		camera_arm.rotation.x = clampf(camera_arm.rotation.x, -tilt_limit, tilt_limit)
		rotation.y += -event.screen_relative.x * mouse_sensitivity

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("interact") and _current_target != null:
			interacted.emit(_current_target)

func get_inventory() -> Inventory:
	return inventory


func _process_debug_flying(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (camera_arm.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var up_down := 0.0
	if Input.is_action_pressed("jump"):
		up_down = 1.0
	if Input.is_action_pressed("crouch"):  # add this action too
		up_down = -1.0
	
	var target_velocity: Vector3 = direction * speed + Vector3.UP * up_down * speed
	velocity = velocity.lerp(target_velocity, delta * 10.0)  # smooth it out
