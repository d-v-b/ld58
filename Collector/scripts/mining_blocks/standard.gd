class_name MiningBlockStandard extends MiningBlock

func _init(_world : World2D, world_position: Vector2, _tile_position: Vector2i) -> void:
	super._init(_world, world_position, _tile_position)
	health = 1
