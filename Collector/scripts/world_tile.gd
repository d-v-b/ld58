extends TileMapLayer
class_name world_tile

const _size = Vector2i(64, 64)
const _offset = Vector2i(_size.x * -0.5, 0)

const mining_block = preload("res://scenes/mining_block.tscn")

var grid := []

func _ready() -> void:
	for y in _size.y:
		var material = 1 if (y < 4) else 2
		
		var row := []
		for x in _size.x:
			var _cell = cell.new()
			var rand_value = randi_range(0, 4)
			_cell.value = 0 if (rand_value == 0) else material
			
			#var mining_blcok = mining_block.instantiate()
			#mining_blcok.position = Vector2(64 * x, 64 * y)
			#add_child(mining_blcok)
			
			row.append(_cell)
		grid.append(row)
	
	
	for y in range(-1, _size.y):
		for x in _size.x:
			if y == -1:
				set_cell(Vector2i(x, y) + _offset, 1, Vector2i(4, 0)  + choose_air_offset(x, y))
			elif grid[y][x].value == 1:
				set_cell(Vector2i(x, y) + _offset, 1, Vector2i(1, 2) + choose_tile_offset(x, y))
			elif grid[y][x].value == 2:
				set_cell(Vector2i(x, y) + _offset, 1, Vector2i(5, 2)  + choose_tile_offset(x, y))
			else:
				set_cell(Vector2i(x, y) + _offset, 1, Vector2i(4, 0)  + choose_air_offset(x, y))
				
			
func get_cell_coord_at_world_pos(world_position):
	return
	
func get_cell(coord):
	return


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
