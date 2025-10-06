extends Node2D

@onready var player = $Player
@onready var death_overlay = $DeathOverlay

@export var diamonds = 10

var diamonds_collected = 0
#var score = 0


func _ready():
	if player:
		player.died.connect(_on_player_died)
	else:
		push_error("Player node not found!")

	death_overlay.visible = false

	# Connect button signals
	$"DeathOverlay/Menu/VBoxContainer/Play again".pressed.connect(_on_play_again_pressed)
	$"DeathOverlay/Menu/VBoxContainer/Go to main menu".pressed.connect(_on_main_menu_pressed)

func _on_player_died():
	print('the player died')

	# Reveal all bombs
	var tile_map = $TileMapLayer
	if tile_map and tile_map.has_method("reveal_all_bombs"):
		tile_map.reveal_all_bombs()

	show_death_screen()

func show_death_screen():
	# Show the death overlay
	death_overlay.visible = true

	# Optional: Fade in the background
	var background = $DeathOverlay/Menu/MenuBackground
	background.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(background, "modulate:a", 1.0, 0.5)

	# Optional: Pause the game
	# get_tree().paused = true

func _on_play_again_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
