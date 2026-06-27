class_name TaskGroup
extends Resource

@export var label: String = ""
@export var tasks: Array[TaskData] = []

func is_complete() -> bool:
	return tasks.all(func(t): return t.done)

static func create(label: String, tasks: Array[TaskData]) -> TaskGroup:
	var group: TaskGroup = TaskGroup.new()
	group.label = label
	group.tasks = tasks
	return group
