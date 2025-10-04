extends Node2D

class_name MiningBlock

signal select(bool)
signal mine
signal destroy

@export var health: int = 5

func _on_mine() -> void:
	reduce_health()
	
func _on_destroy() -> void:
	queue_free()

func _on_select(is_selected: bool) -> void:
	highlight(is_selected)

func reduce_health(value: int = 1):
	health -= value
	print("Mining block with health:", health)
	if health <= 0:
		destroy.emit()

func highlight(visibility: bool = true):
	$Overlay.visible = visibility

func selected(is_selected: bool = false):
	select.emit(is_selected)
