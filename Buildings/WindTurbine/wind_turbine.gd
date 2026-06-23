extends Building

@onready var anim : AnimationPlayer = find_child("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	energy = 5
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if not is_hologram and not anim.is_playing():
		anim.play("eliceanimAction")
	pass
