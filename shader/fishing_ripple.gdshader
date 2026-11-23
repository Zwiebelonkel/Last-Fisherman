shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.7;
uniform vec3 crest_color : source_color = vec3(0.68, 0.81, 0.82);
uniform vec3 trough_color : source_color = vec3(0.08, 0.19, 0.21);

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float radius = length(centered);
	float angle = atan(centered.y, centered.x);
	float crest = 0.0;
	float trough = 0.0;
	float antialias = fwidth(radius) * 0.75;
	// Three successive crests travel out from the bait and lose energy.
	for (int i = 0; i < 3; i++) {
		float age = progress * 1.3 - float(i) * 0.15;
		if (age > 0.0 && age < 1.0) {
			float wave_radius = mix(0.035, 0.465, age);
			float width = max(mix(0.018, 0.008, age), antialias);
			float offset = radius - wave_radius;
			float energy = smoothstep(0.0, 0.06, age)
				* exp(-age * 1.4) * (1.0 - smoothstep(0.65, 1.0, age));
			crest += exp(-pow(offset / width, 2.0)) * energy;
			trough += exp(-pow((offset + width * 1.5) / (width * 1.3), 2.0)) * energy;
		}
	}
	// Vary the reflected light gently while keeping the outer contour circular.
	float shimmer = 0.82 + 0.1 * sin(angle * 3.0 + progress * 2.0)
		+ 0.08 * sin(angle * 7.0 - progress * 3.0);
	float feather = 1.0 - smoothstep(0.475, 0.5, radius);
	float highlight = crest / max(crest + trough * 0.3, 0.0001);
	ALBEDO = mix(trough_color, crest_color, highlight);
	ALPHA = clamp((crest * 0.52 + trough * 0.12) * shimmer * feather * opacity, 0.0, 0.65);
}
