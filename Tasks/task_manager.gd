class_name TaskManager
extends Node

var player: Player = null
var spin_reactor: SpinReactor = null

var iron_group: TaskGroup = null
var first_drill_group: TaskGroup = null
var automation_group: TaskGroup = null
var spin_reactor_group: TaskGroup = null

var groups: Array[TaskGroup] = []
var task_ui: TaskUI = null

func _ready() -> void:
	task_ui = get_tree().get_first_node_in_group("task_ui")
	
	iron_group = TaskGroup.create("First Step", [
		TaskData.create("mine_iron", "Locate an iron vein and start mining"),
	])
	
	first_drill_group = TaskGroup.create("First Drill !", [
		TaskData.create("iron_drill", "Build your first iron drill on a ground deposit"),
		TaskData.create("wind_turbin", "Build a small wind turbin near your drill to power it"),
	])
	
	automation_group = TaskGroup.create("Automation", [
		TaskData.create("factory", "Build a factory to smelt your resources into bars"),
		TaskData.create("science", "Convert resources into science using the science table"),
		TaskData.create("copper_drill", "Build a copper drill on an appropriate ground deposit"),
		TaskData.create("titanium_drill", "Build a titanium drill on an appropriate ground deposit"),
		TaskData.create("tungsten_drill", "Build a tungsten drill on an appropriate ground deposit"),
	])
	
	spin_reactor_group = TaskGroup.create("Save the planet !", [
		TaskData.create("spin_reactor", "Complete the Spin Reactor and activate it"),
	])
	groups = [iron_group, first_drill_group, automation_group, spin_reactor_group]

	task_ui.setup(groups)
	
	# setup signals
	player = get_tree().get_first_node_in_group("player")
	spin_reactor = get_tree().get_first_node_in_group("spin_reactor")
	
	player.placement.building_placed.connect(_building_placement_check)
	player.laser_tool.mined_resource.connect(_mined_check)
	spin_reactor.spin_reactor_built.connect(func(): task_ui.complete_task("spin_reactor"))
	GlobalSignals.science_generated.connect(func(x: int): task_ui.complete_task("science"))
	

func _building_placement_check(building: Building) -> void:
	if building is Factory:
		task_ui.complete_task("factory")
	elif building is WindTurbin:
		task_ui.complete_task("wind_turbin")
	elif building is Drill:
		var drill: Drill = building
		task_ui.complete_task("%s_drill" % drill.type)

func _mined_check(type: String, amount: int) -> void:
	if type == "iron":
		task_ui.complete_task("mine_iron")
