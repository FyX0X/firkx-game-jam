extends Control

signal slot_picked(inventory: Inventory, item_id: String, slot: Panel)
signal slot_dropped(inventory: Inventory, item_id: String)

@onready var grid: GridContainer = $GridContainer
@onready var detail_label: Label = $DetailLabel
@onready var title_label: Label = $TitleLabel

const SLOT_COUNT := 20
const COLS := 5

var inventory: Inventory

func setup(target: Inventory, label: String = "Inventory") -> void:
	inventory = target
	inventory.inventory_changed.connect(_on_inventory_changed)
	title_label.text = label
	refresh()

func _ready():
	_build_grid()
	hide()

func _build_grid():
	grid.columns = COLS
	for i in SLOT_COUNT:
		var slot = preload("res://UI/inventory_slot.tscn").instantiate()
		slot.index = i
		slot.slot_clicked.connect(_on_slot_clicked.bind(slot))
		grid.add_child(slot)

func refresh():
	if not inventory:
		return
	var items = inventory.get_all_items()
	var keys = items.keys()
	for i in SLOT_COUNT:
		var slot = grid.get_child(i)
		if i < keys.size():
			slot.set_item(keys[i], items[keys[i]])
		else:
			slot.clear()

func clear_selection() -> void:
	for slot in grid.get_children():
		slot.set_selected(false)

func _on_inventory_changed():
	refresh()

func _on_slot_clicked(item_id: String, slot: Panel) -> void:
	detail_label.text = item_id + "  ×" + str(inventory.get_amount(item_id)) if item_id != "" else ""
	if item_id != "":
		slot_picked.emit(inventory, item_id, slot)
	else:
		slot_dropped.emit(inventory, item_id)
