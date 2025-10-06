extends Node

class_name MiningBlock

enum MiningBlockType{
	NONE,
	STANDARD,
	BOMB,
	INDESTRUCTIBLE = 100,
}

signal mine(score_modifier: int)
signal destroy(score_modifier: int)
signal damaged(current_health: int, max_health: int)

var health: int = 2
var max_health: int = 2
var position: Vector2
var tile_position : Vector2i
var world : World2D

func _init(_world, world_position: Vector2, _tile_position : Vector2i) -> void:
	world = _world
	tile_position = _tile_position
	position = world_position
	mine.connect(_on_mine)
	destroy.connect(_on_destroy)

func _on_mine(score_modifier: int) -> void:
	reduce_health(score_modifier)
	
func _on_destroy(_score_modifier: int) -> void:
	queue_free()

func reduce_health(score_modifier: int, value: int = 1):
	health -= value
	if health <= 0:
		destroy.emit(score_modifier)
	else:
		damaged.emit(health, max_health)
