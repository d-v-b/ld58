extends Node2D

var speed = -40

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	var window_size = get_viewport().get_visible_rect().size
	if (position.y > window_size.y * 0.5 or position.y < window_size.y * -0.5):
		queue_free()
	position.y += speed * delta

func _on_area_entered(object: CollisionObject2D):
	print("collision detected")
