extends Node2D

@export var enemy_line_scene: PackedScene

var score = 0
var lives = 3
var window_size = Vector2()

func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	get_tree().node_added.connect(_on_node_added)
	EnemyLine.Spawn(self)

func _on_node_added(node: Node) -> void:
	if node is Enemy:
		node.died.connect(_on_enemy_died)

func _on_enemy_died(points: int) -> void:
	score += points

func _on_timer_timeout() -> void:
	EnemyLine.Spawn(self)
