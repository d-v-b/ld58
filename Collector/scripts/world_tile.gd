extends TileMapLayer

class_name WorldTile

const _size = Vector2i(64, 64)

var grid := []

func _ready() -> void:
	for x in _size.x:
		grid.append([])
		for y in _size.y:
			var _cell = WorldCell.new()
			
			if randi_range(0, 4) == 0:
				set_cell(Vector2i(x, y), -1, Vector2i(-1, -1))
				_cell.value = 0
			else:
				set_cell(Vector2i(x, y), 1, Vector2i(1, 2))
				_cell.value = 1
			
			_cell.position = Vector2i(x, y)
			_cell.world_position = position_grid_to_world(_cell.position)
			grid[x].append(_cell)

func position_grid_to_world(grid_position: Vector2i) -> Vector2:
	var world_position := Vector2(grid_position * tile_set.tile_size + tile_set.tile_size / 2)
	return world_position

func position_world_to_grid(world_position: Vector2) -> Vector2i:
	var grid_position = Vector2i(world_position) / tile_set.tile_size
	var cell = grid[grid_position.x][grid_position.y]
	if cell:
		cell.build()
	return grid_position
	
func get_grid_cell(grid_position: Vector2i) -> MiningBlock:
	return grid[grid_position.x][grid_position.y].mining_block
