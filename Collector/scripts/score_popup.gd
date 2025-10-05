extends Label

var velocity := Vector2(0, -50)  # Float upward
var lifetime := 1.5
var fade_start := 0.5
var elapsed_time := 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	elapsed_time += delta

	# Move upward
	position += velocity * delta

	# Fade out after fade_start time
	if elapsed_time > fade_start:
		var fade_progress = (elapsed_time - fade_start) / (lifetime - fade_start)
		modulate.a = 1.0 - fade_progress

	# Delete when lifetime expires
	if elapsed_time >= lifetime:
		queue_free()
