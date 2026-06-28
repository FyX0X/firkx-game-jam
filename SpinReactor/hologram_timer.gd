class_name HologramTimer
extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var viewport: SubViewport = $SubViewport
@onready var time_label: Label = $SubViewport/TimerUI/VBoxContainer/Time
@onready var message_label: Label = $SubViewport/TimerUI/VBoxContainer/Message
var main: MainManager = null

@export var billboard: bool = true

@export var default_color: Color = Color.CYAN
@export var low_color: Color = Color.YELLOW
@export var critical_color: Color = Color.RED

var shader_mat: ShaderMaterial = null

func _ready() -> void:
	main = get_tree().current_scene
	assert(is_instance_valid(main))
	assert(main != null)
	assert(main is MainManager)
	set_message("Please proceed to activate the spin reactor. Corporate doesn't like to wait.")
	main.time_low_signal.connect(_on_time_low)
	main.time_critical_signal.connect(_on_time_critical)
	
	mesh.material_override = mesh.material_override.duplicate()
	shader_mat = mesh.material_override
	
	shader_mat.set_shader_parameter("screen_tex", viewport.get_texture())
	set_hologram_color(default_color)
	set_glitch(0, 0)
	shader_mat.set_shader_parameter("billboard", billboard)
	

func _on_time_low() -> void:
	set_hologram_color(low_color)
	set_glitch(0.3)
	print("low")


func _on_time_critical() -> void:
	print("critical")
	set_hologram_color(critical_color)
	set_glitch(0.8)

func _process(_delta):
	var t = main.time_left
	time_label.text = "Remaining Time : " + StringUtils.format_time_m_s(t)

func set_time_visibility(shown: bool) -> void:
	time_label.visible = shown


func set_glitch(strengh: float, speed: float = 1.0):
	print("hologram_timer: glitch not implemented")
	return
	shader_mat.set_shader_parameter("glitch_strengh", strengh)
	shader_mat.set_shader_parameter("glitch_speed", speed)


func set_hologram_color(color: Color) -> void:
	shader_mat.set_shader_parameter("hologram_color", color)


func set_message(msg: String) -> void:
	message_label.text = msg
