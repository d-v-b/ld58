extends Area2D

@onready var anim = $AnimatedSprite2D

var age = 0
var hud
var start_pos
var end_pos
var flying : bool = false
var velocity

func _ready() -> void:
	anim.play("Idle")
	start_pos = position
	
	hud = get_node("../../HUD")
	


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not flying:
		anim.play("Collected")
		_fly_to_bag()
		await anim.animation_finished
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
