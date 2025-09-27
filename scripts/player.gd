extends CharacterBody2D
class_name gamejam_player

const SPEED = 100.0
const RELOAD_TIME = 1.0


var projectile = preload("res://scenes/projectile.tscn")
var last_shot = 1000.0
var direction = 0; #left = -1, right = 1

signal shoot


func _ready() -> void:
	var window_size = get_viewport().get_visible_rect().size * 0.5
	position.y = (window_size.y * 0.5) - 50
	print(window_size.y, " ", position.y)
	
func _shoot() -> void:
	if last_shot < RELOAD_TIME: return
	
	shoot.emit()
	var my_projectile = projectile.instantiate() as Node2D
	my_projectile.position = position
	my_projectile.position.y += -50
	get_tree().get_root().add_child(my_projectile)
	last_shot = 0.0
	return
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		_shoot()

func _physics_process(delta: float) -> void:
	last_shot += delta
	
	var window_size = get_viewport().get_visible_rect().size * 0.5
	var movement;
	
	direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		movement = direction * SPEED * delta
		var new_position = position.x + movement
		position.x = clamp(new_position, -window_size.x * 0.5, window_size.x * 0.5)
