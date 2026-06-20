extends Control

@onready var item_option: OptionButton = $VBoxContainer/ItemOption
@onready var amount_slider: HSlider = $VBoxContainer/AmountSlider
@onready var amount_label: Label = $VBoxContainer/AmountLabel


var player_inventory: Inventory

const ITEMS = ["iron_ore", "coal", "copper_ore", "stone", "wood", "iron_ingot", "gear"]

func _ready():
	player_inventory = get_tree().get_first_node_in_group("player").get_node("Inventory")
	for item in ITEMS:
		item_option.add_item(item)
	amount_slider.value_changed.connect(func(v): amount_label.text = str(int(v)))

func _input(event):
	if event.is_action_pressed("debug"):   # bind F3 in InputMap
		visible = !visible

func _on_add_button_pressed() -> void:
	var item = ITEMS[item_option.selected]
	var amt = int(amount_slider.value)
	player_inventory.add_item(item, amt)


func _on_remove_button_pressed() -> void:
	var item = ITEMS[item_option.selected]
	var amt = int(amount_slider.value)
	player_inventory.remove_item(item, amt)
