extends CharacterBody2D
class_name Enemy

@export var points: int = 10
@export var aaSpeed: float = 1.0
@onready var reload_timer: Timer = $AATimer
var projectile = preload("res://scenes/projectile.tscn")

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
	reload_timer.start(aaSpeed)

func _physics_process(delta: float) -> void:
	pass
	
func _shoot():
	# shoot.emit()
	
	var my_projectile = projectile.instantiate()
	my_projectile.rotation = PI
	my_projectile.position = get_parent().position + position
	my_projectile.position.y += 25
	my_projectile.speed = 120
	my_projectile.team = false

	get_tree().get_root().add_child(my_projectile)
	return

func _on_death():
	emit_signal("died", points)
	queue_free()
	
func _on_hit():
	DmgNumbers.display_number(points, self.global_position)
	_on_death()
	return
	
func _get_team() -> bool:
	return false

func _on_aa_timer_timeout() -> void:
	_shoot()
