extends CharacterBody2D

@export var enemy_scene: PackedScene
@export var enemy_padding: int = 1
@export var enemy_number: int = 10
@export var enemy_speed: int = 100
@export var side_padding: int = 20

var boundaries = Array()

func _ready() -> void:
	position = Vector2(0, -250)
	var line_size: Vector2
	for n in enemy_number:
		var enemy = enemy_scene.instantiate()
		var origin = Vector2(-(((enemy.width + enemy_padding) * enemy_number) / 2) + (enemy.width / 2), 0)
		origin.x += (enemy.width + enemy_padding) * n
		enemy.set_origin(origin)
		add_child(enemy)
		line_size.x += enemy.width + enemy_padding
		line_size.y = enemy.height
	set_shape(line_size)
	set_boundaries()

func set_shape(line_size: Vector2) -> void:
	$LineShapeCollisionBox.shape.size = line_size
	
func set_boundaries() -> void:
	var window_size = get_node("/root/Game").window_size / 2
	var offset = ($LineShapeCollisionBox.shape.size.x / 2) + side_padding
	boundaries = [-(window_size.x - offset), (window_size.x - offset)]

func _physics_process(delta: float) -> void:
	get_direction()
	move_and_collide(velocity * enemy_speed * delta)

var direction = 1
func get_direction() -> void:
	if position.x < boundaries.min():
		direction = 1
	elif position.x > boundaries.max():
		direction = -1
	velocity.x = move_toward(velocity.x, direction, enemy_speed)
