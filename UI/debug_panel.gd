extends Control

@onready var item_option: OptionButton = $Categories/Inventory/ItemOption
@onready var amount_slider: HSlider = $Categories/Inventory/AmountSlider
@onready var amount_label: Label = $Categories/Inventory/AmountLabel

@onready var fly_button: CheckButton = $Categories/Movement/FlyButton
@onready var speed_slider: HSlider = $Categories/Movement/SpeedSlider
@onready var speed_label: Label = $Categories/Movement/SpeedLabel

var player: Player
var player_inventory: Inventory

const ITEMS = ["iron_ore", "coal", "copper_ore", "stone", "wood", "iron_ingot", "gear"]

func _ready():
	player = get_tree().get_first_node_in_group("player")
	player_inventory = player.get_node("Inventory")
	for item in ITEMS:
		item_option.add_item(item)
	amount_slider.value_changed.connect(func(v): amount_label.text = str(int(v)))
	speed_slider.value = player.speed

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

func _on_fly_button_toggled(toggled_on: bool) -> void:
	player.fly_debug = toggled_on


func _on_speed_slider_value_changed(value: float) -> void:
	speed_label.text = "speed: " + str(value)
	player.speed = value
