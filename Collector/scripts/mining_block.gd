extends Node

class_name MiningBlock

enum MiningBlockType{
	NONE,
	STANDARD,
	BOMB,
	INDESTRUCTIBLE = 100,
}

signal mine
signal destroy
signal damaged(current_health: int, max_health: int)

var health: int = 5
var max_health: int = 5
var position: Vector2
var tile_position : Vector2i
var world : World2D

func _init(_world, world_position: Vector2, _tile_position : Vector2i) -> void:
	world = _world
	tile_position = _tile_position
	position = world_position
	mine.connect(_on_mine)
	destroy.connect(_on_destroy)

func _on_mine() -> void:
	reduce_health()
	
func _on_destroy() -> void:
	queue_free()

func reduce_health(value: int = 1):
	health -= value
	if health <= 0:
		destroy.emit()
	else:
		damaged.emit(health, max_health)
