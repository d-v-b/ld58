extends AnimatedSprite2D

var player : gamejam_player

func _ready() -> void:
	player = get_parent()
	if player and player.has_signal("mine_signal"):
		player.connect("mine_signal", Callable(self, "_do_mine"))
		
	connect("animation_finished", Callable(self, "_on_animation_finish"))
	
func _process(delta: float) -> void:
	if not player:
		return

	var new_anim = "idle" if player.direction == 0.0 else "run"
	
	if player.direction != 0 and sign(player.direction) != sign(player.velocity.x):
		new_anim = "hard_turn"
	
	if !player.is_on_floor() and !player.is_on_wall(): new_anim = "jump"
	
	if player.is_on_wall_only(): new_anim = "climb"

	if animation!= "mine" && animation != new_anim:
		if (new_anim == "hard_turn"): _do_hard_turn(player.direction)
		animation = new_anim
		play()  # explicitly start playback (optional but safe)
	
	if player.direction == -1:
		flip_h = true
	elif player.direction == 1:
		flip_h = false
		
func _on_animation_finish():
	if animation == "mine":
		animation = "idle"
		play()
	return
		
func _do_mine():
	if animation != "mine":
		animation = "mine"
		play()



func _do_hard_turn(direction):
	var turn_sprite = AnimatedSprite2D.new()
	turn_sprite.sprite_frames = preload("res://assets/turn_frames.tres")
	turn_sprite.position.x += -16 * direction
	if direction < 0:
		turn_sprite.flip_h = true
	
	get_tree().current_scene.add_child(turn_sprite)
	turn_sprite.scale = Vector2(4.0, 4.0)
	turn_sprite.global_position = global_position + Vector2((-85 * direction), 0.0)
	turn_sprite.connect("animation_finished", Callable(turn_sprite, "queue_free"))
	turn_sprite.play("turn")
