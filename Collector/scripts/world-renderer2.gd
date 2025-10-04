extends TextureRect

var grid_buffer : RID
var grid_texture : Texture2DRD
var shader_path = "res://shaders/world_renderer.glsl"

var texture_atlas : Texture2DRD

var shader : RID
var pipeline : RID
var uniform_set : RID

var viewport_size : Vector2i

func _ready() -> void:
	var rd := RenderingServer.get_rendering_device()  # Access the low-level RenderingDevice
	viewport_size = get_viewport_rect().size.floor()
	
	size = get_viewport_rect().size
	position = -size * 0.5
	
	var _size: Vector2i = Vector2i(WorldGrid.SIZE)

	var data := PackedByteArray()
	data.resize(4 * _size.x * _size.y)
	var counter = 0
	for y in WorldGrid.SIZE.y:
		for x in WorldGrid.SIZE.x:
			data.encode_s32(counter, WorldGrid.get_cell(x, y).value)
			counter += 4
			
	grid_buffer = rd.storage_buffer_create(data.size(), data)

	var tex_format := RDTextureFormat.new()
	tex_format.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	tex_format.width = viewport_size.x
	tex_format.height = viewport_size.y
	tex_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT

	var texture_atlas_tex2d: Texture2D = load("res://assets/texture_atlas.png")
	var texture_atlas_img: Image = texture_atlas_tex2d.get_image()
	texture_atlas_img.convert(Image.FORMAT_RGBA8)
	var texture_atlas_view := RDTextureView.new()
	
	var atlas_format := RDTextureFormat.new()
	atlas_format.width = texture_atlas_img.get_width()
	atlas_format.height = texture_atlas_img.get_height()
	atlas_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	atlas_format.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	var texture_atlas_rid := rd.texture_create(atlas_format, texture_atlas_view, [texture_atlas_img.get_data()])

	texture_atlas = Texture2DRD.new()
	texture_atlas.texture_rd_rid = texture_atlas_rid
	
	grid_texture = Texture2DRD.new()
	
	grid_texture.texture_rd_rid = rd.texture_create(tex_format, RDTextureView.new())

	_load_pipeline()
	
	texture = grid_texture


func _process(_delta: float) -> void:
	_run_pipeline()
	
	
func _load_pipeline():
	var rd := RenderingServer.get_rendering_device()
	var shader_file = load(shader_path)
	shader = rd.shader_create_from_spirv(shader_file.get_spirv())
	pipeline = rd.compute_pipeline_create(shader)
	
	var nearest_sampler := RDSamplerState.new()
	nearest_sampler.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	nearest_sampler.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	
	var buffer_uniform := RDUniform.new()
	buffer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	buffer_uniform.binding = 0
	buffer_uniform.add_id(grid_buffer)
	
	var texture_uniform := RDUniform.new()
	texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	texture_uniform.binding = 1
	texture_uniform.add_id(grid_texture.texture_rd_rid)
	
	var texture_atlas_uniform := RDUniform.new()
	texture_atlas_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	texture_atlas_uniform.binding = 2
	texture_atlas_uniform.add_id(rd.sampler_create(nearest_sampler))
	texture_atlas_uniform.add_id(texture_atlas.texture_rd_rid)
	
	
	
	uniform_set = rd.uniform_set_create([buffer_uniform, texture_uniform, texture_atlas_uniform], shader, 0)

func _run_pipeline():
	var push_data := PackedByteArray()
	push_data.resize(48)
	push_data.encode_s32(0, WorldGrid.SIZE.x)
	push_data.encode_s32(4, WorldGrid.SIZE.y)
	push_data.encode_float(8, WorldGrid.starting_position.x)
	push_data.encode_float(12, WorldGrid.starting_position.y)
	push_data.encode_float(16, WorldGrid.CELL_SIZE)
	push_data.encode_float(20, get_viewport().get_camera_2d().position.x)
	push_data.encode_float(24, get_viewport().get_camera_2d().position.y)
	push_data.encode_float(28, viewport_size.x)
	push_data.encode_float(32, viewport_size.y)
	
	var rd := RenderingServer.get_rendering_device()
	var list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(list, pipeline)
	rd.compute_list_bind_uniform_set(list, uniform_set, 0)
	rd.compute_list_set_push_constant(list, push_data, push_data.size())
	rd.compute_list_dispatch(list, ceil(viewport_size.x / 16), ceil(viewport_size.y / 16), 1)
	rd.compute_list_end()
