
extends ColorRect
#
#var grid_buffer : RID
#var grid_texture : ImageTexture
#
#var grid_image
#var viewport_size : Vector2i
#
#var shader_mat : ShaderMaterial
#
#var world_grid
#
#func _ready() -> void:
	#world_grid = get_node("world_grid") as world_grid
	#
	#if(!world_grid):
		#print("hello")
	#
	#size = get_viewport_rect().size * 1.25
	#position = -size * 0.5
	#
	##var _size = Vector2i(world_grid.SIZE)
	#
	##grid_image = Image.create(_size.x, _size.y, false, Image.FORMAT_L8)
	##_upload_world_grid()
	#
	#grid_texture = ImageTexture.create_from_image(grid_image)
	#
	## Create and assign shader material
	#shader_mat = ShaderMaterial.new()
	#shader_mat.shader = load("res://shaders/world_renderer.gdshader")
	#material = shader_mat
	#
	## Pass uniforms
	#shader_mat.set_shader_parameter("grid_tex", grid_texture)
	#shader_mat.set_shader_parameter("atlas_tex", load("res://assets/texture_atlas.png"))
	#shader_mat.set_shader_parameter("grid_size", Vector2(world_grid.SIZE))
	#shader_mat.set_shader_parameter("grid_min", world_grid.starting_position)
	#shader_mat.set_shader_parameter("cell_size", world_grid.CELL_SIZE)
	#
	#
#func _process(_delta: float) -> void:
	#var camera = EditorInterface.get_editor_viewport_2d().get_camera_2d() if (Engine.is_editor_hint()) else get_viewport().get_camera_2d()
	#if camera:
		#shader_mat.set_shader_parameter("camera_position", get_viewport().get_camera_2d().get_screen_center_position())
		#shader_mat.set_shader_parameter("screen_size", get_viewport_rect().size * 1.25)
#
#func _upload_world_grid():
	#for y in range(world_grid.SIZE.y):
		#for x in range(world_grid.SIZE.x):
			#var v = world_grid.get_cell(x, y).value
			#grid_image.set_pixel(x, y, Color(v * 255.0, 0, 0))
