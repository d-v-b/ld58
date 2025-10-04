extends CharacterBody2D

signal died
@export var speed = 300.0
@export var jump_velocity = -400.0

var is_dead = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("action_jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_pressed("action_mine"):
		if $MiningBlockSelector.current:
			$MiningBlockSelector.current.mine.emit()
	
	if Input.is_action_just_pressed("action_die"):
		die()
	
	handle_input()
	move_and_slide()

func handle_input():
	if not is_dead:
		var input_dir = 0
		if Input.is_action_pressed("ui_left"):
			input_dir -= 1
		if Input.is_action_pressed("ui_right"):
			input_dir += 1
		if input_dir != 0:
			velocity.x = input_dir * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

func die():
	is_dead = true
	died.emit()
	%AnimationPlayer.play("player_death")
