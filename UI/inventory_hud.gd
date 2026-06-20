class_name InventoryHUD
extends Control

@onready var left_ui: Control  = $LeftInventoryUI
@onready var right_ui: Control = $RightInventoryUI
@onready var transfer_amount: SpinBox = $TransferBar
@onready var cursor_label: Label = $CursorLabel   # floating label that follows mouse
var is_open: bool = false

# Grab state
var _grabbed_item: String = ""
var _grabbed_from: Inventory = null
var _grabbed_slot: Panel = null   # to highlight it


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	cursor_label.hide()
	left_ui.slot_picked.connect(_on_slot_picked)
	left_ui.slot_dropped.connect(_on_slot_dropped)
	right_ui.slot_picked.connect(_on_slot_picked)
	right_ui.slot_dropped.connect(_on_slot_dropped)
	hide()

func open_single(inv: Inventory) -> void:
	is_open = true
	left_ui.setup(inv)
	right_ui.hide()
	left_ui.show()
	show()

func open_transfer(left_inv: Inventory, right_inv: Inventory) -> void:
	is_open = true
	left_ui.setup(left_inv)
	right_ui.setup(right_inv)
	left_ui.show()
	right_ui.show()
	show()

func close() -> void:
	is_open = false
	_cancel_grab()
	hide()

# ── grab / drop ─────────────────────────────────────────────────────
func _on_slot_picked(from_inv: Inventory, item_id: String, slot: Panel) -> void:
	if _grabbed_item == "":
		# First click: grab
		_grabbed_item = item_id
		_grabbed_from = from_inv
		_grabbed_slot = slot
		slot.set_selected(true)
		cursor_label.text = item_id
		cursor_label.show()
	else:
		# Second click on a slot that has an item — could be same inv or other
		if from_inv == _grabbed_from and item_id == _grabbed_item:
			# Clicked the same slot: cancel
			_cancel_grab()
		else:
			# Drop onto an occupied slot: transfer there anyway
			_do_transfer(from_inv)

func _on_slot_dropped(to_inv: Inventory, _item_id: String) -> void:
	# Clicked an empty slot
	if _grabbed_item != "":
		_do_transfer(to_inv)

func _do_transfer(to_inv: Inventory) -> void:
	var amount := int(transfer_amount.value) if transfer_amount else 1
	Inventory.transfer_partial(_grabbed_from, to_inv, _grabbed_item, amount)
	_cancel_grab()

func _cancel_grab() -> void:
	if _grabbed_slot:
		_grabbed_slot.set_selected(false)
	_grabbed_item = ""
	_grabbed_from = null
	_grabbed_slot = null
	cursor_label.hide()

# ── cursor label follows mouse ───────────────────────────────────────
func _process(_delta: float) -> void:
	if cursor_label.visible:
		cursor_label.global_position = get_global_mouse_position() + Vector2(12, 12)

# ── right-click or Escape cancels grab ──────────────────────────────
func _gui_input(event: InputEvent) -> void:
	if _grabbed_item == "" :
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_cancel_grab()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_cancel_grab()
