extends CharacterBody2D
class_name gamejam_player

signal died
@export var speed = 300.0
@export var jump_velocity = -400.0

var direction = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal change_direction

func _physics_process(delta):
	if not is_dead:
		if not is_on_floor():
			velocity.y += gravity * delta
		
		if direction != Input.get_axis("move_left", "move_right"):
			direction = Input.get_axis("move_left", "move_right")

		velocity.x = direction * speed
		
		if Input.is_action_just_pressed("action_jump") and is_on_floor():
			velocity.y = jump_velocity
			
		if Input.is_action_just_pressed("action_mine"):
			if $MiningBlockSelector.current:
				$MiningBlockSelector.current.mine.emit()
		
		if Input.is_action_just_pressed("action_die"):
			die()
		move_and_slide()

func die():
	is_dead = true
	died.emit()
	%AnimationPlayer.play("player_death")
	#handle_input()
	move_and_slide()
