extends CharacterBody2D
class_name gamejam_player

signal died
@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration = 800.0
@export var friction := 800.0
@export var wall_friction := 400.0
@export var wall_jumps : int = 1

var wall_jumps_since_floor = 0

var is_dead = false
var direction = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal change_direction

func _physics_process(delta):
	if is_on_floor(): wall_jumps_since_floor = 0
	
	if not is_dead:
		if not is_on_floor():
			if is_on_wall():
				velocity.y += (gravity - wall_friction) * delta 
			else:
				velocity.y += gravity * delta
			

		if direction != Input.get_axis("move_left", "move_right"):
			direction = Input.get_axis("move_left", "move_right")

		velocity.x = clamp(velocity.x + acceleration * delta * direction, -speed, speed)
		
		if direction == 0:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

		if Input.is_action_just_pressed("action_jump") and (is_on_floor() or is_on_wall()):
			if not is_on_floor() and wall_jumps_since_floor < wall_jumps:
				wall_jumps_since_floor += 1
				velocity.y = jump_velocity * 0.65
				velocity += get_wall_normal() * jump_velocity * -0.35
			elif is_on_floor():
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
	
