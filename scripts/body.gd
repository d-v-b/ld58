extends AnimatedSprite2D

var player : gamejam_player

func _ready() -> void:
	player = get_parent()
	player.shoot.connect(on_shoot)
	connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func on_shoot():
	animation = "shoot"	
	
func _process(delta: float) -> void:
	return

func _on_animation_finished() -> void:
	print("hi")
	if animation == "shoot":
		animation = "idle"
		play()
