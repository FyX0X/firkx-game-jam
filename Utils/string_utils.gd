class_name StringUtils


static func get_pretty_string(item_id: String) -> String:
	var words := item_id.split("_")

	for i in words.size():
		words[i] = words[i].capitalize()

	return " ".join(words)
