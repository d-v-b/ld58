extends Area2D

var speed = -120

func _ready():
	connect("body_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	var window_size = get_viewport().get_visible_rect().size
	if (position.y > window_size.y * 0.5 or position.y < window_size.y * -0.5):
		queue_free()
	position.y += speed * delta

func _on_area_entered(object: CollisionObject2D):
	if object.has_method("_on_hit"):
		object._on_hit()
		queue_free()
