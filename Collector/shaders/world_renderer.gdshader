shader_type canvas_item;


uniform sampler2D grid_tex;
uniform sampler2D atlas_tex : filter_nearest;

uniform vec2 camera_position;
uniform vec2 screen_size;
uniform vec2 grid_min;
uniform ivec2 grid_size;
uniform float cell_size;
uniform int atlas_tiles_x = 16;
uniform int atlas_tiles_y = 16;

const float atlas_resolution = 16.0;
const vec2 atlas_size = vec2(256);

const ivec2 grass_1 = ivec2(0, 0);

const ivec2 dirt_mid = ivec2(1, 2);
const ivec2 dirt_mid_left = ivec2(0, 2);
const ivec2 dirt_mid_rght = ivec2(2, 2);
const ivec2 dirt_top_mid = ivec2(1, 1);
const ivec2 dirt_top_left = ivec2(0, 1);
const ivec2 dirt_top_rght = ivec2(2, 1);
const ivec2 dirt_bot_mid = ivec2(1, 3);
const ivec2 dirt_bot_left = ivec2(0, 3);
const ivec2 dirt_bot_rght = ivec2(2, 3);

void vertex() {
	// Called for every vertex the material is visible on.
}

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 get_cell(ivec2 cell_position)
{
    if (cell_position.x > 0 && cell_position.x < grid_size.x && cell_position.y > 0 && cell_position.y < grid_size.y)
    {
		vec2 uv = (vec2(cell_position) + 0.5) / vec2(grid_size);
        return texture(grid_tex, uv);
    }
    return vec4(0.0);
}

vec2 get_uv(ivec2 texture_pos, vec2 sub_cell_position)
{
    return ((vec2(texture_pos) * atlas_resolution) + (sub_cell_position / cell_size) * atlas_resolution) / atlas_size;
}

ivec2 pick_tile(int mask) {
    // Simplified: only using top variants
    if (mask == 0) return dirt_top_mid; // isolated
    if ((mask & 1) == 0) { // no tile above
        if ((mask & 8) == 0) return dirt_top_left;
        if ((mask & 2) == 0) return dirt_top_rght;
        return dirt_top_mid;
    }
	else if ((mask & 4) == 0) { // no tile below
        if ((mask & 8) == 0) return dirt_bot_left;
        if ((mask & 2) == 0) return dirt_bot_rght;
        return dirt_bot_mid;
    }
	else if ((mask & 8) == 0) { // no tile to left
		return dirt_mid_left;
	}
	else if ((mask & 2) == 0) { // no tile to right
		return dirt_mid_rght;
	}
    return dirt_mid;
}

void fragment() {
	//vec2 pixel_position = ((SCREEN_UV - vec2(0.5)) * screen_size) + camera_position;
	vec2 pixel_position = camera_position + (SCREEN_UV - 0.5) * (screen_size);
	vec2 grid_position = pixel_position - grid_min;
	
	ivec2 cell_position = ivec2(floor(grid_position / cell_size));
    vec2 sub_cell_position = mod(grid_position, cell_size);
	
	float cell = get_cell(cell_position).r;

    vec4 color = vec4(0.0);
    
	if (cell == 1.0) {
	    int mask = 0;
	    mask |= int(get_cell(cell_position + ivec2(0, -1)).r > 0.0) * 1;
	    mask |= int(get_cell(cell_position + ivec2(1, 0)).r > 0.0) * 2;
	    mask |= int(get_cell(cell_position + ivec2(0, 1)).r > 0.0) * 4;
	    mask |= int(get_cell(cell_position + ivec2(-1, 0)).r > 0.0) * 8;
	    
	    ivec2 tile = pick_tile(mask);
	    color = texture(atlas_tex, get_uv(tile, sub_cell_position));
	}
	else if (cell == 0.0) {
		if (get_cell(cell_position + ivec2(0, 1)).r == 1.0) //below is dirt
		{
			ivec2 offset = ivec2(vec2(rand(vec2(cell_position)) * 3.0, 0.0));
			color = texture(atlas_tex, get_uv(grass_1 + offset, sub_cell_position));
		}
		
	}
	
	
	COLOR = color;//vec4(sub_cell_position / 50.0, 0.0, 0.4);//texture(grid_tex, UV);
	//COLOR.a = 0.5;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
