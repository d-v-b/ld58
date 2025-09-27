extends Node2D

@export var enemy_scene: PackedScene

var score = 0
var lives = 3

func _ready() -> void:
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
