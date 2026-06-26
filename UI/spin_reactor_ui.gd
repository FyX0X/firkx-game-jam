class_name  SpinReactorUI
extends Control

@onready var center_container: CenterContainer = $CenterContainer
@onready var color_rect: ColorRect = $CenterContainer/ColorRect

@onready var iron_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/IronProgressBar 
@onready var titanium_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TitaniumProgressBar 
@onready var copper_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/CopperProgressBar
@onready var tungsten_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TungstenProgressBar
@onready var electricity_progress: ProgressBar = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/ElectricityProgressBar

@onready var iron_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/IronLabel 
@onready var titanium_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TitaniumLabel 
@onready var copper_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/CopperLabel
@onready var tungsten_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/TungstenLabel
@onready var electricity_label: Label = $CenterContainer/ColorRect/MarginContainer/VBoxContainer/ElectricityLabel


var spin_reactor: SpinReactor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spin_reactor = get_tree().get_first_node_in_group("spin_reactor")
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()
	
	# init progress bars
	iron_progress.max_value = spin_reactor.construction_cost["iron_bar"]
	titanium_progress.max_value = spin_reactor.construction_cost["titanium_bar"]
	copper_progress.max_value = spin_reactor.construction_cost["copper_bar"]
	tungsten_progress.max_value = spin_reactor.construction_cost["tungsten_bar"]
	
	electricity_progress.max_value = absi(spin_reactor.energy)
	spin_reactor.deposit_changed.connect(_refresh_material)
	spin_reactor.powered_changed.connect(_refresh_electricity)
	_refresh_material()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resize() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	color_rect.custom_minimum_size = viewport_size * 0.8

func _refresh() -> void:
	_refresh_material()
	_refresh_electricity()

func _refresh_electricity() -> void:
	var spin_consumption: int = -spin_reactor.energy
	var grid: PowerGrid = spin_reactor.current_grid
	var grid_deficit: int = grid.demand - grid.production
	var power_in_spin_reactor: int = spin_consumption - grid_deficit
	power_in_spin_reactor = maxi(power_in_spin_reactor, 0)
	power_in_spin_reactor = mini(power_in_spin_reactor, spin_consumption)
	assert(spin_reactor.is_powered == (power_in_spin_reactor == spin_consumption))
	electricity_progress.value = power_in_spin_reactor
	var power_string: String = "Electricity Supplied : Powered" if spin_reactor.is_powered else "Electricity Supplied : Unpowered"
	power_string += " (%d/%d [MW])" % [power_in_spin_reactor, spin_consumption]
	electricity_label.text = power_string

func _refresh_material() -> void:
	iron_progress.value = spin_reactor.deposited["iron_bar"]
	titanium_progress.value = spin_reactor.deposited["titanium_bar"]
	copper_progress.value = spin_reactor.deposited["copper_bar"]
	tungsten_progress.value = spin_reactor.deposited["tungsten_bar"]
	
	iron_label.text = "Iron Bar Deposited: " + str(spin_reactor.deposited["iron_bar"]) + "/" + str(spin_reactor.construction_cost["iron_bar"])
	titanium_label.text = "Titanium Bar Deposited: " + str(spin_reactor.deposited["titanium_bar"]) + "/" + str(spin_reactor.construction_cost["titanium_bar"])
	copper_label.text = "Copper Bar Deposited: " + str(spin_reactor.deposited["copper_bar"]) + "/" + str(spin_reactor.construction_cost["copper_bar"])
	tungsten_label.text = "Tungsten Bar Deposited: " + str(spin_reactor.deposited["tungsten_bar"]) + "/" + str(spin_reactor.construction_cost["tungsten_bar"])
