extends Camera2D

@export var SHAKE_SPEED: float = 300.0
@export var SHAKE_STRENGTH: float = 150.0
@export var SHAKE_DECAY_RATE: float = 10.0

@onready var noise := FastNoiseLite.new()
var noise_i: float = 0.0
var strength_i: float = 0.0

func _ready() -> void:
	var rand := RandomNumberGenerator.new()
	rand.randomize()
	noise.seed = rand.randi()

func _process(delta: float) -> void:
	strength_i = lerp(strength_i, 0.0, SHAKE_DECAY_RATE * delta)
	offset = get_noise_offset(delta, SHAKE_SPEED, strength_i)
	
func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength,
	)
	
func shake_screen(strength: float = SHAKE_STRENGTH):
	strength_i = strength
