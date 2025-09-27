extends Node2D

@export var enemy_scene: PackedScene

var score = 0
var lives = 3
var window_size = Vector2()

func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
