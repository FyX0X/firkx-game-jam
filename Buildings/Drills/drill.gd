class_name Drill
extends Building

@export var type : String = "undefined"
@onready var DrillAudio: AudioStreamPlayer3D = $DrillAudio


const drill_cost : Dictionary = {
	"iron" = {"iron" : 5},
	"titanium" = {"iron_bar": 30, "titanium_bar": 5},
	"copper" = {"iron_bar" : 30, "copper_bar": 5},
	"tungsten" = {"iron_bar" : 75, "titanium_bar": 25, "copper_bar":25, "tungsten_bar": 5},
	"broken" = {"iron" : 5},
}

const dico_speed : Dictionary = {
	"iron" = 1,
	"titanium" = 1,
	"copper" = 1,
	"tungsten" = 1,
	"broken" = 0
}

const energy_cost : Dictionary = {
	"iron" = -5,
	"titanium" = -15,
	"copper" = -15,
	"tungsten" = -30,
	"broken" = 0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# process_speed = 10
	# energy = -5 : now in export
	
	assert(dico_speed.keys() == energy_cost.keys() and dico_speed.keys() == drill_cost.keys())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if is_hologram:
		return
	if not is_powered:
		return
	
	assert(type in dico_speed.keys()) # just to be sure
	

	if DrillAudio and not DrillAudio.playing:
		DrillAudio.play()
	
	buffer += process_speed * delta
	if (buffer >= 1):
		inventory.add_item(type, 1)
		buffer = 0

func set_type(new_type : String):
	type = new_type
	cost = drill_cost.get(type, {})
	process_speed = dico_speed.get(type, 0)
	energy = energy_cost.get(type, 0)
