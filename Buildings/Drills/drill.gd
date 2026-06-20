extends Building

var type : String;
var outputs : Dictionary = {};


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	outputs[type] = 0;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	buffer += process_speed * delta;
	if (buffer >= 1):
		outputs[type] += 1;
		buffer -= 1;
