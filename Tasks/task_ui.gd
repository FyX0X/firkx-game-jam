class_name TaskUI
extends PanelContainer

@onready var task_list := $TaskList

var groups: Array[TaskGroup] = []
var current_group_index: int = 0


func _ready() -> void:
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical   = Control.SIZE_SHRINK_CENTER


func setup(task_groups: Array[TaskGroup]) -> void:
	groups = task_groups
	current_group_index = 0
	_rebuild()


# Call this from anywhere with the task's id string
func complete_task(task_id: String) -> void:
	if current_group_index >= groups.size():
		return

	var group: TaskGroup = groups[current_group_index]
	var found: bool = false
	for task in group.tasks:
		if task.id == task_id:
			task.done = true
			found = true
			break
	if not found:
		return  # id not found in current group — ignore

	_rebuild()

	# Check if all tasks in group are done
	if group.is_complete():
		await get_tree().create_timer(0.6).timeout  # brief pause to show completion
		current_group_index += 1
		if current_group_index >= groups.size():
			hide()  # all groups done
			return
		_rebuild()


func _rebuild() -> void:
	for child in task_list.get_children():
		child.queue_free()

	if current_group_index >= groups.size():
		return

	var group: TaskGroup = groups[current_group_index]

	var header := Label.new()
	header.text = group.label
	header.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	header.add_theme_font_size_override("font_size", 11)
	task_list.add_child(header)

	for task in group.tasks:
		task_list.add_child(_make_row(task))


func _make_row(task: TaskData) -> HBoxContainer:
	var done: bool = task.done

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(14, 14)
	icon.color = Color(0.11, 0.62, 0.46) if done else Color(1, 1, 1, 0.15)
	row.add_child(icon)

	var lbl := Label.new()
	lbl.text = task.label
	lbl.add_theme_color_override(
		"font_color",
		Color(1, 1, 1, 0.35) if done else Color(1, 1, 1, 0.9)
	)
	row.add_child(lbl)

	return row
