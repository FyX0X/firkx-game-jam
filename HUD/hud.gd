class_name HUD
extends CanvasLayer

@onready var popups: Control = $PopupRoot
@onready var cinematic_player: VideoStreamPlayer = $CinematicPlayer
@onready var debug_panel: Control = $DebugPanel
@onready var inventory_hud: Control = $InventoryHUD
@onready var damage_overlay: ColorRect = $DamageOverlay
@onready var build_cost_ui: BuildCostUI = $BuildCostUI
@onready var research_ui: ResearchUI = $ResearchUI
@onready var spin_reactor_ui: SpinReactorUI = $SpinReactorUI

var intro_video: VideoStreamTheora
var outro_video: VideoStreamTheora
var _is_intro: bool = true
var end_callable: Callable = Callable()

var messages: Array[Control] = []
@export var MAX_MESSAGES: int = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	intro_video = preload("res://assets/video/gamejam_animation_debut.ogv")
	outro_video = preload("res://assets/video/gamejam_animation_outro.ogv")
	close_all_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_cinematic(is_intro: bool, end_observer: Callable) -> void:
	_is_intro = is_intro
	popups.hide()
	inventory_hud.hide()
	research_ui.hide()
	debug_panel.hide()
	cinematic_player.show()
	if is_intro:
		cinematic_player.stream = intro_video
	else:
		cinematic_player.stream = outro_video
	cinematic_player.play()
	end_callable = end_observer
	
func skip_intro() -> void:
	cinematic_player.stop()
	_on_cinematic_player_finished()


func set_damage_overlay(health_normalized: float) -> void:
	# health_normalized is 0.0 (dead) to 1.0 (full)
	var alpha = (1.0 - health_normalized) * 0.6   # max 60% opacity at 0 health
	damage_overlay.color = Color(1, 0, 0, alpha)

func flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(damage_overlay, "color:a", 0.5, 0.05)
	tween.tween_property(damage_overlay, "color:a", 0.0, 0.3)

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
	if not _is_intro:
		print("hud: _on_cinematic_player_finished: outro finished keeps video shown")
		return
	popups.show()
	inventory_hud.show()
	debug_panel.show()
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

func set_spin_reactor_ui_visibility(shown: bool) -> void:
	spin_reactor_ui.visible = shown
