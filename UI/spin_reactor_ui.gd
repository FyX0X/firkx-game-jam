class_name  SpinReactorUI
extends Control

@onready var center_container: CenterContainer = $CenterContainer
@onready var color_rect: ColorRect = $CenterContainer/ColorRect

@onready var iron_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/IronProgressBar 
@onready var titanium_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TitaniumProgressBar 
@onready var silicium_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/SiliciumProgressBar
@onready var tungsten_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TungstenProgressBar
@onready var electricity_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/ElectricityProgressBar

@onready var iron_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/IronLabel 
@onready var titanium_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TitaniumLabel 
@onready var silicium_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/SiliciumLabel
@onready var tungsten_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TungstenLabel
@onready var electricity_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/ElectricityLabel


var spin_reactor: SpinReactor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spin_reactor = get_tree().get_first_node_in_group("spin_reactor")
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()
	
	# init progress bars
	iron_progress.max_value = spin_reactor.construction_cost["iron"]
	titanium_progress.max_value = spin_reactor.construction_cost["titanium"]
	silicium_progress.max_value = spin_reactor.construction_cost["silicium"]
	tungsten_progress.max_value = spin_reactor.construction_cost["tungsten"]
	
	_refresh()
	spin_reactor.deposit_changed.connect(_refresh)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resize() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	color_rect.custom_minimum_size = viewport_size * 0.8

func _refresh() -> void:
	iron_progress.value = spin_reactor.deposited["iron"]
	titanium_progress.value = spin_reactor.deposited["titanium"]
	silicium_progress.value = spin_reactor.deposited["silicium"]
	tungsten_progress.value = spin_reactor.deposited["tungsten"]
	
	iron_label.text = "Iron Deposited: " + str(spin_reactor.deposited["iron"]) + "/" + str(spin_reactor.construction_cost["iron"])
	titanium_label.text = "titanium Deposited: " + str(spin_reactor.deposited["titanium"]) + "/" + str(spin_reactor.construction_cost["titanium"])
	silicium_label.text = "Silicium Deposited: " + str(spin_reactor.deposited["silicium"]) + "/" + str(spin_reactor.construction_cost["silicium"])
	tungsten_label.text = "Tungsten Deposited: " + str(spin_reactor.deposited["tungsten"]) + "/" + str(spin_reactor.construction_cost["tungsten"])
