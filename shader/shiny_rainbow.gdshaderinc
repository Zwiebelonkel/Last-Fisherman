// Preserve the fish's texture detail while animated rainbow bands cross its silhouette.
vec3 shiny_rainbow(vec3 base_color, vec2 uv, float time) {
	float hue = uv.x * 0.85 + uv.y * 0.45 - time * 0.18;
	vec3 rainbow = 0.5 + 0.5 * cos(6.283185 * (hue + vec3(0.0, 0.666667, 0.333333)));
	float luminance = dot(base_color, vec3(0.299, 0.587, 0.114));
	float glint = pow(max(0.0, sin((uv.x + uv.y) * 12.0 - time * 2.5)), 18.0);
	// Keep black outlines and shadows in the original texture black.
	float brightness = max(base_color.r, max(base_color.g, base_color.b));
	float rainbow_mask = smoothstep(0.04, 0.18, brightness);
	vec3 shiny_color = mix(base_color, rainbow * (0.45 + luminance * 0.55), 0.65) + vec3(glint * 0.16);
	return mix(base_color, shiny_color, rainbow_mask);
}
