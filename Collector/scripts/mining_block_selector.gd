extends Node

class_name MiningBlockSelector

signal change_current

var current: MiningBlock:
	get:
		return current
	set(block):
		if block == current:
			return
		if current: current.destroy.disconnect(_on_destroy_current)
		current = block
		if current: current.destroy.connect(_on_destroy_current)
		change_current.emit()

func _on_destroy_current() -> void:
	current = null

func _on_change_current() -> void:
	if current:
		$Overlay.global_position = current.position
		$Overlay.visible = true
	else:
		$Overlay.visible = false
