shader_type spatial;
render_mode blend_mix, unshaded, cull_back;

uniform sampler2D cloud_sheet : source_color;
uniform int frames = 5;
uniform float speed = 0.1;
uniform float frame_rate = 6.0;
uniform float tiling = 3.0;
uniform float gap = 0.2;     // <-- LEERRAUM zwischen Wiederholungen (0 = direkt nebeneinander)

void fragment() {
    vec2 uv = UV;

    // --- TILE WIEDERHOLUNG ---
    // uv.x wiederholt sich, aber wir bauen später ein Gap ein
    float tiled = uv.x * tiling;

    // --- GESCHWINDIGKEIT / SCROLL ---
    tiled = fract(tiled + TIME * speed);

    // --- GAP EINBAUEN ---
    // Beispiel: gap = 0.2 → 20% des Bereichs sind leer
    float tile_area = 1.0 - gap;

    // Wenn wir im Gap-Bereich sind → Alpha = 0
    float local_x = fract(tiled);
    if (local_x > tile_area) {
        ALBEDO = vec3(0.0);
        ALPHA = 0.0;
    } else {
        // UV in gültigen Bereich umrechnen
        local_x = local_x / tile_area;

        // --- SPRITESHEET ANIMATION ---
        float frame = floor(mod(TIME * frame_rate, float(frames)));
        float frame_width = 1.0 / float(frames);

        // Frame auswählen
        float sheet_x = local_x * frame_width + frame * frame_width;

        vec4 tex = texture(cloud_sheet, vec2(sheet_x, uv.y));

        ALBEDO = tex.rgb;
        ALPHA = tex.a;
    }
}
