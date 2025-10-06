extends TileMapLayer

class_name WorldTile

const _size = Vector2i(22, 64)
const DENSITY_HOLE = 0.25
const DENSITY_BOMB = 0.10
const DENSITY_DIAMOND = 0.012

var grid: Array[Array]

var cheat_mode: bool = false
func toggle_cheat_mode():
	cheat_mode = !cheat_mode
	for node in get_children():
		if node is not MiningBlockSelector: continue
		node.get_child(0).visible = cheat_mode

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
					
			if (y == 0):
				_cell.is_bomb = false
				_cell.value = 1
			
			_cell.position = Vector2i(x, y)
			_cell.world_position = position_grid_to_world(_cell.position)
			_cell.destroyed.connect(_on_cell_destroyed)
			_cell.scored.connect(_on_cell_scored)
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

	# Initialize bomb glow states
	for y in _size.y:
		for x in _size.x:
			if grid[y][x].is_bomb:
				update_bomb_glow(grid[y][x])

func _on_cell_destroyed(grid_position: Vector2i) -> void:
	var cell = grid[grid_position.y][grid_position.x]
	destroy_cell(cell)

func _on_cell_scored(score: int, world_pos: Vector2) -> void:
	# Get the player position
	var player = get_node("/root/Main/Player")
	if not player:
		return

	# Create score popup
	var popup = Label.new()
	popup.text = "+%d" % score
	popup.add_theme_font_size_override("font_size", 24)
	popup.add_theme_color_override("font_color", Color(1, 0.9, 0.2))  # Gold color
	popup.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	popup.add_theme_constant_override("outline_size", 2)
	popup.position = player.global_position + Vector2(-20, -80)  # Above player's head
	popup.z_index = 10

	var script = load("res://scripts/score_popup.gd")
	popup.set_script(script)

	get_tree().root.add_child(popup)
	
	
func destroy_cell(cell: WorldCell) -> void:
	set_cell(cell.position, 1, Vector2i(4, 0)  + choose_air_offset(cell.position.x, cell.position.y))
	update_neighbours(cell)
		
	cell.destroyed.disconnect(_on_cell_destroyed)

	
func update_neighbours(cell: WorldCell) -> void:
	var x = cell.position.x
	var y = cell.position.y

	var adjacent_positions = [
		Vector2i(x - 1, y),  # left
		Vector2i(x + 1, y),  # right
		Vector2i(x, y - 1),  # top
		Vector2i(x, y + 1),  # bottom
		Vector2i(x - 1, y - 1),  # left
		Vector2i(x + 1, y + 1),  # right
		Vector2i(x + 1, y - 1),  # top
		Vector2i(x - 1, y + 1),  # bottom
	]

	for pos in adjacent_positions:
		if pos.x < 0 or pos.x >= _size.x or pos.y < 0 or pos.y >= _size.y:
			continue
		update_cell(grid[pos.y][pos.x])
		update_bomb_glow(grid[pos.y][pos.x])
	
	
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
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
	]
	var count = 0

	for dir in directions:
		var check = grid_position + dir
		if check.y >= 0 and check.y < grid.size() and check.x >= 0 and check.x < grid[0].size():
				var cell = grid[check.y][check.x]
				if cell and cell.is_bomb and cell.value != 0:
					count += 1
	return count

func count_bombs_in_range(world_position: Vector2) -> int:
	var count = 0
	var grid_pos := position_world_to_grid(world_position)
	if world_position.x < 0:
		grid_pos.x = -1
	if world_position.y < 0:
		grid_pos.y = -1

	var _limit = func calc_limit(pos: Vector2i) -> Vector2i:
		return (grid_pos + pos).max(Vector2i(0, 0)).min(_size - Vector2i(1, 1))
	var directions = {
		_limit.call(Vector2i(-1, -1)): null,
		_limit.call(Vector2i(-1,  0)): null,
		_limit.call(Vector2i(-1,  1)): null,
		_limit.call(Vector2i( 0, -1)): null,
		_limit.call(Vector2i( 0,  1)): null,
		_limit.call(Vector2i( 1, -1)): null,
		_limit.call(Vector2i( 1,  0)): null,
		_limit.call(Vector2i( 1,  1)): null,
	}

	for check_pos in directions.keys():
		var cell = grid[check_pos.y][check_pos.x]
		if cell and cell.is_bomb and cell.value > 0:
			count += 1

	return count

func is_bomb_isolated(cell: WorldCell) -> bool:
	if not cell.is_bomb or cell.value == 0:
		return false

	var x = cell.position.x
	var y = cell.position.y

	# Check all 4 adjacent cells (not diagonal)
	var adjacent_positions = [
		Vector2i(x - 1, y),  # left
		Vector2i(x + 1, y),  # right
		Vector2i(x, y - 1),  # top
		Vector2i(x, y + 1),  # bottom
		Vector2i(x - 1, y - 1),  # left
		Vector2i(x + 1, y + 1),  # right
		Vector2i(x + 1, y - 1),  # top
		Vector2i(x - 1, y + 1),  # bottom
	]

	for pos in adjacent_positions:
		if pos.x < 0 or pos.x >= _size.x or pos.y < 0 or pos.y >= _size.y:
			continue

		var adjacent_cell = grid[pos.y][pos.x]
		if (adjacent_cell.value != 0 and adjacent_cell.value != -1)and not adjacent_cell.is_bomb:
			return false

	return true

func update_bomb_glow(cell: WorldCell) -> void:
	if not cell.is_bomb:
		return

	var isolated = is_bomb_isolated(cell)
	cell.set_glow(isolated)
	if isolated:
		Globals.add_score(150)


func reveal_all_bombs() -> void:
	for y in _size.y:
		for x in _size.x:
			var cell = grid[y][x]
			if cell.is_bomb and cell.value != 0:
				cell.set_glow(true)

func get_bomb_directions(grid_position: Vector2i) -> Array:
	# Returns array of 8 bools, one for each direction
	# Starting from top (index 0) going clockwise
	var directions = [
		Vector2i(0, -1),   # 0: Top
		Vector2i(1, -1),   # 1: Top-Right
		Vector2i(1, 0),    # 2: Right
		Vector2i(1, 1),    # 3: Bottom-Right
		Vector2i(0, 1),    # 4: Bottom
		Vector2i(-1, 1),   # 5: Bottom-Left
		Vector2i(-1, 0),   # 6: Left
		Vector2i(-1, -1),  # 7: Top-Left
	]

	var result = []
	for dir in directions:
		var check = grid_position + dir
		var has_bomb = false
		if check.y >= 0 and check.y < grid.size() and check.x >= 0 and check.x < grid[0].size():
			var cell = grid[check.y][check.x]
			if cell and cell.is_bomb and cell.value != 0:
				has_bomb = true
		result.append(has_bomb)

	return result
