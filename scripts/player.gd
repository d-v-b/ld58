extends CharacterBody2D
class_name gamejam_player

@export var window_padding: int
@export var speed: int
@export var shoot_cooldown: float
@export var reload_time: float
@export var last_shot: float
@export var max_ammo: int
@onready var reload_timer: Timer = $ReloadTimer
var current_ammo: int
var projectile = preload("res://scenes/projectile.tscn")
var direction = 0; #left = -1, right = 1
var reloading: bool = false;
var bonus_reloading: bool = false;
var reload_success: bool = false

signal shoot
signal reload

var __window_size: Vector2
var window_size: Vector2:
	get:
		if not __window_size: __window_size = get_node("/root/Game").window_size / 2
		return __window_size

func _init() -> void:
	pass

func _ready() -> void:
	current_ammo = max_ammo
	pass
	
func _shoot() -> void:
	if last_shot < shoot_cooldown or current_ammo <= 0 or reloading == true: return
	
	var volume: float = randi_range(-10, 0)
	$AudioStreamPlayer.volume_db = volume
	$AudioStreamPlayer.play()
	current_ammo -= 1
	shoot.emit()
	var my_projectile = projectile.instantiate() as Node2D
	if reload_success == true:
		my_projectile.scale *= 10.0
	my_projectile.position = position
	my_projectile.position.y += -50
	get_tree().get_root().add_child(my_projectile)
	last_shot = 0.0
	reload_success = false

	return
	
func _reload() -> void:
	if bonus_reloading == true or current_ammo == max_ammo: return
	
	reload_timer.start(reload_time)
	reloading = true
	$ReloadTimerUI.show()
	return
	
func _bonus_reload() -> void:
	if bonus_reloading == true: return
	
	bonus_reloading = true
	if reload_timer.time_left <= reload_time / 4.0:
		reload_success = true
		reload_timer.stop()
		_on_reload_timer_timeout()
		return
	return
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	elif Input.is_action_just_pressed("reload") && reloading == false:
		_reload()
	elif Input.is_action_just_pressed("reload") && reloading == true:
		_bonus_reload()

func _physics_process(delta: float) -> void:
	last_shot += delta
	direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		var movement = direction * speed * delta
		var new_position = position.x + movement
		position.x = clamp(new_position, -(window_size.x - window_padding), (window_size.x - window_padding))

func _process(delta: float) -> void:
	$ReloadTimerUI.value = reload_timer.time_left
	

func _on_reload_timer_timeout() -> void:
	$AudioStreamPlayer2.play()
	current_ammo = max_ammo
	reload.emit()
	reloading = false
	bonus_reloading = false
	$ReloadTimerUI.hide()
