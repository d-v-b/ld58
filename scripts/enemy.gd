extends CharacterBody2D

@export var speed: int

const ORIGIN = Vector2(-250, -128)
const BOUNDARIES = [-250, 250]

func _ready() -> void:
	position = ORIGIN

func _physics_process(delta: float) -> void:
	get_direction()
	move_and_collide(velocity * speed * delta)

var direction = 1
func get_direction() -> void:
	if position.x < BOUNDARIES.min():
		direction = 1
	elif position.x > BOUNDARIES.max():
		direction = -1
	velocity.x = move_toward(velocity.x, direction, speed)

# Note: temporary, needed for scene deletion?
func _on_death():
	queue_free()
