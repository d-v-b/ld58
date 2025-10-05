extends Node2D

@export var mining_range: float = 100.0
@export var block_selector: MiningBlockSelector

func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var player_pos: Vector2 = get_parent().global_position

	# Get the tile map
	var tile_map = get_node("/root/Main/TileMapLayer")
	if not tile_map:
		block_selector.current = null
		return

	# Find the closest block to the mouse within mining range
	var closest_block: MiningBlock = null
	var closest_distance := mining_range + 1.0  # Start beyond range

	# Convert mining range to grid cell radius
	var cell_radius = int(ceil(mining_range / tile_map.tile_set.tile_size.x)) + 1
	var player_grid_pos = tile_map.position_world_to_grid(player_pos)

	# Check all cells within range
	for dy in range(-cell_radius, cell_radius + 1):
		for dx in range(-cell_radius, cell_radius + 1):
			var check_pos = player_grid_pos + Vector2i(dx, dy)

			# Skip if out of bounds
			if check_pos.y < 0 or check_pos.y >= tile_map.grid.size() or check_pos.x < 0 or check_pos.x >= tile_map.grid[0].size():
				continue

			var cell = tile_map.grid[check_pos.y][check_pos.x]
			if cell and cell.mining_block and cell.value != 0:
				# Check if block is within mining range of player
				var distance_from_player = player_pos.distance_to(cell.world_position)
				if distance_from_player <= mining_range:
					# Check if this block is closer to the mouse than previous closest
					var distance_from_mouse = mouse_pos.distance_to(cell.world_position)
					if distance_from_mouse < closest_distance:
						closest_distance = distance_from_mouse
						closest_block = cell.mining_block

	block_selector.current = closest_block
