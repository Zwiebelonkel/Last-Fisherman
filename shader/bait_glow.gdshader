shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 glow_color : source_color = vec4(1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.3;

void vertex() {
	// Follow the camera without losing the bobber's gameplay/preview scale.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX[0] *= length(MODEL_MATRIX[0].xyz);
	MODELVIEW_MATRIX[1] *= length(MODEL_MATRIX[1].xyz);
	MODELVIEW_MATRIX[2] *= length(MODEL_MATRIX[2].xyz);
}

void fragment() {
	float radius = length(UV * 2.0 - 1.0);
	float halo = pow(max(1.0 - radius, 0.0), 2.0);
	ALBEDO = glow_color.rgb;
	ALPHA = halo * glow_strength;
}
