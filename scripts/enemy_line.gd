extends CharacterBody2D

@export var enemy_scene: PackedScene
@export var enemy_padding: int = 1
@export var enemy_number: int = 10
@export var enemy_speed: int = 100
@export var enemy_speed_increment: int = 30
@export var side_padding: int = 20

var boundaries = Array()

signal end_of_line
signal end_of_cycle

func _ready() -> void:
	position = Vector2(0, -250)
	var line_size: Vector2
	for n in enemy_number:
		var enemy = init_enemy(n)
		line_size.x += enemy.width + enemy_padding
		line_size.y = enemy.height
		add_child(enemy)
	set_shape(line_size)
	set_boundaries()
	
func init_enemy(n: int) -> Enemy:
		var enemy = enemy_scene.instantiate()
		var origin = Vector2(-(((enemy.width + enemy_padding) * enemy_number) / 2) + (enemy.width / 2), 0)
		origin.x += (enemy.width + enemy_padding) * n
		enemy.set_origin(origin)
		return enemy

func set_shape(line_size: Vector2) -> void:
	$LineShapeCollisionBox.shape.size = line_size
	
func set_boundaries() -> void:
	var window_size = get_node("/root/Game").window_size / 2
	var offset = ($LineShapeCollisionBox.shape.size.x / 2) + side_padding
	boundaries = [-(window_size.x - offset), (window_size.x - offset)]

func _physics_process(delta: float) -> void:
	get_direction()
	velocity.x = move_toward(velocity.x, direction, enemy_speed)
	move_and_collide(velocity * enemy_speed * delta)

func get_direction() -> void:
	if position.x < boundaries.min():
		end_of_line.emit()
		end_of_cycle.emit()
	elif position.x > boundaries.max():
		end_of_line.emit()

var direction = 1
func _on_end_of_line() -> void:
	direction *= -1
	position.y += $LineShapeCollisionBox.shape.size.y / 2

func _on_end_of_cycle() -> void:
	enemy_speed += enemy_speed_increment
