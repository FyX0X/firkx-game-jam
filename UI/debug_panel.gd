class_name DebugPanel
extends Control

@onready var item_option: OptionButton = $Categories/Inventory/ItemOption
@onready var amount_slider: HSlider = $Categories/Inventory/AmountSlider
@onready var amount_label: Label = $Categories/Inventory/AmountLabel

@onready var fly_button: CheckButton = $Categories/Movement/FlyButton
@onready var speed_slider: HSlider = $Categories/Movement/SpeedSlider
@onready var speed_label: Label = $Categories/Movement/SpeedLabel

@onready var player_state_value_label: Label = $Categories/Information/PlayerStateValue
@onready var challenge_value_label: Label = $Categories/Information/ChallengeValue

@onready var time_slider: HSlider = $"Categories/Time Management/TimeSlider"
@onready var time_value_label: Label = $"Categories/Time Management/TimeValue"

var player: Player
var player_inventory: Inventory
var main: MainManager = null

const ITEMS = ["iron", "copper", "titanium", "tungsten", "iron_bar"]

func _ready():
	player = get_tree().get_first_node_in_group("player")
	player_inventory = player.get_node("Inventory")
	for item in ITEMS:
		item_option.add_item(item)
	amount_slider.value_changed.connect(func(v): amount_label.text = str(int(v)))
	print("player.speed =", player.speed, " type=", typeof(player.speed))
	speed_slider.value = player.speed
	_refresh()
	main = get_tree().current_scene
	assert(main != null)

func _input(event):
	if event.is_action_pressed("debug"):   # bind F3 in InputMap
		visible = !visible
		_refresh()

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

func set_player_state(state: Player.State) -> void:
	player_state_value_label.text = Player.State.find_key(state)

func _refresh() -> void:
	challenge_value_label.text = GameSettings.Difficulty.find_key(GameSettings.difficulty)


func _on_time_slider_value_changed(value: float) -> void:
	time_value_label.text = "time: %.1f [s]" % value


func _on_time_button_pressed() -> void:
	main.time_left += time_slider.value
