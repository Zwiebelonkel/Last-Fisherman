shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform float pixel_size : hint_range(1.0, 1000.0) = 200;

void fragment() {
    vec2 uv = SCREEN_UV;

    uv = floor(uv * pixel_size) / pixel_size;

    COLOR = texture(SCREEN_TEXTURE, uv);
}


