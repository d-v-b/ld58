extends CharacterBody2D
class_name gamejam_player

@export var window_padding: int
@export var speed: int
@export var reload_time: float
@export var last_shot: float


var projectile = preload("res://scenes/projectile.tscn")
var direction = 0; #left = -1, right = 1

signal shoot

var __window_size: Vector2
var window_size: Vector2:
	get:
		if not __window_size: __window_size = get_node("/root/Game").window_size / 2
		return __window_size

func _init() -> void:
	pass

func _ready() -> void:
	pass
	
func _shoot() -> void:
	if last_shot < reload_time: return
	
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
	direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		var movement = direction * speed * delta
		var new_position = position.x + movement
		position.x = clamp(new_position, -(window_size.x - window_padding), (window_size.x - window_padding))
