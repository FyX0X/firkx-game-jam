extends Node

@onready var hud_layer: HUD = $HUD
@onready var inventory_hud: InventoryHUD = $HUD/InventoryHUD
@onready var player: Player = $Player
@onready var building_placement: Placement = $Player/Placement
@onready var spin_reactor: SpinReactor = $SpinReactor
@onready var space_sky_environment: SpaceSkyEnvironment = $World/SpaceSky


enum GameState { INTRO, GAME, WON }
var state: GameState = GameState.INTRO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var science_table: ScienceTable = find_child("ScienceTable",true,true)
	var research_table: ResearchTable =find_child("ResearchTable",true,true)
	player.interacted.connect(_on_player_interacted)
	player.respawn()
	player.interaction_target_changed.connect(_on_interaction_target_changed)
	spin_reactor.spin_reactor_built.connect(_on_win)
	building_placement.building_selection_changed.connect(_on_building_selection_change)
	set_state(GameState.INTRO)
	research_table.research_opened.connect(_on_research_opened)
	spin_reactor.computer.spin_reactor_open_ui.connect(_on_spin_reactor_opened)
	hud_layer.pause_menu.unpaused.connect(_toggle_pause)

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
			spin_reactor.reactor_audio.stop()
			hud_layer.play_cinematic(false, _on_outro_finished)

func _on_intro_finished() -> void:
	set_state(GameState.GAME)

func _on_outro_finished() -> void:
	pass

func _on_win() -> void:
	# make this smooth
	space_sky_environment.start_rotation()
	# play spin reactor animation
	
	await get_tree().create_timer(20).timeout
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
	# inventory_hud.close()
	player.set_state(Player.State.NORMAL)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		
		if state == GameState.INTRO:
			hud_layer.skip_intro()
			return
		if player.get_state() == Player.State.NORMAL:
			_toggle_pause()
			return
		
		hud_layer.close_all_ui()
		player.set_state(Player.State.NORMAL)
		
	if event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		if player.get_state() == Player.State.UI_OPEN:
			player.set_state(Player.State.NORMAL)
		else:
			_open_inventory(player.get_inventory())
		

func _toggle_pause() -> void:
	var tree: SceneTree = get_tree()
	tree.paused = not tree.paused
	hud_layer.set_pause_menu_visibility(tree.paused)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if tree.paused else Input.MOUSE_MODE_CAPTURED

func _on_player_interacted(target: Node) -> void:
	print("debug: on_player_interacted - " + str(target))
	if target.has_method("interact"):
		target.interact(player)
	elif target.has_method("get_inventory"):
		var target_inv: Inventory = target.get_inventory()
		if target_inv:
			_open_inventory(player.get_inventory(), target.get_inventory())
	else:
		print("Interact failed: No suitable methods for target found.")

func _on_interaction_target_changed(target: Node, group: String) -> void:
	if target == null:
		return
	if target.has_method("get_custom_interaction_message"):
		hud_layer.show_popup_message(target.get_custom_interaction_message(), 2)
		return
	
	if group == "interactable":
		hud_layer.show_popup_message("Press E to Interact")
	if group == "mineable":
		hud_layer.show_popup_message("Left Click to Mine", 2)

func _on_building_selection_change(building: Building) -> void:
	if building == null:
		return
	hud_layer.show_popup_message("Left Click to place : " + building.name, 2)
	hud_layer.show_build_recipe(building.cost)

func _on_research_opened() -> void:
	player.set_state(Player.State.UI_OPEN)
	hud_layer.set_research_ui_visibility(true)

func _on_research_closed() -> void:
	player.set_state(Player.State.NORMAL)
	# hud_layer.set_research_ui_visibility(false)

func _on_spin_reactor_opened() -> void:
	player.set_state(Player.State.UI_OPEN)
	hud_layer.set_spin_reactor_ui_visibility(true)
