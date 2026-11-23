shader_type canvas_item;

// Adapted from the card-reveal reference: additive color, pulse and edge warble.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform vec4 rarity_color : source_color = vec4(1.0);
uniform float effect_amount : hint_range(0.0, 1.0) = 0.0;
uniform float glow_strength : hint_range(0.0, 3.0) = 1.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.25;
uniform float edge_power : hint_range(0.5, 6.0) = 2.2;
uniform float flicker_strength : hint_range(0.0, 1.0) = 0.0;
uniform float flicker_speed : hint_range(0.0, 60.0) = 12.0;
uniform float aberration_strength : hint_range(0.0, 0.02) = 0.0;
uniform float distortion_strength : hint_range(0.0, 0.05) = 0.0;
uniform float distortion_speed : hint_range(0.0, 10.0) = 3.0;

float flicker_noise(float t) {
	return sin(t * 12.9898) * 0.5
		+ sin(t * 27.233 + 1.7) * 0.3
		+ sin(t * 53.71 + 3.1) * 0.2;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered = uv - vec2(0.5);
	vec2 edge_distance = min(uv, vec2(1.0) - uv);
	float flow_time = TIME * distortion_speed;
	float wave = sin(uv.x * 16.0 + flow_time)
		+ cos(uv.y * 18.0 - flow_time * 0.8);
	// Reach all four screen edges while leaving the catch card in the center clear.
	float edge = min(edge_distance.x, edge_distance.y) + wave * 0.014;
	float vignette = pow(1.0 - smoothstep(0.0, 0.32, edge), edge_power);
	float envelope = vignette * effect_amount;

	vec2 distort_offset = vec2(
		sin(uv.y * 18.0 + flow_time),
		cos(uv.x * 16.0 + flow_time * 0.8)
	) * distortion_strength * envelope;
	vec2 distorted_uv = uv + distort_offset;
	vec2 aberration = normalize(centered + vec2(0.0001))
		* aberration_strength * envelope;

	vec3 screen_col;
	screen_col.r = texture(screen_texture, distorted_uv + aberration).r;
	screen_col.g = texture(screen_texture, distorted_uv).g;
	screen_col.b = texture(screen_texture, distorted_uv - aberration).b;

	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
	float flicker = 1.0 + flicker_noise(TIME * flicker_speed)
		* flicker_strength * effect_amount;
	float wisps = 0.85 + wave * 0.075;
	vec3 glow = rarity_color.rgb * envelope * glow_strength * 0.35 * pulse * flicker * wisps;
	COLOR = vec4(screen_col + glow, 1.0);
}
