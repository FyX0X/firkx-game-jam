class_name SkillCheck
extends Control

signal skill_check_result(success : bool)

var active : bool = false
var current_angle : float = 0.0
var rotation_speed : float = 150.0
var success_start: float = 0.0
var success_end: float = 0.0

@onready var player : Player = get_parent().get_parent().find_child("Player",true)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not active:
		return
	current_angle += rotation_speed * delta
	queue_redraw()
	
	if current_angle >= 270.0:
		_finish(false)

func start_check() -> void:
	current_angle = -90.0
	
	success_start = randf() * 270 # not in first quadrant
	success_end = success_start + 20.0
	
	active = true
	player.skillcheck_active = true
	show()
	set_process(true)

func _input(event: InputEvent) -> void:
	if active and event.is_action_pressed("jump"):
		var success = current_angle >= success_start and current_angle <= success_end
		_finish(success)
		get_viewport().set_input_as_handled()

func _finish(success : bool) -> void:
	active = false
	player.skillcheck_active = false
	player.time_since_skill = 0.2
	hide()
	set_process(false)
	skill_check_result.emit(success)

# Fonction magique de Godot pour dessiner des formes sans sprites
func _draw() -> void:
	var center = size / 2
	var radius = min(size.x, size.y) / 2
	
	draw_circle(center, radius, Color(0, 0, 0, 0.6))
	
	draw_arc(center, radius * 0.8, deg_to_rad(success_start), deg_to_rad(success_end), 32, Color.WHITE, 12.0, true)
	
	var needle_end = center + Vector2(cos(deg_to_rad(current_angle)), sin(deg_to_rad(current_angle))) * radius
	draw_line(center, needle_end, Color.RED, 4.0, true)

func cancel() -> void:
	if active:
		_finish(false)
