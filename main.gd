extends Node

@onready var hud_layer: HUD = $HUD
@onready var inventory_hud: InventoryHUD = $HUD/InventoryHUD
@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.interacted.connect(_on_player_interacted)
	player.interaction_target_changed.connect(_on_interaction_target_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		inventory_hud.close()
		print("TODO: implement pause")
	
	if event.is_action_pressed("inventory"):
		if inventory_hud.is_open:
			inventory_hud.close()
		else:
			inventory_hud.open_single(player.get_inventory())


func _on_player_interacted(target: Node) -> void:
	print("debug: on_player_interacted - " + str(target))
	if target.has_method("get_inventory"):
		inventory_hud.open_transfer(player.get_inventory(), target.get_inventory())
		hud_layer.clear_popup_message()
	elif target.has_method("interact"):
		target.interact(player)
	else:
		print("Interact failed: No suitable methods for target found.")

func _on_interaction_target_changed(target: Node, group: String) -> void:
	if target == null:
		hud_layer.clear_popup_message()
		return
	if group == "interactable":
		hud_layer.show_popup_message("Press E to Interact")
	if group == "mineable":
		hud_layer.show_popup_message("Left Click to Mine", 2)
