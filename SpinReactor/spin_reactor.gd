class_name SpinReactor
extends StaticBody3D

signal spin_reactor_built
signal deposit_changed
signal powered_changed

@onready var deposit: StaticBody3D = $Deposit
@onready var inventory: Inventory = $Deposit/Inventory
@onready var computer: StaticBody3D = $Computer
@onready var reactor_audio: AudioStreamPlayer3D = $ReactorAudio
@onready var flame_particle: GPUParticles3D = $Flame

@export var process_speed: float = 10.0
var progress: float = 0
@export var construction_cost: Dictionary = {
	"iron_bar" :  20,#20
	"titanium_bar" : 15 ,#15
	"copper_bar" : 15  ,# 15
	"tungsten_bar" : 10 #10
}
var deposited: Dictionary = {
	"iron_bar" : 0,
	"titanium_bar" : 0,
	"copper_bar" : 0,
	"tungsten_bar" : 0
}

var current_mat: Material = null
var green_elec : Material = preload("res://assets/Material/green_elec.tres")
var red_elec : Material = preload("res://assets/Material/red_elec.tres")
@export var electricity_consumption: float = 100
@export var energy : int = -150 #200
var is_powered : bool = false
var current_grid : PowerGrid = null
var connected_cables : Array[Node3D] = []

var has_material: bool = false
var is_complete: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(deposited.keys() == construction_cost.keys())
	current_grid = PowerManager.create_new_grid()
	current_grid.add_building(self)
	PowerManager.connection(self)
	flame_particle.emitting = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if inventory.is_empty():
		return
		
	progress += process_speed * delta
	if (progress >= 1):
		_consume_item()
		progress = 0
	
	if has_material and is_powered and not is_complete:
		is_complete = true
		spin_reactor_built.emit()
		reactor_audio.play()
		flame_particle.emitting = true
		print("spin reactor is complete : electricity not yet implemented")

func _consume_item() -> void:
	# if Audioscience and not Audioscience.playing:
	# 	Audioscience.play()
	
	var allowed_items: Array = construction_cost.keys()
	
	for item in _get_missing_materials():
		if inventory.has_item(item):
			inventory.remove_item(item, 1)
			deposited[item] += 1
			deposit_changed.emit()
			_update_material()
			return

func _get_missing_materials() -> Array:
	
	var allowed_items: Array = construction_cost.keys()
	var missing: Array = []
	for item in allowed_items:
		if deposited[item] < construction_cost[item]:
			missing.append(item)
	return missing

func _update_material() -> void:
	has_material = _get_missing_materials().is_empty()



func set_powered(powered : bool) -> void:
	print("spin_reactor: Is powered : " + str(powered))
	is_powered = powered
	powered_changed.emit()
	var light = self.find_child("Light*", true, false)
	if light:
		print("Spin Reactor: Light found")
		if is_powered:
			print("spin reactor: set powered WIP")
			_override_mat(light, green_elec)
		else:
			print("spin reactor: set powered WIP")
			_override_mat(light, red_elec)

func _override_mat(node: Node3D, mat: Material) -> void:
	if mat == current_mat: 
		return
	current_mat = mat
	_override_mat_recursive(node, mat)

func _override_mat_recursive(node : Node3D, mat : Material) -> void:
	if node == null:
		return
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		if child is Node3D:
			_override_mat_recursive(child,mat)
