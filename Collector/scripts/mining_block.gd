extends Node

class_name MiningBlock

signal select(bool)
signal mine
signal destroy

var health: int = 5
var position: Vector2

func _init(world_position: Vector2) -> void:
	position = world_position

func _on_mine() -> void:
	reduce_health()
	
func _on_destroy() -> void:
	queue_free()

func _on_select(is_selected: bool) -> void:
	pass

func reduce_health(value: int = 1):
	health -= value
	if health <= 0:
		destroy.emit()

func selected(is_selected: bool):
	select.emit(is_selected)
