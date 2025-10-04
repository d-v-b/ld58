extends RefCounted

class_name WorldCell

var value = 0
var position: Vector2i
var world_position: Vector2
var mining_block: MiningBlock

func build() -> void:
	if value == 0 or mining_block: return
	mining_block = MiningBlock.new(world_position)
	return
