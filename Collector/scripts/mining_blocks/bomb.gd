class_name MiningBlockBomb extends MiningBlock

var explosion_radius = 1280;

func _init(_world : World2D, world_position: Vector2, _tile_position: Vector2i) -> void:
	super._init(_world, world_position, _tile_position)

func _on_destroy(score_modifier: int) -> void:
	print("BANG")
	
	# Define the explosion shape — e.g., a circular area
	var shape := CircleShape2D.new()
	shape.radius = explosion_radius

	# Set up query parameters
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, position) # position the shape at this node
	params.collision_mask = 1  # choose which layers to detect (adjust as needed)
	params.exclude = [self]    # don't detect self

	var space_state = world.direct_space_state
	var results = space_state.intersect_shape(params)

	for result in results:
		var collider = result.get("collider")
		if collider:
			if collider.has_method("on_hit"):
				collider.on_hit()

	super._on_destroy(score_modifier)
