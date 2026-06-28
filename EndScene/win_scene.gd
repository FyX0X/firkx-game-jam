extends EndScene


@onready var speedrun_label: Label = $SpeedrunLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	speedrun_label.text = "Finish time: " + StringUtils.format_time_m_s_ms(Stats.finish_time)
