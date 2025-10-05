extends Node

class_name MiningBlock

enum MiningBlockType{
	NONE,
	STANDARD,
	INDESTRUCTIBLE = 100,
}

signal mine
signal destroy

var health: int = 5
var position: Vector2

func _init(world_position: Vector2) -> void:
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
