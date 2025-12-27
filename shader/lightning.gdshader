shader_type canvas_item;

// ==============================
// PANEL-GRÖSSE (vom Script setzen!)
// ==============================

uniform vec2 panel_size_px = vec2(240.0, 290.0);

// ==============================
// STYLE
// ==============================

uniform vec4 glow_color : source_color = vec4(0.2, 0.5, 1.0, 1.0);
uniform float intensity = 4.0;

uniform float border_thickness_px = 2.0;
uniform float border_softness_px  = 0.0;
uniform float corner_radius_px    = 3.0;

// ==============================
// FLICKER
// ==============================

uniform float flicker_intensity = 0.2;
uniform float pulse_speed = 1.6;


// ==============================
// NOISE
// ==============================

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), f);
}

float neon_flicker(float t) {
    float slow = noise(t * 1.5) * 0.3 + 0.7;
    float fast = step(0.97, noise(t * 20.0)) * 0.3;
    return clamp(slow * (1.0 - fast), 0.6, 1.0);
}

// ==============================
// ROUNDED RECT SDF (PIXEL)
// ==============================

float rounded_rect_sdf(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}


// ==============================
// FRAGMENT
// ==============================

void fragment() {
    // ✅ PANEL-LOKALE PIXELPOSITION
    vec2 pixel_pos = UV * panel_size_px;
    vec2 center = panel_size_px * 0.5;

    float dist = rounded_rect_sdf(
        pixel_pos - center,
        center - vec2(border_thickness_px),
        corner_radius_px
    );

    // ❗ NUR AUSSEN zeichnen
// Nur Bereich AUSSEN am Rand (nicht innen!)
	float border_outer = smoothstep(
    	border_thickness_px + border_softness_px,
    	border_thickness_px,
    	dist
	);

// Innenbereich hart ausmaskieren
	float inside_mask = step(0.0, dist);

// Finaler Rand
	float border = border_outer * inside_mask;


    float pulse = sin(TIME * pulse_speed) * 0.05 + 0.95;
    float flicker = mix(1.0, neon_flicker(TIME), flicker_intensity);

    float alpha = border * intensity * pulse * flicker;
    alpha = clamp(alpha, 0.0, 1.0);

    COLOR = vec4(glow_color.rgb, alpha);
}
