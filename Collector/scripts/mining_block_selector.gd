extends Node

class_name MiningBlockSelector

signal change_current

@export var overlay_color: Color
@export var overlay_fill_alpha: float = 0.4
@export var overlay_border_alpha: float = 0.8

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

func _ready() -> void:
	$Overlay/Fill.color = Color(overlay_color, overlay_fill_alpha)
	$Overlay/Border.default_color = Color(overlay_color, overlay_border_alpha)
