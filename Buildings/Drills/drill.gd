class_name Drill
extends Building

@export var type : String = "iron"

const drill_cost : Dictionary = {
	"iron" = {"iron" : 5},
	"titanium" = {"iron": 50},
	"sillicium" = {"iron" : 100, "titanium": 20},
	"tungsten" = {"iron" : 100, "titanium": 20, "sillicium":30}
}

const dico_speed : Dictionary = {
	"iron" = 10,
	"titanium" = 10,
	"sillicium" = 10,
	"tungsten" = 10
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_speed = 10
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if is_hologram:
		return
	
	buffer += process_speed * delta
	if (buffer >= 1):
		inventory.add_item(type, 1)
		buffer -= 1

func set_type(new_type : String):
	type = new_type
	process_speed = dico_speed[type]
