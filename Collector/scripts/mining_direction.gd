extends RayCast2D

@export var mining_length: int = 100
@export var block_selector: MiningBlockSelector

func _process(delta: float) -> void:
	var mouse_pos := get_local_mouse_position()
	target_position = mouse_pos.normalized() * mining_length
	
	var collider := get_collider()
	
	var corrected_collision_point := correct_collision_point(get_collision_point())
	
	var block = collider.get_grid_cell(collider.position_world_to_grid(corrected_collision_point)) if collider is WorldTile else null
	block_selector.current = block
	
func correct_collision_point(collision_point: Vector2, correction_factor: float = 0.1) -> Vector2:
	var corrected_collision_point: Vector2
	corrected_collision_point.x = (collision_point.x - correction_factor) if collision_point.x < get_parent().position.x else (collision_point.x + correction_factor)
	corrected_collision_point.y = (collision_point.y - correction_factor) if collision_point.y < get_parent().position.y else (collision_point.y + correction_factor)
	return corrected_collision_point
