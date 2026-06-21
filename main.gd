extends Node

@onready var hud_layer: HUD = $HUD
@onready var inventory_hud: InventoryHUD = $HUD/InventoryHUD
@onready var player: Player = $Player
@onready var building_placement: Placement = $Player/Placement

enum GameState { INTRO, GAME, WON }
var state: GameState = GameState.INTRO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.interacted.connect(_on_player_interacted)
	player.interaction_target_changed.connect(_on_interaction_target_changed)
	building_placement.win_triggered.connect(_on_win)
	building_placement.building_selection_changed.connect(_on_building_selection_change)
	set_state(GameState.INTRO)

func set_state(new_state: GameState) -> void:
	state = new_state
	match state:
		GameState.INTRO:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			player.active = false
			hud_layer.play_cinematic(true, _on_intro_finished)
		GameState.GAME:
			player.active = true
			player.set_state(Player.State.NORMAL)
		GameState.WON:
			player.active = false
			hud_layer.play_cinematic(false, _on_outro_finished)

func _on_intro_finished() -> void:
	set_state(GameState.GAME)

func _on_outro_finished() -> void:
	pass

func _on_win() -> void:
	set_state(GameState.WON)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _open_inventory(left: Inventory, right: Inventory = null) -> void:
	player.set_state(Player.State.UI_OPEN)
	if right == null:
		inventory_hud.open_single(left)
		return
	inventory_hud.open_transfer(left, right);
		
	
func _close_inventory() -> void:
	inventory_hud.close()
	player.set_state(Player.State.NORMAL)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_close_inventory()
		if state == GameState.INTRO:
			hud_layer.skip_intro()
		print("TODO: implement pause")
	
	if event.is_action_pressed("inventory"):
		if inventory_hud.is_open:
			_close_inventory()
		else:
			_open_inventory(player.get_inventory())


func _on_player_interacted(target: Node) -> void:
	print("debug: on_player_interacted - " + str(target))
	if target.has_method("interact"):
		target.interact(player)
	elif target.has_method("get_inventory"):
		_open_inventory(player.get_inventory(), target.get_inventory())
	else:
		print("Interact failed: No suitable methods for target found.")

func _on_interaction_target_changed(target: Node, group: String) -> void:
	if target == null:
		return
	if group == "interactable":
		hud_layer.show_popup_message("Press E to Interact")
	if group == "mineable":
		hud_layer.show_popup_message("Left Click to Mine", 2)

func _on_building_selection_change(building: Building) -> void:
	hud_layer.show_popup_message("Left Click to place : " + building.name, 2)
	hud_layer.show_build_recipe(building.cost)
	
