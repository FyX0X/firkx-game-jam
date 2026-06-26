extends Drill


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	remove_from_group("electrical")
	set_type("broken")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
