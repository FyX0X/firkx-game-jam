extends Node3D

@export var damage_per_second: float = 30.0
@export var resource_tick: float = 1.5

@onready var player: Player = get_parent()   # adjust path if needed
@onready var beam: MeshInstance3D = $Beam

var _tick_timer: float = 0.0
var _connected_target: Node  = null


func _process(delta: float) -> void:
	if Input.is_action_pressed("attack"):
		_do_laser(delta)
	else:
		beam.visible = false
		_tick_timer = 0.0
		_disconnect_target()

func _do_laser(delta: float) -> void:
	var target = player._current_target
	if target == null or not target.is_in_group("minable"):
		beam.visible = false
		_tick_timer = 0.0
		_disconnect_target()
		return
	
	# connect signal if target changed
	if target != _connected_target:
		_disconnect_target()
		_connected_target = target
		if target.has_signal("resource_yielded"):
			target.resource_yielded.connect(_on_resource_yielded)
	beam.visible = true
	
	if target.is_in_group("breakable"):
		target.take_damage(damage_per_second * delta)

	_tick_timer += delta
	if _tick_timer >= resource_tick:
		_tick_timer = 0.0
		if target.has_method("yield_resource"):
			target.yield_resource()

func _disconnect_target() -> void:
	if _connected_target != null:
		if _connected_target.has_signal("resource_yielded"):
			if _connected_target.resource_yielded.is_connected(_on_resource_yielded):
				_connected_target.resource_yielded.disconnect(_on_resource_yielded)
		_connected_target = null

func _on_resource_yielded(ore_type: String, amount: int) -> void:
	print("_on_resource_yielded()")
	player.pickup_resource(ore_type, amount)
	# or: inventory_changed.emit(ore_type, amount)
	# or: InventoryManager.add(ore_type, amount)
