extends CharacterBody2D

@export var impulse_strength = 500.0
@export var friction = 0.9

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	var collision_shape = $CollisionShape2D
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(40, 40)
	collision_shape.shape = rect_shape

	# Add to player group so mining blocks can find us
	add_to_group("player")

func _physics_process(delta):
	# Handle mouse input first, before physics
	handle_mouse_input()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Apply friction when on the ground
		velocity.x *= friction

	move_and_slide()

	# Handle collisions and bounce off mining blocks
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Only bounce off mining blocks
		if collider and collider.name == "MiningBlock":
			var normal = collision.get_normal()
			velocity = velocity.bounce(normal)

func handle_mouse_input():
	if Input.is_action_just_pressed("action_mine"):
		# Check if we clicked on a mining block
		var space_state = get_world_2d().direct_space_state
		var mouse_pos = get_global_mouse_position()
		var query = PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		var result = space_state.intersect_point(query, 1)

		# Only apply impulse if we didn't click on a mining block
		var clicked_mining_block = false
		for hit in result:
			if hit.collider.name == "MiningBlock":
				clicked_mining_block = true
				break

		if not clicked_mining_block:
			var direction = (mouse_pos - global_position).normalized()
			velocity = direction * impulse_strength

func apply_pushback(force: Vector2):
	print("Player received pushback: ", force)
	print("Velocity before: ", velocity)
	velocity += force
	print("Velocity after: ", velocity)
