extends Node2D

@onready var player = $Player
@onready var death_overlay = $DeathOverlay

@export var diamonds = 10

var diamonds_collected = 0
#var score = 0

var settings_menu_instance = null


func _ready():
	if player:
		player.died.connect(_on_player_died)
	else:
		push_error("Player node not found!")

	death_overlay.visible = false
	
	var timer = $"HUD/Timer"
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	# Connect button signals
	$"DeathOverlay/Menu/VBoxContainer/Play again".pressed.connect(_on_play_again_pressed)
	$"DeathOverlay/Menu/VBoxContainer/Go to main menu".pressed.connect(_on_main_menu_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_settings_menu()

func _on_player_died():
	print('the player died')
	$"HUD/Timer".stop()

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

func toggle_settings_menu() -> void:
	if settings_menu_instance == null:
		# Open settings menu
		var settings_scene = load("res://scenes/settings_menu.tscn")
		settings_menu_instance = settings_scene.instantiate()

		# Create a CanvasLayer to ensure proper positioning
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		add_child(canvas_layer)
		canvas_layer.add_child(settings_menu_instance)

		# Store reference to canvas layer for cleanup
		settings_menu_instance.set_meta("canvas_layer", canvas_layer)

		# Pause the game
		get_tree().paused = true

		# Make sure settings menu and canvas layer are not affected by pause
		canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		settings_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		# Close settings menu
		var canvas_layer = settings_menu_instance.get_meta("canvas_layer")
		canvas_layer.queue_free()
		settings_menu_instance = null

		# Unpause the game
		get_tree().paused = false

func _on_timer_timeout():
	$Player.die()
