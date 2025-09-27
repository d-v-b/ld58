extends CharacterBody2D


const SPEED = 100.0

func _ready() -> void:
	var window_size = get_viewport().get_visible_rect().size * 0.5
	position.y = (window_size.y * 0.5) - 10
	print(window_size.y, " ", position.y)
	
func _shoot() -> void:
	return
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		_shoot()

func _physics_process(delta: float) -> void:
	var window_size = get_viewport().get_visible_rect().size * 0.5
	var movement;
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		movement = direction * SPEED * delta
		var new_position = position.x + movement
		position.x = clamp(new_position, -window_size.x * 0.5, window_size.x * 0.5)
