extends RefCounted

class_name WorldCell

signal destroyed(Vector2i)

var value = 0
var position: Vector2i
var world_position: Vector2
var mining_block: MiningBlock

func build() -> void:
	if value == 0 or mining_block: return
	mining_block = MiningBlockFactory.create(MiningBlock.MiningBlockType.STANDARD, world_position)
	mining_block.destroy.connect(_on_destroy)

func destroy() -> void:
	if value == 0 or not mining_block: return
	value = 0
	mining_block.destroy.disconnect(_on_destroy)
	mining_block = null
	destroyed.emit(position)

func _on_destroy() -> void:
	destroy()
