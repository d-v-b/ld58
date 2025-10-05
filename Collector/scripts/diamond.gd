extends Area2D

@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	anim.play("Idle")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		anim.play("Collected")
		await anim.animation_finished
		queue_free()
		get_node("/root/Main").diamonds_collected += 1
		
