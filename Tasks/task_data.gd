class_name TaskData
extends Resource

@export var id: String = ""
@export var label: String = ""
var done: bool = false

static func create(id: String, label: String) -> TaskData:
	var task: TaskData = TaskData.new()
	task.id = id
	task.label = label
	return task
