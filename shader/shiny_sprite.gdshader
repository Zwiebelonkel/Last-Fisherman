shader_type spatial;
render_mode unshaded, cull_disabled;

#include "res://shader/shiny_rainbow.gdshaderinc"
uniform sampler2D fish_texture : source_color, filter_nearest;

void vertex() {
	// Match Sprite3D's billboard while preserving its scale and position.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX[0] *= length(MODEL_MATRIX[0].xyz);
	MODELVIEW_MATRIX[1] *= length(MODEL_MATRIX[1].xyz);
	MODELVIEW_MATRIX[2] *= length(MODEL_MATRIX[2].xyz);
}

void fragment() {
	vec4 fish = texture(fish_texture, UV);
	ALBEDO = shiny_rainbow(fish.rgb, UV, TIME);
	ALPHA = fish.a * COLOR.a;
}
