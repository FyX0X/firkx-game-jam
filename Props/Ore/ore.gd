class_name Ore
extends BaseProp

enum OreType {
	IRON,
	TITANIUM,
	COPPER,
	TUNGSTEN,
	NULL
}

@export var type : OreType = OreType.IRON

@onready var mesh_instance : MeshInstance3D = $MeshInstance3D

var ore_data : Dictionary = {
	OreType.IRON: {
		"display_name": "Iron", 
	},
	OreType.COPPER: {
		"display_name": "Copper", 
	},
	OreType.TITANIUM: {
		"display_name": "Titanium", 
	},
	OreType.TUNGSTEN: {
		"display_name": "Tungsten", 
	},
	OreType.NULL: {
		"display_name": "NULL", 
	}
}
var current_name : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data = ore_data[type]
	current_name = data["display_name"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _get_string(ore : OreType) -> String:
	match ore:
		OreType.IRON:
			return "iron"
		OreType.TITANIUM:
			return "titanium"
		OreType.COPPER:
			return "copper"
		OreType.TUNGSTEN:
			return "tungsten"
		_:
			return ""

func _set_type(string : String = "" , new_type : OreType = OreType.NULL):
	if new_type != OreType.NULL:
		type = new_type
	elif string:
		match string:
			"iron":
				type =  OreType.IRON
			"titanium":
				type = OreType.TITANIUM
			"copper":
				type = OreType.COPPER
			"tungsten":
				type = OreType.TUNGSTEN
			_:
				type = OreType.NULL
