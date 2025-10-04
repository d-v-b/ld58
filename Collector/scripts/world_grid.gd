#@tool
extends Node2D
#class_name WorldGrid
#
#const SIZE = Vector2(64, 64)
#const CELL_SIZE = 50
#const CELL_RECT = Vector2(CELL_SIZE, CELL_SIZE)
#
#var grid := []
#var starting_position := Vector2(-SIZE.x * CELL_SIZE * 0.5, 0)
#
#func _ready() -> void:
	#for y in SIZE.y:
		#var row := []
		#for x in SIZE.x:
			#var _cell = WorldCell.new()
			#var rand_value = randi_range(0, 4)
			#_cell.value = 0 if (rand_value == 0) else 1
			#row.append(_cell)
		#grid.append(row)
#
#
#func get_cell(x, y):
	#return grid[y][x]
	##_draw()
#
##func _draw():
	##for y in SIZE.y:
		##for x in SIZE.x:
			##var cell_value : cell = grid[y][x]
			##var pos = Vector2(x * CELL_SIZE, y * CELL_SIZE) + starting_position
			##var rect = Rect2(pos, CELL_RECT)
			##
			##if(cell_value.value == 1):
				##draw_rect(rect, Color(0.213, 0.412, 0.24, 1.0))
			##else:
				##draw_rect(rect, Color(0.515, 0.265, 0.379, 1.0))
