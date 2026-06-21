extends Node

@onready var hud_layer: HUD = $HUD
@onready var inventory_hud: InventoryHUD = $HUD/InventoryHUD
@onready var player: Player = $Player
@onready var building_placement: Placement = $Player/Placement
@onready var intro_video: VideoStreamPlayer = $HUD/IntroVideo

enum GameState { INTRO, GAME, WON }
var state: GameState = GameState.INTRO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.interacted.connect(_on_player_interacted)
	player.interaction_target_changed.connect(_on_interaction_target_changed)
	building_placement.win_triggered.connect(_on_win)
	set_state(GameState.INTRO)

func set_state(new_state: GameState) -> void:
	state = new_state
	match state:
		GameState.INTRO:
			player.active = false
			hud_layer.play_cinematic(true, _on_intro_finished)
		GameState.GAME:
			player.active = true
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


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		inventory_hud.close()
		if state == GameState.INTRO:
			hud_layer.skip_intro()
		print("TODO: implement pause")
	
	if event.is_action_pressed("inventory"):
		if inventory_hud.is_open:
			inventory_hud.close()
		else:
			inventory_hud.open_single(player.get_inventory())


func _on_player_interacted(target: Node) -> void:
	print("debug: on_player_interacted - " + str(target))
	if target.has_method("interact"):
		target.interact(player)
	elif target.has_method("get_inventory"):
		inventory_hud.open_transfer(player.get_inventory(), target.get_inventory())
		hud_layer.clear_popup_message()
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
