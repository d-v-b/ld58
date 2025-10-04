extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	var collision_shape = $CollisionShape2D
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(40, 40)
	collision_shape.shape = rect_shape

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	handle_input()
	move_and_slide()

func handle_input():
	var input_dir = 0
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir += 1
	
	if input_dir != 0:
		velocity.x = input_dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
