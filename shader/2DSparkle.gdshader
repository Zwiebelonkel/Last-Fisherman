shader_type canvas_item;
render_mode blend_add, unshaded;

uniform vec2 panel_size_px = vec2(240.0, 290.0);
uniform float Corner_Radius_PX = 3.0;
uniform float Edge_Softness_PX = 0.5;

// Sparkle
uniform float Sparkle_Density   : hint_range(0.0, 1.0) = 0.5;
uniform float Sparkle_Size      : hint_range(0.001, 0.2) = 0.06;   // war 0.015
uniform float Sparkle_Speed     : hint_range(0.0, 5.0) = 1.2;
uniform float Sparkle_Brightness: hint_range(0.0, 6.0) = 2.5;
uniform float Sparkle_Twinkle   : hint_range(0.0, 10.0) = 4.0;
uniform vec4  Sparkle_Color_A   : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4  Sparkle_Color_B   : source_color = vec4(0.8, 0.9, 1.0, 1.0);

// Chrome
uniform float Chrome_Intensity  : hint_range(0.0, 2.0) = 0.6;
uniform float Chrome_Speed      : hint_range(0.0, 3.0) = 0.4;
uniform float Chrome_Scale      : hint_range(1.0, 20.0) = 6.0;

float rounded_rect_sdf(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}
float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float star_shape(vec2 uv, float size) {
	float s = abs(uv.x) + abs(uv.y);
	float r = length(uv);
	return smoothstep(size, 0.0, mix(r, s, 0.5));
}

float chrome_noise(vec2 uv, float t) {
	vec2 p = uv * Chrome_Scale;
	float w1 = sin(p.x * 1.5 + p.y * 0.8 + t * Chrome_Speed) * 0.5 + 0.5;
	float w2 = sin(p.x * 0.7 - p.y * 1.3 + t * Chrome_Speed * 0.7 + 1.57) * 0.5 + 0.5;
	float w3 = sin((p.x + p.y) * 1.1 + t * Chrome_Speed * 1.3 + 3.14) * 0.5 + 0.5;
	return w1 * w2 * w3;
}

void fragment() {
	float min_dim = min(panel_size_px.x, panel_size_px.y);
	float corner_r  = Corner_Radius_PX  / min_dim;
	float edge_soft = Edge_Softness_PX  / min_dim;

	vec2 uv_c = UV - vec2(0.5);
	float dist = rounded_rect_sdf(uv_c, vec2(0.5) - edge_soft, corner_r);
	float mask = 1.0 - smoothstep(0.0, edge_soft, dist);

// --- Chrome ---
	float chrome = chrome_noise(UV, TIME);
	
	vec3 base_color = Sparkle_Color_A.rgb;
	vec3 comp_color = vec3(
		base_color.b * 0.5 + base_color.g * 0.5,
		base_color.r * 0.5 + base_color.b * 0.5,
		base_color.g * 0.5 + base_color.r * 0.5
	);
	float blend_t = sin(TIME * Chrome_Speed * 0.15 + UV.x * 2.0 + UV.y * 1.5) * 0.5 + 0.5;
	vec3 chrome_rgb = mix(base_color, comp_color + vec3(0.3), blend_t);
	chrome_rgb = mix(chrome_rgb, vec3(1.0), chrome * 0.4);
	
	vec4 chrome_col = vec4(chrome_rgb * chrome * Chrome_Intensity,
	                       chrome * Chrome_Intensity * 0.35);

	// --- Sparkles ---
	vec4 sparkle_out = vec4(0.0);
	float grid_size = 3.0 + Sparkle_Density * 4.0;  // war 6.0 + Density * 8.0
	vec2 grid_uv    = UV * grid_size;
	vec2 grid_id    = floor(grid_uv);
	vec2 grid_local = fract(grid_uv);

	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 cell_id = grid_id + vec2(float(x), float(y));
			vec2 rnd  = hash2(cell_id);
			float r1  = hash1(cell_id + vec2(13.7, 7.3));
			float r2  = hash1(cell_id + vec2(3.14, 2.72));

			if (r1 > (1.0 - Sparkle_Density)) {
				vec2 sp_pos = rnd * 0.8 + 0.1;
				vec2 local  = grid_local - vec2(float(x), float(y)) - sp_pos;

				float angle = r2 * 6.28318 + TIME * Sparkle_Speed * (0.5 + r1 * 0.5);
				float cs = cos(angle); float sn = sin(angle);
				vec2 rot = vec2(cs*local.x - sn*local.y, sn*local.x + cs*local.y);

				float size   = Sparkle_Size * (0.5 + r2) / grid_size;
				float twinkle = pow(max(0.0, sin(r1 * 6.28318 + TIME * Sparkle_Twinkle * (0.5 + r2 * 0.5))), 3.0);

				float star   = star_shape(rot, size);
				float cross_h = smoothstep(size*8.0, 0.0, abs(rot.y)) * smoothstep(size*1.0, 0.0, abs(rot.x));
				float cross_v = smoothstep(size*8.0, 0.0, abs(rot.x)) * smoothstep(size*1.0, 0.0, abs(rot.y));
				float val = (star + (cross_h + cross_v) * 0.6) * twinkle * Sparkle_Brightness;

				sparkle_out += mix(Sparkle_Color_A, Sparkle_Color_B, r2) * val;
			}
		}
	}
	sparkle_out.rgb = clamp(sparkle_out.rgb, vec3(0.0), vec3(4.0));
	sparkle_out.a   = clamp(sparkle_out.a,   0.0, 1.0);

vec4 result = chrome_col + sparkle_out;
	// Chrome separat skalieren damit es nicht von Sparkles überwältigt wird
	result.rgb = clamp(result.rgb * 1.5, vec3(0.0), vec3(1.0));
	result.rgb *= mask;
	result.a = 1.0;
	COLOR = result;
}