class_name Drill
extends Building

@export var type : String = "undefined"
@onready var DrillAudio: AudioStreamPlayer3D = $DrillAudio
@onready var anim : AnimationPlayer = $Mesh/AnimationPlayer

const drill_cost : Dictionary = {
	"iron" = {"iron" : 5},
	"titanium" = {"iron_bar": 10, "titanium_bar": 3},
	"copper" = {"iron_bar" : 10, "copper_bar": 3},
	"tungsten" = {"iron_bar" : 20, "titanium_bar": 5, "copper_bar":5, "tungsten_bar": 3}
}

const dico_speed : Dictionary = {
	"iron" = 2,
	"titanium" = 2,
	"copper" = 2,
	"tungsten" = 2
}

const energy_cost : Dictionary = {
	"iron" = -5,
	"titanium" = -10,
	"copper" = -10,
	"tungsten" = -20
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	process_speed = 10
	# energy = -5 : now in export
	set_type("undefined")
	
	assert(dico_speed.keys() == energy_cost.keys() and dico_speed.keys() == drill_cost.keys())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if is_hologram:
		return
	if not is_powered:
		return
	if not anim.is_playing():
		anim.play("Drill_Operate")
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
