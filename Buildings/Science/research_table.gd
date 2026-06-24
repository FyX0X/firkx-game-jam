class_name ResearchTable
extends Building

signal research_opened

@onready var attention_grabber: AttentionGrabber = $AttentionGrabber
var already_interacted: bool = false

func interact(player: Player) -> void:
	if not already_interacted:
		already_interacted = true
		attention_grabber.queue_free()
	research_opened.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	pass

func get_inventory() -> Inventory:
	return null
