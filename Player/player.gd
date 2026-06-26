class_name Player
extends CharacterBody3D

signal interacted(target: Node)
signal interaction_target_changed(target: Node, group: String)
var _current_target: Node = null

@onready var inventory: Inventory = $Inventory
@onready var camera_arm: SpringArm3D = $SpringArm3D
@onready var raycast: RayCast3D = $SpringArm3D/Camera3D/RayCast3D
@onready var placement: Placement = $Placement
@onready var audio_step: AudioStreamPlayer3D = $Audiostep
@onready var audio_jump: AudioStreamPlayer3D = $Audiojump
@onready var audio_jetpack: AudioStreamPlayer3D = $Anchor/JetPack/Audio
@onready var jetpack_flame: GPUParticles3D = $Anchor/JetPack/Flame
@onready var anim : AnimationPlayer = $Anchor/mesh/AnimationPlayer
@onready var mesh : Node3D = $Anchor/mesh
@onready var anchor: Node3D = $Anchor

var hud_layer: HUD
var debug_panel: DebugPanel
var spawnpoint: Node3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity: float = 0.003
@export var tilt_limit = deg_to_rad(75)
@export var max_health: float = 100
var health: float
@export var heal_time: float = 5
@export var healing_speed: float = 25
var _time_since_damage: float = 0
@export var respawn_delay: float = 1

# --- Jetpack ---
@export var jetpack_thrust: float = 12.0       # upward acceleration while thrusting
@export var jetpack_max_fuel: float = 100.0
@export var jetpack_drain_rate: float = 20.0   # fuel/sec while thrusting
@export var jetpack_regen_rate: float = 15.0   # fuel/sec while on ground
var jetpack_fuel: float
var jetpack_active: bool = false

var _active_zones: Dictionary = {}

var loot_bag_scene: PackedScene = preload("res://Props/LootBag/loot_bag.tscn")

var skillcheck_active :bool = false
var time_since_skill : float = 0.0

var upgrades: Dictionary = {
	"heat_resistance": 0.0,
	"cold_resistance": 0.0,
}
var fly_debug: bool = false
var active: bool = true

var science_points = 0

enum State {
	NORMAL,
	ATTACKING,
	BUILDING,
	DEAD,
	UI_OPEN
}

var _current_state: State = State.NORMAL

func _ready() -> void:
	health = max_health
	jetpack_fuel = jetpack_max_fuel
	placement.building_placed.connect(_on_building_placed)
	GlobalSignals.science_generated.connect(_on_science_generated)
	hud_layer = get_tree().get_first_node_in_group("hud")
	debug_panel = get_tree().get_first_node_in_group("debug_panel")
	spawnpoint = get_tree().get_first_node_in_group("spawn")
	print("player _ready: REMOVE FREE RESOURCES")
	# inventory.add_item("iron", 20)
	# science_points += 100
	 
	assert(hud_layer != null)
	assert(debug_panel != null)
	assert(spawnpoint != null)


func _on_building_placed(building: Building) -> void:
	for item in building.cost:
		inventory.remove_item(item, building.cost[item])

func _physics_process(delta: float) -> void:
	if time_since_skill > 0:
		time_since_skill -= delta
	if not active:
		return

	if fly_debug:
		_process_debug_flying(delta)
	else:
		_process_movement(delta)
	move_and_slide()
	_apply_zone_damage(delta)
	_process_health(delta)
	raycast_check()
	_update_animation()

func _update_animation() -> void:
	var on_ground := is_on_floor()
	var moving := Vector2(velocity.x, velocity.z).length() > 0.05
	var laser := (_current_state == State.ATTACKING)

	if laser and not anim.current_animation == "interact":
		if anim.is_playing() and anim.current_animation == "gunidle":
			anim.play("gunidle")
		else:
			anim.play("gun")
			anim.queue("gunidle")
		return
	# Jump animation removed — no jump anim needed with jetpack
	elif not on_ground and not anim.current_animation == "interact":
		anim.play("idle")
		return	
	elif moving and not anim.current_animation == "interact":
		anim.play("run")
	elif not anim.current_animation == "interact":
		anim.play("idle")

func _process_movement(delta: float) -> void:
	if _current_state == State.DEAD:
		if audio_step.playing:
			audio_step.stop()
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Tap = instant jump (free, no fuel)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not skillcheck_active and time_since_skill <= 0:
		velocity.y = jump_velocity
		audio_jump.play()

	# Hold = jetpack thrust (costs fuel, works mid-air)
	if Input.is_action_pressed("jump") and not is_on_floor() and jetpack_fuel > 0.0:
		velocity.y += jetpack_thrust * delta
		jetpack_fuel = maxf(jetpack_fuel - jetpack_drain_rate * delta, 0.0)
		jetpack_active = true
	else:
		jetpack_active = false
	_update_jetpack()

	# Fuel regenerates only on the ground
	if is_on_floor():
		jetpack_fuel = minf(jetpack_fuel + jetpack_regen_rate * delta, jetpack_max_fuel)

	# Horizontal movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		var target_angle = atan2(-velocity.x, -velocity.z)
		anchor.global_rotation.y = lerp_angle(anchor.global_rotation.y, target_angle, 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	var est_en_mouvement := Vector2(velocity.x, velocity.z).length() > 0.1
	if is_on_floor() and est_en_mouvement:
		if not audio_step.playing:
			audio_step.play()
	else:
		if audio_step.playing:
			audio_step.stop()

func _update_jetpack() -> void:
	if jetpack_active:
		if not audio_jetpack.playing:
			audio_jetpack.play()
		jetpack_flame.emitting = true
	else:
		if audio_jetpack.playing:
			audio_jetpack.stop()
		jetpack_flame.emitting = false

func raycast_check() -> void:
	if raycast.is_colliding():
		var interactable = raycast.get_collider()
		if interactable == null or interactable == _current_target:
			return
		_current_target = interactable
		for group in ["interactable", "mineable", "breakable"]:
			if interactable.is_in_group(group):
				interaction_target_changed.emit(_current_target, group)
				return

	if _current_target != null:
		_current_target = null
		interaction_target_changed.emit(null, "")

func _input(event: InputEvent):
	if not active or _current_state == State.DEAD:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_arm.rotation.x -= event.screen_relative.y * mouse_sensitivity
		camera_arm.rotation.x = clampf(camera_arm.rotation.x, -tilt_limit, tilt_limit)
		rotation.y += -event.screen_relative.x * mouse_sensitivity

func _unhandled_input(event: InputEvent) -> void:
	if _current_state == State.DEAD:
		return
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("interact") and _current_target != null:
			interacted.emit(_current_target)
		if event.is_action_pressed("build"):
			if _current_state == State.BUILDING:
				set_state(State.NORMAL)
			else:
				set_state(State.BUILDING)
		if _current_state == State.BUILDING:
			if event.is_action_pressed("scroll_up"):
				placement.object_change(1)
			elif event.is_action_pressed("scroll_down"):
				placement.object_change(-1)

func _on_science_generated(amount: int) -> void:
	science_points += amount

func get_state() -> State:
	return _current_state

func set_state(state: State) -> void:
	match _current_state:
		State.NORMAL:
			pass
		State.ATTACKING:
			pass
		State.BUILDING:
			placement.clear_hologram()
			hud_layer.build_cost_ui.hide()
		State.DEAD:
			active = true
			# revive ?
		State.UI_OPEN:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			hud_layer.close_all_ui()
	
	# handle new state
	_current_state = state
	match _current_state:
		State.NORMAL:
			pass
		State.ATTACKING:
			pass
		State.BUILDING:
			placement.object_change(0)
			hud_layer.build_cost_ui.show()
		State.DEAD:
			active = false
		State.UI_OPEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	debug_panel.set_player_state(_current_state)

func get_inventory() -> Inventory:
	return inventory

func pickup_resource(item_id: String, amount: int) -> void:
	if amount <= 0:
		return
	hud_layer.show_popup_message("Pickup: " + item_id + " * " + str(amount), 1)
	inventory.add_item(item_id, amount)

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

func take_damage(damage: float) -> void:
	if _current_state == State.DEAD:
		return
	_time_since_damage = 0
	health -= damage
	if health <= 0:
		health = 0
		die()
	hud_layer.set_damage_overlay(health / max_health)

func _process_health(delta: float) -> void:
	_time_since_damage += delta
	if _time_since_damage >= heal_time and health <= max_health:
		health += minf(healing_speed * delta, max_health)
		hud_layer.set_damage_overlay(health / max_health)

func die() -> void:
	set_state(State.DEAD)
	velocity = Vector3.ZERO
	var bag: LootBag = loot_bag_scene.instantiate()
	get_tree().current_scene.add_child(bag)
	bag.global_position = global_position
	Inventory.transfer_all(inventory, bag.get_inventory())
	assert(inventory.is_empty())
	get_tree().create_timer(respawn_delay).timeout.connect(respawn)

func respawn() -> void:
	set_state(State.NORMAL)
	global_position = spawnpoint.global_position
	health = max_health
	jetpack_fuel = jetpack_max_fuel   # refuel on respawn
	_time_since_damage = heal_time
	hud_layer.set_damage_overlay(1.0)

func enter_zone(zone: DamageZone) -> void:
	_active_zones[zone] = 0.0
	hud_layer.biome_ui.show_biome_entry(zone)
	print("player: enter_zone()" + str(zone) + ", " + zone.biome_name)

func exit_zone(zone: DamageZone) -> void:
	_active_zones.erase(zone)

func _apply_zone_damage(delta: float) -> void:
	for zone in _active_zones:
		_active_zones[zone] += delta
		var time_in_zone: float = _active_zones[zone]
		
		# grace period reduced by player upgrades
		var effective_grace = zone.grace_period * (1 + _get_zone_resistance(zone))
		if time_in_zone >= effective_grace:
			take_damage(zone.damage_per_second * delta)

func _get_zone_resistance(zone: DamageZone) -> float:
	# 0.0 = no resistance, 0.5 = grace period +50%
	match zone.zone_type:
		DamageZone.Type.HOT:  return upgrades.get("heat_resistance", 0.0)
		DamageZone.Type.COLD: return upgrades.get("cold_resistance", 0.0)
		_:                    return 0.0
