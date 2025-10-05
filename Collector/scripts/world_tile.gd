extends TileMapLayer

class_name WorldTile

const _size = Vector2i(22, 64)
const DENSITY_HOLE = 0.25
const DENSITY_BOMB = 0.10
const DENSITY_DIAMOND = 0.012

var grid: Array[Array]

func _ready() -> void:
	for y in _size.y:
		grid.append([])
		for x in _size.x:
			var _cell = WorldCell.new(get_world_2d(), self)
			var _material = 1 if (y < 4) else 2
			var rand_value = randf()
			
			if rand_value < DENSITY_HOLE:
				_cell.value = -1 if rand_value < DENSITY_DIAMOND else 0
			else:
				_cell.value = _material
				if rand_value < DENSITY_HOLE + DENSITY_BOMB:
					_cell.is_bomb = true
			
			_cell.position = Vector2i(x, y)
			_cell.world_position = position_grid_to_world(_cell.position)
			_cell.destroyed.connect(_on_cell_destroyed)
			_cell.build()
			
			grid[y].append(_cell)

	for y in range(-1, _size.y):
		for x in _size.x:
			if y == _size.y - 1 || y < 0:
				set_cell(Vector2i(x, y), 1, Vector2i(4, 0) + choose_air_offset(x, y))
			elif grid[y][x].value == 1:
				set_cell(Vector2i(x, y), 1, Vector2i(1, 2) + choose_tile_offset(x, y))
			elif grid[y][x].value == 2:
				set_cell(Vector2i(x, y), 1, Vector2i(5, 2) + choose_tile_offset(x, y))
			else:
				set_cell(Vector2i(x, y), 1, Vector2i(4, 0) + choose_air_offset(x, y))

func _on_cell_destroyed(grid_position: Vector2i) -> void:
	var cell = grid[grid_position.y][grid_position.x]
	destroy_cell(cell)
	
func destroy_cell(cell: WorldCell) -> void:
	set_cell(cell.position, 1, Vector2i(4, 0)  + choose_air_offset(cell.position.x, cell.position.y))
	update_neighbours(cell)
	cell.destroyed.disconnect(_on_cell_destroyed)
	
func update_neighbours(cell: WorldCell) -> void:
	var x = cell.position.x
	var y = cell.position.y
	
	if (x > 0):
		update_cell(grid[y][x-1])
	if (x < _size.x-1):
		update_cell(grid[y][x+1])
	if (y > 0):
		update_cell(grid[y-1][x])
	if (y < _size.y-1):
		update_cell(grid[y+1][x])
	
	
func update_cell(cell: WorldCell) -> void:
	if cell.value <= 0:
		set_cell(cell.position, 1, Vector2i(4, 0) + choose_air_offset(cell.position.x, cell.position.y))
	elif cell.value == 1:
		set_cell(cell.position, 1, Vector2i(1, 2) + choose_tile_offset(cell.position.x, cell.position.y))
	elif cell.value == 2:
		set_cell(cell.position, 1, Vector2i(5, 2) + choose_tile_offset(cell.position.x, cell.position.y))

func position_grid_to_world(grid_position: Vector2i) -> Vector2:
	var world_position := Vector2(grid_position * tile_set.tile_size + tile_set.tile_size / 2)
	return world_position

func position_world_to_grid(world_position: Vector2) -> Vector2i:
	var grid_position := Vector2i(world_position) / tile_set.tile_size
	return grid_position

func get_grid_cell(grid_position: Vector2i) -> MiningBlock:
	return grid[grid_position.y][grid_position.x].mining_block

func choose_tile_offset(x: int, y: int) -> Vector2i:
	var max_y := grid.size() - 1
	if max_y < 0:
		return Vector2i.ZERO
	var max_x = grid[0].size() - 1

	var top_free = y == 0 or (y > 0 and grid[y - 1][x].value <= 0)
	var bot_free = y < max_y and grid[y + 1][x].value <= 0
	var lft_free = x > 0 and grid[y][x - 1].value <= 0
	var rgt_free = x < max_x and grid[y][x + 1].value <= 0
	
	if top_free && bot_free:
		if lft_free:
			if rgt_free:
				return Vector2i(0, 3)
			return Vector2i(-1, 2)
		if rgt_free:
			return Vector2i(1, 2)
		return Vector2i(0, 2)
		
	if lft_free && rgt_free:
		if top_free:
			return Vector2i(-1, 3)
		if bot_free:
			return Vector2i(1, 3)
		return Vector2i(1, 4)
		

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
	if y == max_y: return Vector2i(0, 0)
	
	var bot_grass = y < max_y and grid[y + 1][x].value == 1

	# Deterministic pseudo-random number based on x and y
	var _seed := int((x * 73856093) ^ (y * 19349663)) & 0x7fffffff
	var number := _seed % 5  # gives values 0–4, consistent per (x, y)

	if bot_grass:
		return Vector2i(-number, 0)
	return Vector2i(0, 0)

func count_adjacent_bombs(grid_position: Vector2i) -> int:
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                   Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
	]
	var count = 0
	
	for dir in directions:
		var check = grid_position + dir
		if check.y >= 0 and check.y < grid.size() and check.x >= 0 and check.x < grid[0].size():
				var cell = grid[check.y][check.x]
				if cell and cell.is_bomb:
					count += 1
	return count
