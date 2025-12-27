shader_type canvas_item;
render_mode blend_premul_alpha;

// ==============================
// PANEL-GRÖSSE (vom Script setzen!)
// ==============================

uniform vec2 panel_size_px = vec2(240.0, 290.0);

// ==============================
// SHINE PARAMETER
// ==============================

uniform float Line_Smoothness : hint_range(0, 0.1) = 0.045;
uniform float Line_Width : hint_range(0, 0.2) = 0.09;
uniform float Brightness = 3.0;
uniform float Rotation_deg : hint_range(-90, 90) = 30;
uniform float Distortion : hint_range(1, 2) = 1.8;
uniform float Speed = 0.5;
uniform float Position : hint_range(0, 1) = 0;
uniform float Position_Min = 0.25;
uniform float Position_Max = 0.5;
uniform float Alpha : hint_range(0, 1) = 1.0;

uniform vec4 ShineColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// ==============================
// ROUNDED CORNER (PIXELGENAU)
// ==============================

uniform float Corner_Radius_PX = 3.0;   // 👈 DEIN PANEL-RADIUS
uniform float Edge_Softness_PX = 1.5;   // kleine Kantenweichheit


// ==============================
// HILFSFUNKTIONEN
// ==============================

vec2 rotate_uv(vec2 uv, vec2 center, float rotation, bool use_degrees) {
	float angle = use_degrees ? rotation * (3.1415926 / 180.0) : rotation;
	mat2 rot = mat2(
		vec2(cos(angle), -sin(angle)),
		vec2(sin(angle),  cos(angle))
	);
	vec2 d = uv - center;
	d = rot * d;
	return d + center;
}

// Rounded Rectangle SDF (UV, aber pixelkorrekt skaliert)
float rounded_rect_sdf(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}


// ==============================
// FRAGMENT
// ==============================

void fragment() {

	// ==========================
	// PIXEL → UV UMGERECHNET
	// ==========================
	float min_dim = min(panel_size_px.x, panel_size_px.y);
	float corner_radius_uv = Corner_Radius_PX / min_dim;
	float edge_softness_uv = Edge_Softness_PX / min_dim;

	// ==========================
	// ROUNDED CARD MASK
	// ==========================
	vec2 uv_centered = UV - vec2(0.5);
	vec2 half_size = vec2(0.5) - edge_softness_uv;

	float card_dist = rounded_rect_sdf(
		uv_centered,
		half_size,
		corner_radius_uv
	);

	float card_mask = 1.0 - smoothstep(0.0, edge_softness_uv, card_dist);

	// ==========================
	// SHINE
	// ==========================
	vec2 center_uv = UV - vec2(0.5);
	float gradient_to_edge = max(abs(center_uv.x), abs(center_uv.y));
	gradient_to_edge = 1.0 - gradient_to_edge * Distortion;

	vec2 rot_uv = rotate_uv(UV, vec2(0.5), Rotation_deg, true);

	float p = fract(TIME * Speed + mix(Position_Min, Position_Max, Position));
	p = mix(-2.0, 2.0, p);

	float line = abs(rot_uv.x + p);
	line = sqrt(max(gradient_to_edge * line, 0.0));

	float sm = clamp(Line_Smoothness, 0.001, 1.0);
	float remapped = (line - (Line_Width + sm)) / ((Line_Width - sm) - (Line_Width + sm));
	remapped = min(remapped * Brightness, Alpha);

	// ==========================
	// FINAL (EXAKT MASKIERT)
	// ==========================
	vec4 col = ShineColor * remapped * card_mask;
	COLOR = col;
}
