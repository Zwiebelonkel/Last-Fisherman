shader_type spatial;
render_mode unshaded;

#include "res://shader/shiny_rainbow.gdshaderinc"

uniform sampler2D fish_texture : source_color, filter_nearest, repeat_disable;
uniform bool shiny_enabled = false;
uniform float cooked_amount : hint_range(0.0, 1.0) = 0.0;
uniform float burned_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 pixel = texture(fish_texture, UV);
	if (pixel.a < 0.5) discard;
	vec3 color = pixel.rgb;
	if (shiny_enabled) {
		color = shiny_rainbow(color, UV, TIME);
	}
	if (cooked_amount > 0.0) {
		vec2 crumb = floor(UV * vec2(textureSize(fish_texture, 0)));
		float grain = fract(sin(dot(crumb, vec2(127.1, 311.7))) * 43758.5453);
		float brightness = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
		float toast = clamp(brightness * 0.65 + grain * 0.35, 0.0, 1.0);
		vec3 crust = mix(vec3(0.24, 0.085, 0.025), vec3(0.92, 0.59, 0.22), toast);
		crust *= mix(0.7, 1.05, step(0.2, grain));
		crust = mix(crust, crust * vec3(0.33, 0.24, 0.18), burned_amount);
		// Retain the original dark outline and details beneath the toasted crust.
		color = mix(color, crust, cooked_amount * smoothstep(0.04, 0.15, brightness));
	}
	// Opaque geometry writes real depth. No blended front/back sorting is needed.
	ALBEDO = color * COLOR.rgb;
}
