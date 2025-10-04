extends ColorRect

var grid_buffer : RID
var grid_texture : ImageTexture

var grid_image
var viewport_size : Vector2i

var shader_mat : ShaderMaterial

func _ready() -> void:
	size = get_viewport_rect().size * 1.25
	position = -size * 0.5
	
	var _size = Vector2i(WorldGrid.SIZE)
	
	grid_image = Image.create(_size.x, _size.y, false, Image.FORMAT_L8)
	_upload_world_grid()
	
	grid_texture = ImageTexture.create_from_image(grid_image)
	
	# Create and assign shader material
	shader_mat = ShaderMaterial.new()
	shader_mat.shader = load("res://shaders/world_renderer.gdshader")
	material = shader_mat
	
	# Pass uniforms
	shader_mat.set_shader_parameter("grid_tex", grid_texture)
	shader_mat.set_shader_parameter("atlas_tex", load("res://assets/texture_atlas.png"))
	shader_mat.set_shader_parameter("grid_size", Vector2(WorldGrid.SIZE))
	shader_mat.set_shader_parameter("grid_min", WorldGrid.starting_position)
	shader_mat.set_shader_parameter("cell_size", WorldGrid.CELL_SIZE)
	
	
func _process(_delta: float) -> void:
	shader_mat.set_shader_parameter("camera_position", get_viewport().get_camera_2d().get_screen_center_position())
	shader_mat.set_shader_parameter("screen_size", get_viewport_rect().size * 1.25)

func _upload_world_grid():
	for y in range(WorldGrid.SIZE.y):
		for x in range(WorldGrid.SIZE.x):
			var v = WorldGrid.get_cell(x, y).value
			grid_image.set_pixel(x, y, Color(v * 255.0, 0, 0))
