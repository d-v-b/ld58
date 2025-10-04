// ShaderType: compute

#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(std430, set = 0, binding = 0) buffer grid_buffer { int values[]; };
layout(rgba32f, set = 0, binding = 1) uniform image2D color_image;
layout(set = 0, binding = 2) uniform sampler2D atlas_texture;

layout(push_constant) uniform Params {
    int grid_width;
    int grid_height;
    float grid_min_x;
    float grid_min_y;
    float cell_size;
    float camera_pos_x; // center of screen
    float camera_pos_y;
    float viewport_width;
    float viewport_height;
};

// uint get_index(uint i, uint j, uint n) {
//     return (i * (2u * n + 3u - i)) / 2u + j;
// }

const float atlas_resolution = 16.0;
const vec2 atlas_size = vec2(256);

const ivec2 dirt_middle = ivec2(1, 2);
const ivec2 dirt_top_mid = ivec2(1, 1);
const ivec2 dirt_top_left = ivec2(0, 1);
const ivec2 dirt_top_rght = ivec2(2, 1);

int get_cell(ivec2 cell_position)
{
    int grid_index = cell_position.y * grid_width + cell_position.x;

    if (cell_position.x > 0 && cell_position.x < grid_width && cell_position.y > 0 && cell_position.y < grid_height)
    {
        return values[grid_index];
    }
    return 0;
}

vec2 get_uv(ivec2 texture_pos, vec2 sub_cell_position)
{
    return ((vec2(texture_pos) * atlas_resolution) + (sub_cell_position / cell_size) * atlas_resolution) / atlas_size;
}

void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
    vec2 screen_size = vec2(viewport_width, viewport_height);
    vec2 uv_norm = (vec2(gl_GlobalInvocationID.xy) + 0.5) / screen_size;

    
    vec2 camera_position = vec2(camera_pos_x, camera_pos_y);

    vec2 pixel_position = gl_GlobalInvocationID.xy + (vec2(camera_pos_x, camera_pos_y) - (screen_size * 0.5));
    vec2 grid_position = pixel_position - vec2(grid_min_x, grid_min_y);
    ivec2 cell_position = ivec2(floor(grid_position / cell_size));
    vec2 sub_cell_position = mod(grid_position, cell_size);

    int cell = get_cell(cell_position);

    vec4 color = vec4(0.0);
    
    if (cell == 1) //grass
    {
        if (get_cell(cell_position + ivec2(0, -1)) == 0) // above is clear
        {
            if (get_cell(cell_position + ivec2(-1, 0)) == 0) // above and left are clear
            {
                color = texture(atlas_texture, get_uv(dirt_top_left, sub_cell_position));
            }
            else if (get_cell(cell_position + ivec2(1, 0)) == 0) // above and right are clear
            {
                color = texture(atlas_texture, get_uv(dirt_top_rght, sub_cell_position));
            }
            else
            {
                color = texture(atlas_texture, get_uv(dirt_top_mid, sub_cell_position));
            }
            
        }

        else
        {
            color = texture(atlas_texture, get_uv(dirt_middle, sub_cell_position));
        }
    }

    imageStore(color_image, pixel, color);
}
