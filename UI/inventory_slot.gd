extends Panel

signal slot_clicked(item_id: String)

@onready var icon_label: Label = $VBoxContainer/Icon
@onready var count_label: Label = $VBoxContainer/Count

var index: int = 0
var current_item: String = ""

func _ready():
	custom_minimum_size = Vector2(64, 64)
	count_label.text = "0"

func set_item(item_id: String, amount: int):
	current_item = item_id
	# icon_label.text = ItemDB.get_icon(item_id)   # returns an emoji or texture path
	icon_label.text = item_id
	count_label.text = "×" + str(amount)
	modulate.a = 1.0

func clear():
	current_item = ""
	icon_label.text = ""
	count_label.text = ""
	modulate.a = 0.4

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and current_item != "":
		print("DEBUG (inventory_slot.gd _gui_input())")
		slot_clicked.emit(current_item)
