class_name ResearchUI
extends Control

@onready var center_container: CenterContainer = $CenterContainer
@onready var color_rect: ColorRect = $CenterContainer/ColorRect
@onready var texture_rect:	 TextureRect = $CenterContainer/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resize() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	color_rect.custom_minimum_size = viewport_size * 0.8
	texture_rect.custom_minimum_size = viewport_size * 0.7
