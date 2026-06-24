class_name BiomeUI
extends Control

@onready var biome_label: Label = $CenterContainer/VBoxContainer/BiomeLabel
@onready var description_label: Label = $CenterContainer/VBoxContainer/DescriptionLabel
@onready var timer: Timer = $Timer

func show_biome_entry(biome: DamageZone, time: float = 4) -> void:
	biome_label.text  = biome.biome_name
	description_label.text = biome.biome_description
	timer.start(time)
	show()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	timer.timeout.connect(hide)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
