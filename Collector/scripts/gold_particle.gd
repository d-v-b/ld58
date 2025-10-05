extends ColorRect
class_name gold_particle

var lifetime : float = 10
var age : float
var opaqueness = 1.0
var HUD : CanvasLayer

var start_pos : Vector2
var end_pos

var starting_velocity : Vector2
var velocity : Vector2


func _init(colour : Color, _start_pos : Vector2, _end_pos : Vector2) -> void:
	color = colour# * (randf() - 0.5)
	color.a = 1.0
	start_pos = _start_pos
	end_pos = _end_pos

func _ready() -> void:
	size = Vector2(5, 5) * (randf() + 0.5)
	starting_velocity = Vector2(randi_range(-500, 500), randi_range(-500, 500))
	position = start_pos
	z_index = 2
	
func _physics_process(delta: float) -> void:
	age += delta

	var to_bag = end_pos - position
	var total_dist = (end_pos - start_pos).length()
	var current_dist = to_bag.length()
	
	var distance_to_end = (end_pos - position).length()
	if (distance_to_end < 30):
		queue_free()
	
	# progress (0 at start, 1 at end)
	var t = clamp(1.0 - (current_dist / total_dist), 0.0, 1.0)

	# bell-shaped scale: 1 → 2 → 1
	var scale_factor := 1.0 + sin(t * PI)  # sin(0)=0, sin(PI)=0, sin(PI/2)=1
	scale = Vector2.ONE * scale_factor

	# --- movement logic ---
	var direction_to_bag = to_bag.normalized() * 1000.0
	velocity = lerp(starting_velocity, direction_to_bag, min(1.0, age))
	position += velocity * delta

	if age > 3.0:
		queue_free()
