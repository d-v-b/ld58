extends CharacterBody2D
class_name Enemy

@export var points: int = 100

var origin: Vector2

var width: int:
	get: return $Collision.shape.get_rect().size.x
		
var height: int:
	get: return $Collision.shape.get_rect().size.y

signal died(points: int)
	
func set_origin(arg: Vector2):
	origin = arg

func _ready() -> void:
	position = origin

func _physics_process(delta: float) -> void:
	pass

func _on_death():
	emit_signal("died", points)
	queue_free()
	
func _on_hit():
	DmgNumbers.display_number(points, self.global_position)
	_on_death()
	return
