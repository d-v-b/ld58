extends RayCast2D

@export var mining_length: int = 100
@export var block_selector: MiningBlockSelector

func _process(delta: float) -> void:
	var mouse_pos := get_local_mouse_position()
	target_position = mouse_pos.normalized() * mining_length
	var collider := get_collider()
	if collider and collider is MiningBlock:
		block_selector.current = collider
	else:
		block_selector.current = null
