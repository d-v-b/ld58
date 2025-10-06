extends Sprite2D
class_name diamond_particle

var lifetime : float = 10
var age : float
var HUD : CanvasLayer

var start_pos : Vector2
var end_pos

var starting_velocity : Vector2
var velocity : Vector2

var value = 1


func _init(_start_pos : Vector2, _end_pos : Vector2) -> void:
	start_pos = _start_pos
	end_pos = _end_pos
	texture = load("res://assets/diamond2.png")
	

func _ready() -> void:
	scale = Vector2(4.0, 4.0);
	starting_velocity = Vector2(0, -1000)
	position = start_pos
	z_index = 2
	
func _physics_process(delta: float) -> void:
	age += delta

	var to_bag = end_pos - position
	var total_dist = (end_pos - start_pos).length()
	var current_dist = to_bag.length()
	
	var distance_to_end = (end_pos - position).length()
	if (distance_to_end < 30):
		Globals.add_score(value)
		queue_free()
	
	#progress (0 at start, 1 at end)
	var t = clamp(1.0 - (current_dist / total_dist), 0.0, 1.0)

	#bell-shaped scale: 1 → 2 → 1
	var scale_factor := 1.0 + sin(t * PI)  # sin(0)=0, sin(PI)=0, sin(PI/2)=1
	scale = Vector2.ONE * scale_factor * 1

	# --- movement logic ---
	var direction_to_bag = to_bag.normalized() * 1000.0
	velocity = lerp(starting_velocity, direction_to_bag, min(1.0, age))
	position += velocity * delta


	if age > 3.0:
		Globals.add_score(value)
		queue_free()
