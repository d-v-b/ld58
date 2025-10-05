extends ColorRect
class_name destruction_particle

var velocity : Vector2
var drag = 0.9
var lifetime : float
var opaqueness = 1.0

func _init(colour : Color) -> void:
	color = colour * randf() * 2.0

func _ready() -> void:
	size = Vector2(12, 12) * randf()
	velocity = Vector2(randi_range(-100, 100), randi_range(0, 500))
	z_index = -1
	
func _process(delta: float) -> void:
	global_position += velocity * delta
	velocity.y += 980 * delta
	velocity.x *= pow(drag, delta * 60.0)
	opaqueness -= 2.5 * delta
	color.a = opaqueness
	if opaqueness <= 0:
		queue_free()
