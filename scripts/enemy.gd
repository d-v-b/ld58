extends CharacterBody2D

const SPEED = 100
const RANGE = 100
const ORIGIN = Vector2(-250, -128)

func _ready() -> void:
	position = ORIGIN

func _physics_process(delta: float) -> void:
	get_direction()
	move_and_collide(velocity * delta)

func get_direction() -> void:
	velocity.x = move_toward(velocity.x, RANGE, SPEED)

# Note: temporary, needed for scene deletion?
func _on_death():
	queue_free()
