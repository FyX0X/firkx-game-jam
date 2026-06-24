class_name Drill
extends Building

@export var type : String = "iron"
@onready var DrillAudio: AudioStreamPlayer3D = $DrillAudio


const drill_cost : Dictionary = {
	"iron" = {"iron" : 5},
	"titanium" = {"iron": 50},
	"copper" = {"iron" : 100, "titanium": 20},
	"tungsten" = {"iron" : 100, "titanium": 20, "copper":30}
}

const dico_speed : Dictionary = {
	"iron" = 10,
	"titanium" = 10,
	"copper" = 10,
	"tungsten" = 10
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	process_speed = 10
	energy = -5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if is_hologram:
		return
	if DrillAudio and not DrillAudio.playing:
		DrillAudio.play()
	
	buffer += process_speed * delta
	if (buffer >= 1):
		inventory.add_item(type, 1)
		buffer -= 1

func set_type(new_type : String):
	type = new_type
	cost = drill_cost[type]
	process_speed = dico_speed[type]
