extends Control

signal slot_picked(inventory: Inventory, item_id: String, mouse_button: MouseButton, slot: Panel)
signal slot_dropped(inventory: Inventory, item_id: String, mouse_button: MouseButton)

@onready var grid: GridContainer = $VBoxContainer/GridContainer
@onready var detail_label: Label = $VBoxContainer/DetailLabel
@onready var title_label: Label = $VBoxContainer/TitleLabel

var inventory: Inventory


func _ready():
	for i in grid.get_child_count():
		var slot = grid.get_child(i)
		slot.index = i
		slot.slot_clicked.connect(_on_slot_clicked.bind(slot))
	hide()

func setup(target: Inventory) -> void:
	inventory = target
	inventory.inventory_changed.connect(_on_inventory_changed)
	if title_label:
		title_label.text = target.inventory_name
	refresh()

func teardown() -> void:
	if inventory:
		inventory.inventory_changed.disconnect(_on_inventory_changed)
		inventory = null

func refresh():
	if not inventory:
		return
	var items = inventory.get_all_items()
	var keys = items.keys()
	var count = grid.get_child_count()
	for i in count:
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

func _on_slot_clicked(item_id: String, mouse_button: MouseButton, slot: Panel) -> void:
	if detail_label:
		detail_label.text = item_id + "  ×" + str(inventory.get_amount(item_id)) if item_id != "" else ""
	if item_id != "":
		slot_picked.emit(inventory, item_id, mouse_button, slot)
	else:
		slot_dropped.emit(inventory, item_id, mouse_button)
