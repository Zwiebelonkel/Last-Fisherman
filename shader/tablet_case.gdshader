shader_type spatial;
render_mode cull_disabled;

uniform vec4 case_color : source_color = vec4(0.16, 0.17, 0.135, 1.0);

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), f.x), f.y);
}
void fragment() {
	float grime = noise(UV * 18.0) * noise(UV * 43.0 + 9.0);
	float grain = noise(UV * vec2(650.0, 400.0));
	float scratches = smoothstep(0.78, 0.96, noise(UV * vec2(45.0, 900.0)));
	vec3 color = mix(case_color.rgb, vec3(0.055, 0.042, 0.022), grime * 0.8);
	color *= 0.8 + grain * 0.4;
	color = mix(color, vec3(0.38, 0.34, 0.25), scratches * 0.3);
	ALBEDO = color;
	ROUGHNESS = 0.78 + grime * 0.2;
	METALLIC = 0.22;
}
