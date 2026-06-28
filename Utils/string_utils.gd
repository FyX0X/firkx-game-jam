class_name StringUtils


static func get_pretty_string(item_id: String) -> String:
	var words := item_id.split("_")

	for i in words.size():
		words[i] = words[i].capitalize()

	return " ".join(words)


static func format_time_m_s_ms(time_s: float) -> String:
	var total_seconds: int = floori(time_s)
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	var millis: int = round((time_s - total_seconds) * 1000)
	return "%02d:%02d:%03d" % [minutes, seconds, millis]


static func format_time_m_s(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60

	return "%02d:%02d" % [minutes, seconds]
