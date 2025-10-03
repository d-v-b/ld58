extends CharacterBody2D

class_name EnemyLine

@export var enemy_scene: PackedScene
@export var enemy_padding: int = 1
@export var enemy_number: int = 3
@export var enemy_speed: int = 100
@export var enemy_speed_increment: int = 30
@export var side_padding: int = 20
@export var bottom_padding: int = 3

var boundaries: Array
var children_count: int = 0

signal end_of_line
signal end_of_cycle
signal enemy_line_empty

static func Spawn(parent: Node2D) -> void:
	var enemy_line := preload("res://scenes/enemy_line.tscn").instantiate()
	parent.add_child(enemy_line)

func _ready() -> void:
	var line_size: Vector2
	for n in enemy_number:
		var enemy = init_enemy(n)
		line_size.x += enemy.width + enemy_padding
		line_size.y = enemy.height
		add_child(enemy)
		children_count += 1
	set_shape(line_size)
	set_boundaries()
	
func init_enemy(n: int) -> Enemy:
		var enemy = enemy_scene.instantiate()
		var origin = Vector2(-(((enemy.width + enemy_padding) * enemy_number) / 2) + (enemy.width / 2), 0)
		origin.x += (enemy.width + enemy_padding) * n
		enemy.set_origin(origin)
		enemy.connect("died", _on_enemy_died_in_line)
		return enemy

func set_shape(line_size: Vector2) -> void:
	$LineShapeCollisionBox.shape.size = line_size

func set_boundaries() -> void:
	var window_size = get_node("/root/Game").window_size / 2
	var offset = ($LineShapeCollisionBox.shape.size.x / 2) + side_padding
	boundaries = [-(window_size.x - offset), (window_size.x - offset)]
	position = Vector2(-(window_size.x - offset), -(window_size.y - 100))

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
	position.y += $LineShapeCollisionBox.shape.size.y + bottom_padding

func _on_end_of_cycle() -> void:
	enemy_speed += enemy_speed_increment

func _on_enemy_died_in_line(points: int) -> void:
	children_count -= 1
	if children_count <= 0:
		enemy_line_empty.emit()

func _on_enemy_line_empty() -> void:
	queue_free()
