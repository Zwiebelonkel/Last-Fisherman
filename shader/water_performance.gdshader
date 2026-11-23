shader_type spatial;
uniform float surface_time = -1.0;
render_mode cull_disabled;

uniform vec4 water_color : source_color = vec4(0.05, 0.2, 0.27, 1.0);
uniform float wave_height = 1.0;
uniform float wave_speed = 1.0;
uniform float level_offset = 0.0;
uniform int detail_level = 0;
uniform sampler2D detail_normal : hint_normal, repeat_enable, filter_linear_mipmap;

void vertex() {
	float t = (surface_time >= 0.0 ? surface_time : TIME) * wave_speed;
	float a = VERTEX.x * 0.22 + t * 0.8;
	float b = VERTEX.z * 0.18 - t * 0.65;
	float strength = wave_height * (detail_level > 0 ? 0.075 : 0.04);
	VERTEX.y += level_offset + (sin(a) + sin(b)) * strength;
	NORMAL = normalize(vec3(-cos(a) * 0.22 * strength, 1.0, -cos(b) * 0.18 * strength));
}

void fragment() {
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	ALBEDO = water_color.rgb;
	METALLIC = 0.15;
	ROUGHNESS = detail_level > 0 ? 0.22 : 0.4;
	if (detail_level > 0) {
		NORMAL_MAP = texture(detail_normal, UV * 24.0 + vec2((surface_time >= 0.0 ? surface_time : TIME) * 0.013, (surface_time >= 0.0 ? surface_time : TIME) * 0.008)).rgb;
		NORMAL_MAP_DEPTH = 0.4;
	}
}
