extends TileMapLayer

class_name WorldTile

const _size = Vector2i(64, 64)

var grid := []

func _ready() -> void:
	for x in _size.x:
		grid.append([])
		for y in _size.y:
			var _cell = WorldCell.new()
			var material = 1 if (y < 4) else 2
			var rand_value = randi_range(0, 4)
			
			if rand_value == 0:
				#set_cell(Vector2i(x, y), -1, Vector2i(-1, -1))
				_cell.value = 0
			else:
				#set_cell(Vector2i(x, y), 1, Vector2i(1, 2))
				_cell.value = material

			if y == _size.y - 1:
				set_cell(Vector2i(x, y), 1, Vector2i(4, 0)  + choose_air_offset(x, y))
			elif grid[y][x].value == 1:
				set_cell(Vector2i(x, y), 1, Vector2i(1, 2) + choose_tile_offset(x, y))
			elif grid[y][x].value == 2:
				set_cell(Vector2i(x, y), 1, Vector2i(5, 2)  + choose_tile_offset(x, y))
			else:
				set_cell(Vector2i(x, y), 1, Vector2i(4, 0)  + choose_air_offset(x, y))
			
			
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

func choose_tile_offset(x: int, y: int) -> Vector2i:
	var max_y := grid.size() - 1
	if max_y < 0:
		return Vector2i.ZERO
	var max_x = grid[0].size() - 1

	var top_free = y == 0 or (y > 0 and grid[y - 1][x].value == 0)
	var bot_free = y < max_y and grid[y + 1][x].value == 0
	var lft_free = x > 0 and grid[y][x - 1].value == 0
	var rgt_free = x < max_x and grid[y][x + 1].value == 0

	if top_free:
		if lft_free:
			return Vector2i(-1, -1)
		elif not rgt_free:
			return Vector2i(0, -1)
		return Vector2i(1, -1)
	elif bot_free:
		if lft_free:
			return Vector2i(-1, 1)
		elif not rgt_free:
			return Vector2i(0, 1)
		return Vector2i(1, 1)
	elif lft_free:
		return Vector2i(-1, 0)
	elif rgt_free:
		return Vector2i(1, 0)
	return Vector2i(0, 0)
	
func choose_air_offset(x: int, y: int) -> Vector2i:
	var max_y := grid.size() - 1
	var bot_grass = y < max_y and grid[y + 1][x].value == 1

	if (bot_grass):
		return Vector2i(-randi() % 5, 0)
	
	return Vector2i(0, 0)
