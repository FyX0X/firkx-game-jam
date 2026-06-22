class_name Factory
extends Building

@export var recipe : Dictionary = {} #ie my_recipe = {"input" : {ITEMS}, "output" : {ITEMS}, "time" : FLOAT}
var outputs : Dictionary = {}
@onready var DrillAudio: AudioStreamPlayer3D = $Drill/DrillAudio


const recipes : Dictionary = {
	"iron" : {"input" : {"iron" : 2}, "output" : {"iron_bar" : 1}, "time" : 3},
	"titanium" : {"input" : {"titanium" : 2}, "output" : {"titanium_bar" : 1}, "time" : 4},
	"sillicium" : {"input": {"sillicium" : 2}, "output" : {"sillicium_bar" : 1}, "time" : 3},
	"tungsten" :{"input" : {"tungsten" : 2}, "output" : {"tungsten_bar" : 1}, "time" : 3},
}

const ores = ["iron", "titanium", "sillicium", "tungsten"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	inventory.inventory_changed.connect(_on_inventory_changed)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if is_hologram:
		return
	
	if _can_process():
		if DrillAudio and not DrillAudio.playing:
			DrillAudio.play()
		buffer += delta * process_speed
		if (buffer >= recipe["time"]):
			_finish_processing()
			

func _on_inventory_changed():
	var keys = inventory.get_all_items().keys()
	for item in keys:
		if item in ores:
			recipe = recipes[item]
			return

func _can_process() -> bool:
	for item in recipe["input"]:
		var amount_needed = recipe["input"][item]
		if not inventory.get_all_items().has(item) or inventory.get_all_items()[item] < amount_needed:
			return false
	return true

func _finish_processing() -> void:
	for item in recipe["input"]:
		inventory.remove_item(item, recipe["input"][item])
	
	for item in recipe["output"]:
		inventory.add_item(item, recipe["output"][item])
	buffer -= recipe["time"]

func set_recipe(new_recipe : Dictionary):
	recipe = new_recipe
	
