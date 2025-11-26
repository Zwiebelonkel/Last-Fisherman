shader_type canvas_item;
render_mode blend_premul_alpha;

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

vec2 rotate_uv(vec2 uv, vec2 center, float rotation, bool use_degrees){
	float _angle = use_degrees ? rotation * (3.1415926/180.0) : rotation;
	mat2 _rotation = mat2(
		vec2(cos(_angle), -sin(_angle)),
		vec2(sin(_angle), cos(_angle))
	);
	vec2 _delta = uv - center;
	_delta = _rotation * _delta;
	return _delta + center;
}

void fragment() {
	vec2 center_uv = UV - vec2(0.5, 0.5);
	float gradient_to_edge = max(abs(center_uv.x), abs(center_uv.y));
	gradient_to_edge = 1.0 - gradient_to_edge * Distortion;

	vec2 rot_uv = rotate_uv(UV, vec2(0.5, 0.5), Rotation_deg, true);
	float p = fract(TIME * Speed + mix(Position_Min, Position_Max, Position));
	p = mix(-2.0, 2.0, p);

	float line = abs(rot_uv.x + p);
	line = sqrt(gradient_to_edge * line);

	float sm = clamp(Line_Smoothness, 0.001, 1.0);
	float remapped = (line - (Line_Width + sm)) / ((Line_Width - sm) - (Line_Width + sm));
	remapped = min(remapped * Brightness, Alpha);

	// Shine in Farbung der Seltenheit
	vec4 col = ShineColor * remapped;

	COLOR = col;
}
