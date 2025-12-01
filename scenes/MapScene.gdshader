shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D cloud_sheet : hint_default_white;
uniform int frames = 5;
uniform float speed = 0.1;
uniform float frame_rate = 6.0;
uniform float tiling = 3.0;
uniform float gap = 0.2;     // Leerraum zwischen Wiederholungen (0 = direkt nebeneinander)

void fragment() {
    vec2 uv = UV;

    // --- TILE WIEDERHOLUNG ---
    float tiled = uv.x * tiling;

    // --- GESCHWINDIGKEIT / SCROLL ---
    tiled = fract(tiled + TIME * speed);

    // --- GAP EINBAUEN ---
    float tile_area = 1.0 - gap;

    // Wenn wir im Gap-Bereich sind → transparent
    float local_x = fract(tiled);
    if (local_x > tile_area) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        // UV in gültigen Bereich umrechnen
        local_x = local_x / tile_area;

        // --- SPRITESHEET ANIMATION ---
        float frame = floor(mod(TIME * frame_rate, float(frames)));
        float frame_width = 1.0 / float(frames);

        // Frame auswählen
        float sheet_x = local_x * frame_width + frame * frame_width;

        vec4 tex = texture(cloud_sheet, vec2(sheet_x, uv.y));

        COLOR = tex;
    }
}
