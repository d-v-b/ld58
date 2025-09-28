extends CharacterBody2D
class_name Enemy

@export var speed: int
@export var window_padding: int
@export var points: int = 100

const ORIGIN = Vector2(-250, -128)
var boundaries = Array()

signal died(points: int)

func _ready() -> void:
	position = ORIGIN
	var window_size = get_node("/root/Game").window_size / 2
	boundaries = [-(window_size.x - window_padding), (window_size.x - window_padding)]

func _physics_process(delta: float) -> void:
	get_direction()
	move_and_collide(velocity * speed * delta)

var direction = 1
func get_direction() -> void:
	if position.x < boundaries.min():
		direction = 1
	elif position.x > boundaries.max():
		direction = -1
	velocity.x = move_toward(velocity.x, direction, speed)

# Note: temporary, needed for scene deletion?
func _on_death():
	emit_signal("died", points)
	queue_free()
	
func _on_hit():
	_on_death()
	return
