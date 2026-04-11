shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;
uniform float jitter_strength : hint_range(0.0, 0.02) = 0.0035;
uniform float jitter_speed : hint_range(0.0, 30.0) = 8.0;
uniform float uv_snap : hint_range(64.0, 1024.0) = 320.0;
uniform float line_jitter : hint_range(0.0, 0.02) = 0.0015;

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    float t = TIME * jitter_speed;
    float row = floor(uv.y * uv_snap);

    float row_noise = (hash(row + floor(t * 12.0)) - 0.5) * line_jitter;
    float frame_noise = (hash(floor(t * 6.0)) - 0.5) * jitter_strength;

    uv.x += row_noise + frame_noise;

    uv = floor(uv * uv_snap) / uv_snap;
    uv = clamp(uv, vec2(0.0), vec2(1.0));

    COLOR = texture(screen_tex, uv);
}
