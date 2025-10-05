extends RefCounted

class_name MiningBlockFactory

static func create(type: MiningBlock.MiningBlockType, world_position: Vector2):
	if type == MiningBlock.MiningBlockType.STANDARD:
		return MiningBlockStandard.new(world_position)
	return MiningBlock.new(world_position)
