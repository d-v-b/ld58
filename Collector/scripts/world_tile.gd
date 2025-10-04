extends TileMapLayer
class_name world_tile

const _size = Vector2i(64, 64)
const _offset = Vector2i(_size.x * -0.5, 0)

var grid := []

func _ready() -> void:
	for y in _size.y:
		var row := []
		for x in _size.x:
			var _cell = cell.new()
			var rand_value = randi_range(0, 4)
			_cell.value = 0 if (rand_value == 0) else 1
			
			row.append(_cell)
		grid.append(row)
	
	
	for y in _size.y:
		for x in _size.x:
			if grid[y][x].value == 1:
				set_cell(Vector2i(x, y) + _offset, 1, Vector2i(1, 2))
			else:
				set_cell(Vector2i(x, y) + _offset, 1, Vector2i(-1, -1))
			
#func get_cell_coord_at_world_pos(vec2 world_position):
