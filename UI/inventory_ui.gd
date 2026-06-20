extends Control

@onready var grid: GridContainer = $GridContainer
@onready var detail_label: Label = $DetailLabel

var player_inventory: Inventory
const SLOT_COUNT := 20
const COLS := 5
var shown: bool = false

func _ready():
	player_inventory = get_tree().get_first_node_in_group("player").get_node("Inventory")
	player_inventory.inventory_changed.connect(_on_inventory_changed)
	_build_grid()
	refresh()
	hide()
	

func _build_grid():
	grid.columns = COLS
	print(grid)  # should print [GridContainer:...]
	for i in SLOT_COUNT:
		var slot = preload("res://UI/inventory_slot.tscn").instantiate()
		slot.index = i
		slot.slot_clicked.connect(_on_slot_clicked)
		grid.add_child(slot)
		print("added slot ", i)

func refresh():
	var items = player_inventory.get_all_items()
	var keys = items.keys()
	for i in SLOT_COUNT:
		var slot = grid.get_child(i)
		if i < keys.size():
			slot.set_item(keys[i], items[keys[i]])
		else:
			slot.clear()

func _on_inventory_changed():
	refresh()

func _on_slot_clicked(item_id: String):
	detail_label.text = item_id + "  ×" + str(player_inventory.get_amount(item_id))


func _input(event):
	if event.is_action_pressed("inventory"):
		shown = !shown
		visible = shown
		print("_inventory_ui.gd: _input()" + str(player_inventory.get_all_items()))
