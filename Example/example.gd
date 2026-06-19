extends Node2D

var shown: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.hide();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Sprite2D.visible = shown;
	shown = !shown;
