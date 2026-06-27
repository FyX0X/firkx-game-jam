class_name HUD
extends CanvasLayer

@onready var popups: Control = $PopupRoot
@onready var cinematic_player: VideoStreamPlayer = $CinematicPlayer
@onready var debug_panel: DebugPanel = $DebugPanel
@onready var inventory_hud: Control = $InventoryHUD
@onready var damage_overlay: ColorRect = $DamageOverlay
@onready var build_cost_ui: BuildCostUI = $BuildCostUI
@onready var research_ui: ResearchUI = $ResearchUI
@onready var spin_reactor_ui: SpinReactorUI = $SpinReactorUI
@onready var build_label : Label = $BuildLabel
@onready var biome_ui: BiomeUI = $BiomeUI
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var skill_check : SkillCheck = $SkillCheck
@onready var task_ui: TaskUI = $TaskUI
@onready var crosshair: ColorRect = $Crosshair


const _INTRO_VIDEO: VideoStreamTheora = preload("res://assets/video/intro_long.ogv")
var end_callable: Callable = Callable()

var messages: Array[Control] = []
@export var MAX_MESSAGES: int = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_all_ui()
	crosshair.visible = GameSettings.crosshair_enabled


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func trigger_skill_check(callable_result : Callable) -> void:
	skill_check.skill_check_result.connect(callable_result, CONNECT_ONE_SHOT)
	skill_check.start_check()

func play_cinematic(end_observer: Callable) -> void:
	popups.hide()
	inventory_hud.hide()
	research_ui.hide()
	debug_panel.show_debug_panel(false)
	cinematic_player.show()
	cinematic_player.stream = _INTRO_VIDEO
	cinematic_player.play()
	end_callable = end_observer
	
func skip_intro() -> void:
	cinematic_player.stop()
	_on_cinematic_player_finished()


func set_damage_overlay(health_normalized: float) -> void:
	# health_normalized is 0.0 (dead) to 1.0 (full)
	var alpha = (1.0 - health_normalized) * 0.6   # max 60% opacity at 0 health
	damage_overlay.color = Color(1, 0, 0, alpha)

func show_popup_message(text: String, time: float = 2.0) -> void:
	if time <= 0:
		return

	# prevent duplicate last message
	if messages.size() > 0:
		var last := messages[messages.size() - 1]
		if is_instance_valid(last) and last.text == text:
			return

	var label := Label.new()
	label.text = text
	label.modulate.a = 1.0  # already visible
	label.add_theme_font_size_override("font_size", 24)
	# Add a Black Outline
	label.add_theme_color_override("font_outline_color", Color.BLACK) # Set color to black
	label.add_theme_constant_override("outline_size", 8)              # Thickness in pixels

	popups.add_child(label)
	messages.append(label)

	if messages.size() > MAX_MESSAGES:
		_remove_message(messages[0])

	# place immediately, then animate only if needed
	_relayout(false)

	if time > 0:
		var timer := get_tree().create_timer(time)
		timer.timeout.connect(func():
			if is_instance_valid(label):
				_remove_message(label)
		)

func _remove_message(label: Control) -> void:
	if not is_instance_valid(label):
		return

	messages.erase(label)

	var t := create_tween()
	t.tween_property(label, "modulate:a", 0.0, 0.15)
	t.parallel().tween_property(label, "position:x", label.position.x + 20, 0.15)

	t.tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
		_relayout(true)
	)

func _relayout(animated: bool = true) -> void:
	var start_pos := Vector2(20, 20)
	var spacing := 30

	for i in messages.size():
		var label := messages[i]
		if not is_instance_valid(label):
			continue

		var target := start_pos + Vector2(0, i * spacing)

		if animated:
			var t := create_tween()
			t.tween_property(label, "position", target, 0.2)
		else:
			label.position = target

func _on_cinematic_player_finished() -> void:
	if (end_callable.is_valid()):
		end_callable.call()
		end_callable = Callable()

	popups.show()
	inventory_hud.show()
	cinematic_player.hide()

func show_build_recipe(recipe: Dictionary) -> void:
	build_cost_ui.show()
	build_cost_ui.set_build_cost(recipe)

func set_research_ui_visibility(shown: bool) -> void:
	research_ui.visible = shown

func close_all_ui() -> void:
	set_research_ui_visibility(false)
	set_spin_reactor_ui_visibility(false)
	inventory_hud.close()
	build_cost_ui.hide()
	update_building_info(null)

func set_spin_reactor_ui_visibility(shown: bool) -> void:
	spin_reactor_ui.visible = shown

func update_building_info(building : Building) -> void:
	if building == null:
		build_label.visible = false
		return
	build_label.visible = true
	
	if building.is_in_group("electrical"):
		build_label.text = building.name + "\n"
		if building.energy > 0:
			build_label.text += "Production: " + str(building.energy) + " MW"
		elif building.energy < 0:
			build_label.text += "Consommation: " + str(-building.energy) + " MW"
		else:
			build_label.text += ""

func set_pause_menu_visibility(shown: bool) -> void:
	pause_menu.visible = shown
