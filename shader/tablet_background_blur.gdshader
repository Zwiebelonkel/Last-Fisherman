shader_type canvas_item;
render_mode unshaded;

uniform vec2 direction = vec2(1.0, 0.0);
uniform float radius_pixels : hint_range(0.0, 48.0) = 9.0;
varying vec4 item_modulate;

void vertex() {
	item_modulate = COLOR;
}

void fragment() {
	// Cover the entire Gaussian kernel to avoid ghost copies with larger radii.
	// Pair adjacent taps using bilinear filtering, in horizontal/vertical passes.
	vec2 step_uv = direction * TEXTURE_PIXEL_SIZE;
	float sigma = max(radius_pixels / 3.0, 0.1);
	float inverse_variance = 0.5 / (sigma * sigma);
	int radius = int(ceil(clamp(radius_pixels, 0.0, 48.0)));
	vec4 blurred = texture(TEXTURE, UV);
	float total_weight = 1.0;
	for (int i = 1; i <= 48; i += 2) {
		if (i > radius) {
			break;
		}
		float distance_a = float(i);
		float distance_b = float(i + 1);
		float weight_a = exp(-distance_a * distance_a * inverse_variance);
		float weight_b = i + 1 <= radius ? exp(-distance_b * distance_b * inverse_variance) : 0.0;
		float weight = weight_a + weight_b;
		vec2 offset = step_uv * (distance_a + weight_b / max(weight, 0.000001));
		blurred += (texture(TEXTURE, UV + offset) + texture(TEXTURE, UV - offset)) * weight;
		total_weight += 2.0 * weight;
	}
	COLOR = blurred / total_weight * item_modulate;
}
