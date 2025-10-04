extends AnimatedSprite2D

var player : gamejam_player

func _ready() -> void:
	player = get_parent()
	
func _process(delta: float) -> void:
	if not player:
		return

	var new_anim = "idle" if player.direction == 0.0 else "run"
	
	if !player.is_on_floor(): new_anim = "jump"

	if animation != new_anim:
		print(animation)
		animation = new_anim
		play()  # explicitly start playback (optional but safe)
	
	if player.direction == -1:
		flip_h = true
	elif player.direction == 1:
		flip_h = false
