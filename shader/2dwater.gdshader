shader_type canvas_item;

uniform float edge_softness : hint_range(0.0, 0.5) = 0.2;
uniform float wave_strength : hint_range(0.0, 20.0) = 5.0;
uniform float wave_speed = 1.0;
uniform float wave_scale = 10.0;

void fragment() {
    vec2 uv = UV;

    // ----- Wellenbewegung -----
    float t = TIME * wave_speed;
    float wave = sin((uv.y + t) * wave_scale) * 0.005 * wave_strength;
    uv.x += wave;

    // Textur holen
    vec4 col = texture(TEXTURE, uv);

    // ----- Weiche Kanten -----
    float fade_left   = smoothstep(0.0, edge_softness, UV.x);
    float fade_right  = smoothstep(1.0, 1.0 - edge_softness, UV.x);
    float fade_top    = smoothstep(0.0, edge_softness, UV.y);
    float fade_bottom = smoothstep(1.0, 1.0 - edge_softness, UV.y);

    float edge_mask = fade_left * fade_right * fade_top * fade_bottom;

    // Ergebnis
    COLOR = vec4(col.rgb, col.a * edge_mask);
}
