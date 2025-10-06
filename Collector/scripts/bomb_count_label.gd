extends HBoxContainer

var bomb_texture: Texture2D

func _ready() -> void:
	# Load the bomb icon
	bomb_texture = load("res://assets/bomb.png")

func update_count(bombs_nearby: int) -> void:
	# Clear existing icons
	for child in get_children():
		child.queue_free()

	# Add bomb icons based on count
	for i in range(bombs_nearby):
		var icon = TextureRect.new()
		icon.texture = bomb_texture
		icon.custom_minimum_size = Vector2(30, 30)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		# Add white outline shader for visibility
		var shader_material = ShaderMaterial.new()
		var outline_shader = """
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 size = TEXTURE_PIXEL_SIZE * outline_width;

	float outline = 0.0;
	outline += texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline = min(outline, 1.0);

	vec4 outline_final = mix(color, outline_color, outline - color.a);
	COLOR = mix(outline_final, color, color.a);
}
"""
		var shader = Shader.new()
		shader.code = outline_shader
		shader_material.shader = shader
		icon.material = shader_material

		# Color based on danger level
		match bombs_nearby:
			0:
				icon.modulate = Color.GREEN
			1:
				icon.modulate = Color.GREEN_YELLOW
			2:
				icon.modulate = Color.YELLOW
			3:
				icon.modulate = Color.RED
			4:
				icon.modulate = Color.PURPLE
			_:
				icon.modulate = Color.GRAY

		add_child(icon)
