class_name ScienceTable
extends Building

@onready var Audioscience: AudioStreamPlayer3D = $Audioscience

const science_values : Dictionary = {
	"iron": 1,
	"titanium": 2,
	"copper": 3,
	"tungsten": 5
}

const science_needed : Dictionary = {
	"iron" : 0,
	"titanium" : 75,
	"copper" : 50,
	"tungsten" : 150,
}

@onready var attention_grabber: AttentionGrabber = $AttentionGrabber
var already_interacted: bool = false

func get_inventory() -> Inventory:
	if not already_interacted:
		already_interacted = true
		attention_grabber.queue_free()
	return super.get_inventory() # or return inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	process_speed = 10
	attention_grabber.show()


func _process(delta: float) -> void:
	super._process(delta)
	if inventory.is_empty():
		return
		
	if is_hologram:
		return
	
	buffer += process_speed * delta
	if (buffer >= 1):
		_consume_item()
		buffer -= 1

func _consume_item() -> void:
	for item in science_values.keys():
		if inventory.has_item(item):
			GlobalSignals.science_generated.emit(science_values[item])
			inventory.remove_item(item,1)
			if Audioscience and not Audioscience.playing:
				Audioscience.play()
			return
