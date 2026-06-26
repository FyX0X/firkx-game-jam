class_name InventorySlot
extends Panel

signal slot_clicked(item_id: String, mouse_button: MouseButton)

@onready var icon_label: Label = $Icon
@onready var count_label: Label = $Count

var index: int = 0
var current_item: String = ""

func _ready():
	# custom_minimum_size = Vector2(64, 64)
	count_label.text = ""

func set_item(item_id: String, amount: int):
	current_item = item_id
	icon_label.text = StringUtils.get_pretty_string(item_id)
	count_label.text = "×" + str(amount)
	modulate.a = 1.0

func clear():
	current_item = ""
	icon_label.text = ""
	count_label.text = ""
	modulate.a = 0.4

# ── selection highlight ─────────────────────────────────────────────
func set_selected(selected: bool) -> void:
	if selected:
		self_modulate = Color(1.5, 1.5, 0.5)   # yellow tint
	else:
		self_modulate = Color.WHITE

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		slot_clicked.emit(current_item, event.button_index)   # emit even if empty (for drop target)
