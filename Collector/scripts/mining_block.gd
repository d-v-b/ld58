extends Node2D

signal mine
signal destroy

@export var health: int = 5

func _on_mine() -> void:
	reduce_health()
	
func _on_destroy() -> void:
	queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("action_mine"):
		mine.emit()

func reduce_health(value: int = 1):
	health -= value
	if health <= 0:
		destroy.emit()
