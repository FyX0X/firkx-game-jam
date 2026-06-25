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

## should be set by inherited class
var mesh_instance : MeshInstance3D = null

var ore_data : Dictionary = {
	OreType.IRON: {
		"display_name": "Iron",
		"color": Color(0.37, 0.207, 0.148, 1.0)
	},
	OreType.COPPER: {
		"display_name": "Copper",
		"color": Color(0.193, 0.58, 0.445, 1.0)
	},
	OreType.TITANIUM: {
		"display_name": "Titanium", 
		"color": Color(0.278, 0.328, 0.466, 1.0)
	},
	OreType.TUNGSTEN: {
		"display_name": "Tungsten", 
		"color": Color(0.396, 0.39, 0.363, 1.0)
	},
	OreType.NULL: {
		"display_name": "NULL", 
		"color": Color(1.0, 1.0, 1.0, 1.0)
	}
}
var current_name : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data = ore_data[type]
	current_name = data["display_name"]
	_set_material()


func _set_material() -> void:
	# should be set by inherited class
	assert(mesh_instance != null)
	var mat: StandardMaterial3D = mesh_instance.get_active_material(1).duplicate()
	mat.albedo_color *= ore_data[type]["color"]
	mesh_instance.set_surface_override_material(1, mat)

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
