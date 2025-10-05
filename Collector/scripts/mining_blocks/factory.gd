extends RefCounted

class_name MiningBlockFactory

static func create(type: MiningBlock.MiningBlockType, world: World2D, world_position: Vector2, tile_position: Vector2i):
	if type == MiningBlock.MiningBlockType.STANDARD:
		return MiningBlockStandard.new(world, world_position, tile_position)
	if type == MiningBlock.MiningBlockType.BOMB:
		return MiningBlockBomb.new(world, world_position, tile_position)
	return MiningBlock.new(world, world_position, tile_position)
