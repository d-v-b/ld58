extends ProgressBar

func _ready():
	var player = get_node("/root/Game/Player")
	if player:
		max_value = player.max_ammo
		player.connect("shoot", Callable(self, "_update_bar"))
		player.connect("reload", Callable(self, "_update_bar"))
		_update_bar()

func _update_bar() -> void:
	value = get_node("/root/Game/Player").current_ammo
	
