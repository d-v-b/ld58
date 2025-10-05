extends RefCounted

class_name WorldCell

signal destroyed(Vector2i)

var value = 0 # 1 = dirt, 2 = stone
var is_bomb = false
var position: Vector2i
var world_position: Vector2
var mining_block: MiningBlock
var world : World2D
var tile_map : TileMapLayer

var tile_highlight = load("res://scenes/mining_block_selector.tscn")
var tile_diamond = load("res://scenes/diamond.tscn")

func _init(_world : World2D, _tile_map):
	tile_map = _tile_map
	world = _world

func build() -> void:
	if value == -1:
		var diamond = tile_diamond.instantiate()
		diamond.position = world_position
		tile_map.add_child(diamond)
		return

	if value == 0 or mining_block:
		return
	
	if is_bomb:
		mining_block = MiningBlockFactory.create(MiningBlock.MiningBlockType.BOMB, world, world_position, position)
		var mining_block_selector = tile_highlight.instantiate()
		mining_block_selector.overlay_color = Color(1, 0, 0)
		mining_block_selector.current = mining_block
		tile_map.add_child(mining_block_selector)
		mining_block_selector.get_child(0).visible = false
	else:
		mining_block = MiningBlockFactory.create(MiningBlock.MiningBlockType.STANDARD, world, world_position, position)
	
	mining_block.destroy.connect(_on_destroy)

func destroy() -> void:	
	if value == 0 or not mining_block: return
	
	for i in 32:
		var color = Color(0.404, 0.275, 0.239) if value == 1 else Color(0.392, 0.408, 0.427, 1.0)
		var particle = destruction_particle.new(color)
		particle.global_position = world_position + Vector2(randi_range(-32, 32), randi_range(-32, 32))
		tile_map.add_child(particle)
		
	value = 0
	mining_block.destroy.disconnect(_on_destroy)
	mining_block = null
	destroyed.emit(position)

func _on_destroy() -> void:
	destroy()
