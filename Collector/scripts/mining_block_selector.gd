extends Node

class_name MiningBlockSelector

signal change_current

var _current: MiningBlock
var current: MiningBlock:
	get:
		return _current
	set(block):
		if block == _current:
			return
		if _current:
			_current.selected(false)
		if block:
			block.selected(true)
		_current = block
		change_current.emit()

func _on_change_current() -> void:
	if current:
		$Overlay.global_position = current.position
		$Overlay.visible = true
	else:
		$Overlay.visible = false
