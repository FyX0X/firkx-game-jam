extends Node3D

@export var damage_per_second: float = 30.0
@onready var player: Player = get_parent()   # adjust path if needed
@onready var beam: MeshInstance3D = $Beam
@onready var pickup_audio: AudioStreamPlayer3D = $Beam/pickup_audio
@onready var laser_audio: AudioStreamPlayer3D = $Beam/laser_audio

var _tick_timer: float = 0.0
var _connected_target: Node  = null

@export var qte_chance : float = 0.3
@export var qte_bonus_dmg : float = 2.0
var qte_bonus_time : float = 0.0

var _qte_active : bool = false
var bonus_duration : float = 0.25

var laser_material : Material = preload("res://assets/Material/purple_laser.tres")
var subdivisions : int = 50
var thickness : float = 0.3

var im_mesh : ImmediateMesh 

var line_count = 5
func _ready() -> void:
	im_mesh = ImmediateMesh.new()
	beam.mesh = im_mesh
	beam.material_override = laser_material

func _process(delta: float) -> void:
	if Input.is_action_pressed("attack"):
		_do_laser(delta)
	else:
		_stop_laser()

func create_curved_laser(delta :float):
	var start : Vector3 = player.find_child("Laser",true,false).global_position
	var end : Vector3 = player.raycast.get_collision_point()
	if not player.raycast.is_colliding():
		return
	start = beam.to_local(start)
	end = beam.to_local(end)
	im_mesh.clear_surfaces()	
	im_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	#var time_scale = Time.get_ticks_msec() * 0.01
	var direction = end - start
	var total_distance = direction.length()
	var previous_point = start

	for line_index in range(line_count):
			var line_speed_modifier = 1.0 + sin(line_index) * 0.5 # Vitesse unique
			var time_scale = Time.get_ticks_msec() * 0.01 * line_speed_modifier
			
			previous_point = start
			
			for i in range(1, subdivisions + 1):
				var t = float(i) / subdivisions
				var base_point = start.lerp(end, t)
				
				var wave_frequency = 3.0 + cos(line_index) * 1.5
				var wave = (t * total_distance * wave_frequency) - time_scale
				
				var offset_x = cos(wave + line_index) * 0.25
				var offset_y = sin(wave + line_index) * 0.25
				
				var fade_edges = t
				offset_x *= fade_edges
				offset_y *= fade_edges
				
				var current_point = base_point + Vector3(offset_x, offset_y, 0.0)
				
				# On dessine le segment de cette ligne
				im_mesh.surface_add_vertex(previous_point)
				im_mesh.surface_add_vertex(current_point)
				
				previous_point = current_point
		
	im_mesh.surface_end()
	

func _do_laser(delta: float) -> void:
	var damage = 0
	if  player.get_state() == Player.State.UI_OPEN or player.get_state() == Player.State.BUILDING:
		_stop_laser()
		return
	
	var target = player._current_target
	if target == null or not (target.is_in_group("minable") or target.is_in_group("breakable")):
		_stop_laser()
		return
	
	# connect signal if target changed
	if target != _connected_target:
		_disconnect_target()
		_connected_target = target
		if target.has_signal("resource_yielded"):
			target.resource_yielded.connect(_on_resource_yielded)
			
	beam.visible = true
	create_curved_laser(delta)
	if player._current_state == Player.State.NORMAL:
		player.set_state(Player.State.ATTACKING)
	
	if laser_audio and not laser_audio.playing:
		laser_audio.play()
	
	
	if target.is_in_group("breakable"):
		target.take_damage(damage_per_second * delta, player.get_inventory())

	_tick_timer += delta
	if qte_bonus_time > 0:
		qte_bonus_time -= delta
		
	if target.has_method("take_damage_ore"):
		if not _qte_active and randf() < qte_chance * delta:
			_start_qte()
		
		if qte_bonus_time > 0:
			damage = damage_per_second * qte_bonus_dmg
		else:
			damage = damage_per_second
		target.take_damage_ore(damage* delta )

func _start_qte() -> void:
	_qte_active = true
	player.hud_layer.trigger_skill_check(_on_qte_finished)

func _on_qte_finished(success: bool) -> void:
	_qte_active = false
	if success:
		print("QTE Réussi ! Dégâts bonus !")
		if _connected_target :
			qte_bonus_time += bonus_duration
			
			# if pickup_audio: pickup_audio.play()

# Nouvelle fonction centralisée pour éteindre le laser et son audio
func _stop_laser() -> void:
	beam.visible = false
	_tick_timer = 0.0
	_disconnect_target()
	if laser_audio and laser_audio.playing:
		laser_audio.stop()
	if player.get_state() == Player.State.ATTACKING:
		player.set_state(Player.State.NORMAL)
	if _qte_active:
		player.hud_layer.skill_check.cancel()
		_qte_active = false

func _disconnect_target() -> void:
	if _connected_target != null:
		if _connected_target.has_signal("resource_yielded"):
			if _connected_target.resource_yielded.is_connected(_on_resource_yielded):
				_connected_target.resource_yielded.disconnect(_on_resource_yielded)
		_connected_target = null

func _on_resource_yielded(ore_type: String, amount: int) -> void:
	print("_on_resource_yielded()")
	player.pickup_resource(ore_type, amount)
	if pickup_audio:
		if pickup_audio.playing:
			pickup_audio.stop()
		pickup_audio.play()
