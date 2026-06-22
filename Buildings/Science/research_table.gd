class_name ResearchTable
extends Building

signal research_opened

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	pass

func get_inventory() -> Inventory:
	return null

func interact(player: Player) -> void:
	research_opened.emit()
