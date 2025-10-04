extends Node2D

@onready var camera = $Camera2D
@onready var player = $Player

func _ready():
	pass

func _process(_delta):
	if player:
		camera.global_position = player.global_position