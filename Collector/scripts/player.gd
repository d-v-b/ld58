extends CharacterBody2D

@export var speed = 300.0

func _ready():
	var collision_shape = $CollisionShape2D
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(40, 40)
	collision_shape.shape = rect_shape


func _physics_process(_delta):
	handle_input()
	move_and_slide()

func handle_input():
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
