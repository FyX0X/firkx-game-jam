@tool #Dont touch it is for the map import
class_name OreVein
extends Ore

## Do not assign onready in this file use the ready function !!

signal resource_yielded(ore_type: Ore.OreType, amount: int)

@export var total_yield: int = 8

var remaining_yield: int

var ratio = 0.75

var health = 300.0
var current_health = health
var accumulated_damage = 0.0
var damage_threshold : float


func _ready() -> void:
	super()
	remaining_yield = total_yield
	add_to_group("minable")
	$MeshInstance3D.material_override = null
	damage_threshold = health / total_yield
	# si ca crash ici : reimport la map :
	# maptestvolume.glb
	

func yield_resource() -> void:
	if remaining_yield <= 0:
		return
	remaining_yield -= 1
	resource_yielded.emit(_get_string(type), 1)
	_resize()
	if remaining_yield <= 0:
		_deplete()

func _resize():
	var mesh : MeshInstance3D = $MeshInstance3D
	var visual_scale = $MeshInstance3D.scale
	var tween = create_tween()
	var initial_scale = visual_scale
	var new_scale = initial_scale * ratio
	tween.tween_property(mesh,"scale",new_scale,0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(mesh,"scale",initial_scale,0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	

func take_damage_ore(dmg : float):
	current_health -= dmg
	accumulated_damage += dmg
	while accumulated_damage >= damage_threshold:
		accumulated_damage -= damage_threshold
		yield_resource()

func _deplete() -> void:
	# override to do something before freeing
	print("Vein exhausted")
	super()
