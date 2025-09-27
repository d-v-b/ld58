extends Node2D

@export var enemy_scene: PackedScene

func _ready() -> void:
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
