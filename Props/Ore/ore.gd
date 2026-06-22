class_name Ore
extends BaseProp

@export var type : OreType = OreType.IRON

enum OreType {
	IRON,
	TITANIUM,
	SILLICIUM,
	TUNGSTEN
}

@onready var mesh_instance : MeshInstance3D = $MeshInstance3D

var ore_data : Dictionary = {
	OreType.IRON: {
		"display_name": "Iron", 
		"color": Color(0.7, 0.4, 0.3) # Rougeâtre / Rouille
	},
	OreType.SILLICIUM: {
		"display_name": "Sillicium", 
		"color": Color(0.671, 0.667, 0.643, 1.0) # Orange
	},
	OreType.TITANIUM: {
		"display_name": "Titanium", 
		"color": Color(0.382, 0.595, 0.184, 1.0) 
	},
	OreType.TUNGSTEN: {
		"display_name": "Tungsten", 
		"color": Color(0.328, 0.489, 0.945, 1.0) 
	} 
}
var current_name : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data = ore_data[type]
	current_name = data["display_name"]
	_set_ore_color(data["color"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_ore_color(new_color : Color) -> void:
	var new_mat = StandardMaterial3D.new()
	new_mat.albedo_color = new_color

	new_mat.metallic = 0.8
	new_mat.roughness = 0.4

	mesh_instance.material_override = new_mat

func _get_string(ore : OreType) -> String:
	match ore:
		OreType.IRON:
			return "iron"
		OreType.TITANIUM:
			return "titanium"
		OreType.SILLICIUM:
			return "sillicium"
		OreType.TUNGSTEN:
			return "tungsten"
		_:
			return ""
