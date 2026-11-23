shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D screen_texture : source_color, filter_linear;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), f.x), f.y);
}
void fragment() {
	vec3 image = texture(screen_texture, UV).rgb;
	float edge = pow(max(abs(UV.x - 0.5), abs(UV.y - 0.5)) * 2.0, 10.0);
	float smudge = noise(UV * 15.0) * noise(UV * 31.0 + 5.0);
	float scratch = smoothstep(0.992, 0.999, noise(UV * vec2(140.0, 2200.0)));
	ALBEDO = image * vec3(0.95, 0.99, 0.92) * (1.0 - smudge * 0.07 - edge * 0.14);
	ALBEDO += vec3(0.25, 0.24, 0.20) * scratch * edge * 0.1;
}
