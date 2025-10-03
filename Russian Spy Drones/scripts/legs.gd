extends AnimatedSprite2D

var player : gamejam_player

func _ready() -> void:
	player = get_parent()
	
func _process(delta: float) -> void:
	speed_scale = player.direction
	if player.direction == 0.0:
		speed_scale = sin(Time.get_ticks_msec() * 0.001)
