extends Node

@onready var hud_layer: CanvasLayer = $HUD
@onready var inventory_hud: InventoryHUD = $HUD/InventoryHUD
@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("inventory"):
		inventory_hud.open_single(player.get_inventory())
		
