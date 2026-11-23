shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 glow_color : source_color = vec4(1.0, 0.95, 0.4, 1.0);
uniform float glow_strength : hint_range(0.0, 4.0) = 1.5;
uniform float flicker_speed : hint_range(0.1, 5.0) = 1.0;

varying float brightness;

void vertex() {
	// Keep the soft light facing the camera while preserving particle size.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]
	);
	MODELVIEW_MATRIX *= mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

	// Each particle gets its own phase and rhythm, with a little faster shimmer.
	float seed = fract(sin(float(INSTANCE_ID) * 127.1 + 17.7) * 43758.5453);
	float phase = seed * 6.283185;
	float time = TIME * flicker_speed;
	float pulse = 0.5 + 0.5 * sin(time * mix(1.8, 3.2, seed) + phase);
	float shimmer = 0.5 + 0.5 * sin(time * mix(7.0, 11.0, seed) + phase * 2.3);
	brightness = 0.45 + 0.45 * pulse + 0.10 * shimmer;
}

void fragment() {
	float radius = length(UV * 2.0 - 1.0);
	float core = 1.0 - smoothstep(0.0, 0.35, radius);
	float halo = pow(max(1.0 - radius, 0.0), 2.0);
	ALBEDO = glow_color.rgb * COLOR.rgb * brightness;
	EMISSION = ALBEDO * glow_strength;
	ALPHA = (core * 0.7 + halo * 0.3) * COLOR.a * glow_color.a;
}
