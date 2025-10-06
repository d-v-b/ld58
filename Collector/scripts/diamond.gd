extends Area2D

@onready var anim = $AnimatedSprite2D

var age = 0
var hud
var start_pos
var end_pos
var flying : bool = false
var velocity
var score = 70

func _ready() -> void:
	anim.play("Idle")
	start_pos = position
	
	hud = get_node("../../HUD")
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not flying:

		
		# Create score popup
		var popup = Label.new()
		popup.text = "+0:20.0\n+%d" % score
		popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		popup.add_theme_font_size_override("font_size", 48)
		popup.add_theme_color_override("font_color", Color(0.0, 0.85, 0.85))
		popup.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		popup.add_theme_constant_override("outline_size", 2)
		popup.position = global_position # Above cell
		popup.z_index = 10

		var script = load("res://scripts/score_popup.gd")
		popup.set_script(script)

		get_tree().root.add_child(popup)

		anim.play("Collected")
		_fly_to_bag()
		await anim.animation_finished
		
		var timer = get_node("../../SuddenDeath")
		timer.start(timer.time_left + 20)
		
		queue_free()
		
		
func _fly_to_bag():
	if flying: return
	flying = true
	age = 0
	var bag = hud.get_node("Canvas/Bag/Bag_Hole") as Control
	end_pos = Vector2(bag.global_position)
	
	
	var particle = diamond_particle.new(get_canvas_transform().origin + global_position, end_pos)
	particle.value = 70
	hud.add_child(particle)
	

		
func _physics_process(delta: float) -> void:
	if !flying:
		age += delta * 4;
		position.y = start_pos.y + (sin(age) * 3)
