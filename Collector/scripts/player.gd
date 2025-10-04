extends CharacterBody2D
class_name gamejam_player

@export var speed = 300.0
@export var jump_velocity = -400.0

var direction = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal change_direction

func _physics_process(delta):
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
	
	#handle_input()
	move_and_slide()

#func handle_input():
	#var input_dir = 0
	#if Input.is_action_pressed("ui_left"):
		#input_dir -= 1
		#facing = -1
	#if Input.is_action_pressed("ui_right"):
		#input_dir += 1
		#facing = 1
	#
	#if input_dir != 0:
		#velocity.x = input_dir * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
