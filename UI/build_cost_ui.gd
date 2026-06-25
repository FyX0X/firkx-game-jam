class_name BuildCostUI
extends Control

@onready var build_label: Label = $VBoxContainer/BuildLabel
@onready var grid: GridContainer = $VBoxContainer/GridContainer

var slots: Array[InventorySlot]

@onready var player : Player = get_parent().get_parent().find_child("Player", true)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in grid.get_child_count():
		var slot = grid.get_child(i)
		slots.append(slot)
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_build_cost(recipe: Dictionary):
	var size: int = recipe.size()
	if size > 5:
		push_error("Build cost ui: set_build_cost(), recipe had more than 5 element")
		return
	_clear_recipe()
	var keys = recipe.keys()
	for i in size:
		slots[i].set_item(keys[i], recipe[keys[i]])
		if not player.get_inventory().has_item(keys[i], recipe[keys[i]]):
			slots[i].self_modulate = Color(1, 0, 0, 0.5)

func _clear_recipe() -> void:
	for i in 5:
		slots[i].clear()
		slots[i].self_modulate = Color.WHITE
