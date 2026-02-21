shader_type spatial;

uniform float snap_resolution : hint_range(16.0, 512.0) = 64.0;
uniform sampler2D albedo_texture : source_color;

void vertex() {
    vec4 clip_pos = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);

    clip_pos.xyz /= clip_pos.w;
    clip_pos.xy = floor(clip_pos.xy * snap_resolution) / snap_resolution;
    clip_pos.xyz *= clip_pos.w;

    POSITION = clip_pos;
}

void fragment() {
    vec4 tex = texture(albedo_texture, UV);
    ALBEDO = tex.rgb;
}