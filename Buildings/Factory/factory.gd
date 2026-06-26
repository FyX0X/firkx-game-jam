class_name Factory
extends Building

@export var recipe : Dictionary = {} #ie my_recipe = {"input" : {ITEMS}, "output" : {ITEMS}, "time" : FLOAT}
var outputs : Dictionary = {}
@onready var Audiofactory: AudioStreamPlayer3D = $Audiofactory


const recipes : Dictionary = {
	"iron" : {"input" : {"iron" : 2}, "output" : {"iron_bar" : 1}, "time" : 0.5},
	"titanium" : {"input" : {"titanium" : 2}, "output" : {"titanium_bar" : 1}, "time" : 0.5},
	"copper" : {"input": {"copper" : 2}, "output" : {"copper_bar" : 1}, "time" : 0.5},
	"tungsten" :{"input" : {"tungsten" : 2}, "output" : {"tungsten_bar" : 1}, "time" : 0.5},
}

const ores = ["iron", "titanium", "copper", "tungsten"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	inventory.inventory_changed.connect(_on_inventory_changed)
	# energy = -5 in export

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if is_hologram:
		return
	if not is_powered:
		return
	
	if _can_process():
		if Audiofactory and not Audiofactory.playing:
			Audiofactory.play()
		buffer += delta * process_speed
		if (buffer >= recipe["time"]):
			_finish_processing()
			

func _on_inventory_changed():
	_update_recipe()

func _update_recipe() -> void:
	if not recipe.is_empty() and _can_process_recipe(recipe):
		return
		
	for ore in ores:
		if recipes.has(ore):
			var test_recipe = recipes[ore]
			if _can_process_recipe(test_recipe):
				recipe = test_recipe
				return
				

func _can_process() -> bool:
	return _can_process_recipe(recipe)

func _finish_processing() -> void:
	for item in recipe["input"]:
		inventory.remove_item(item, recipe["input"][item])
	
	for item in recipe["output"]:
		inventory.add_item(item, recipe["output"][item])
	buffer -= recipe["time"]
func _can_process_recipe(r: Dictionary) -> bool:
	if r.is_empty() or not r.has("input"):
		return false
		
	var items = inventory.get_all_items()
	for item in r["input"]:
		var amount_needed = r["input"][item]
		# On vérifie si l'item est présent ET si sa quantité est suffisante
		if not items.has(item) or items[item] < amount_needed:
			return false
	return true
	
func set_recipe(new_recipe : Dictionary):
	recipe = new_recipe
	
