extends Area2D

@onready var anim = $AnimatedSprite2D

var score = 70

func _ready() -> void:
	anim.play("Idle")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Globals.add_score(score)
		
		# Create score popup
		var popup = Label.new()
		popup.text = "+%d" % score
		popup.add_theme_font_size_override("font_size", 24)
		popup.add_theme_color_override("font_color", Color(0.0, 0.85, 0.85))
		popup.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		popup.add_theme_constant_override("outline_size", 2)
		popup.position = global_position # Above cell
		popup.z_index = 10

		var script = load("res://scripts/score_popup.gd")
		popup.set_script(script)

		get_tree().root.add_child(popup)
		anim.play("Collected")
		await anim.animation_finished
		queue_free()
		# get_node("/root/Main").diamonds_collected += 1
		
