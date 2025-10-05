extends Label

func update_count(bombs_nearby: int) -> void:
	text = str(bombs_nearby)
	
	match bombs_nearby:
		0:
			modulate = Color.GREEN
		1:
			modulate = Color.GREEN_YELLOW
		2:
			modulate = Color.YELLOW
		3:
			modulate = Color.RED
		4:
			modulate = Color.PURPLE
		_:
			modulate = Color.GRAY
