shader_type canvas_item;

uniform vec2 shadow_offset = vec2(8.0, 8.0);
uniform vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5); // Defaultwert, kein hint_color

void fragment() {
    // Original-Icon-Farbe
    vec4 tex_color = texture(TEXTURE, UV);

    // Shadow sampling mit Offset
    vec2 offset_uv = UV + shadow_offset / vec2(textureSize(TEXTURE, 0));
    vec4 shadow_tex = texture(TEXTURE, offset_uv);

    // Alpha des Schattens = Icon-Alpha * Shadow-Alpha
    vec4 shadow = vec4(shadow_color.rgb, shadow_tex.a * shadow_color.a);

    // Shadow unter Icon mischen
    COLOR = shadow + tex_color;
}
