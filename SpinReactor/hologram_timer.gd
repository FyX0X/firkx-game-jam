class_name HologramTimer
extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var viewport: SubViewport = $SubViewport
@onready var time_label: Label = $SubViewport/TimerUI/VBoxContainer/Time
@onready var message_label: Label = $SubViewport/TimerUI/VBoxContainer/Message
var main: MainManager = null

@export var default_color: Color = Color.CYAN
@export var low_color: Color = Color.YELLOW
@export var critical_color: Color = Color.RED


func _ready() -> void:
	main = get_tree().current_scene
	assert(is_instance_valid(main))
	assert(main != null)
	assert(main is MainManager)
	set_message("Please proceed to activate the spin reactor. Corporate doesn't like to wait.")
	main.time_low_signal.connect(_on_time_low)
	main.time_critical_signal.connect(_on_time_critical)
	
	var mat := mesh.material_override as ShaderMaterial
	mat.set_shader_parameter("screen_tex", viewport.get_texture())
	set_hologram_color(default_color)

func _on_time_low() -> void:
	set_hologram_color(low_color)


func _on_time_critical() -> void:
	set_hologram_color(critical_color)

func _process(_delta):
	var t = main.time_left
	time_label.text = "Remaining Time : " + _format_time(t)

func set_time_visibility(shown: bool) -> void:
	time_label.visible = shown


func set_hologram_color(color: Color) -> void:
	var mat: ShaderMaterial = mesh.material_override
	mat.set_shader_parameter("hologram_color", color)


func set_message(msg: String) -> void:
	message_label.text = msg

func _format_time(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60

	return "%02d:%02d" % [minutes, seconds]
