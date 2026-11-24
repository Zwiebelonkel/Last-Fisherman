// Positions are in world XZ. The shadow is projected through the moving surface,
// so it also reads through the opaque low-quality water and respects shoreline depth.
uniform vec4 fight_shadow = vec4(0.0); // mouth XZ, half length, opacity
uniform vec4 fight_wake = vec4(0.0); // apex XZ, length, opacity
uniform vec4 fight_axes = vec4(1.0, 0.0, 1.0, 0.0); // fish forward, wake forward
uniform float fight_depth = 0.0;

vec2 fight_local(vec2 offset, vec2 forward) {
	return vec2(dot(offset, forward), dot(offset, vec2(-forward.y, forward.x)));
}

vec3 fight_surface(vec3 surface, vec3 eye, inout vec3 water_albedo, inout float water_roughness,
		inout float water_metallic, out float water_specular) {
	vec3 glint = vec3(0.0);
	water_specular = 0.5;
	if (fight_shadow.w > 0.0) {
		vec3 sight = normalize(surface - eye);
		vec3 ray = refract(sight, vec3(0.0, 1.0, 0.0), 0.75);
		vec2 offset = surface.xz - fight_shadow.xy;
		// The mouth touches the bobber. Refraction grows toward the submerged body.
		float depth = fight_depth + 0.12 * smoothstep(0.0, fight_shadow.z, length(offset));
		offset += ray.xz * depth / max(0.4, -ray.y);
		// Give the submerged body thickness when seen almost edge-on from the pier.
		vec2 along_view = sight.xz / max(length(sight.xz), 0.001);
		float thickness = smoothstep(0.10, 0.65, abs(sight.y));
		offset -= along_view * dot(offset, along_view) * (0.64 * (1.0 - thickness));
		vec2 p = fight_local(offset, fight_axes.xy) / fight_shadow.z;
		float aft = -p.x;
		if (aft > -0.24 && aft < 2.14 && abs(p.y) < 0.5) {
			float body_width = mix(0.36, 0.16, smoothstep(0.65, 1.48, aft));
			float body = length(vec2((aft - 0.65) / 0.77, p.y / body_width));
			float fin_width = mix(0.085, 0.27, smoothstep(1.40, 1.95, aft));
			float tail = max(abs(p.y) / fin_width, abs(aft - 1.63) / 0.38);
			float d = min(body, tail);
			float mask = (1.0 - smoothstep(0.34, 1.18, d)) * fight_shadow.w * 0.48;
			water_albedo *= 1.0 - mask * 0.95;
			water_roughness = mix(water_roughness, 0.93, mask);
			water_metallic *= 1.0 - mask;
			water_specular *= 1.0 - mask * 0.92;
			// A diffuse blue-grey edge stays legible in the tunnel's black reflections.
			glint += vec3(0.027, 0.044, 0.049) * mask * smoothstep(0.23, 0.87, d);
		}
	}
	if (fight_wake.w > 0.0) {
		vec2 p = fight_local(fight_wake.xy - surface.xz, fight_axes.zw) / fight_wake.z;
		float edge = abs(abs(p.y) - max(p.x, 0.0) * 0.43);
		float crest = (1.0 - smoothstep(0.012, 0.074, edge))
			* smoothstep(-0.05, 0.045, p.x) * (1.0 - smoothstep(0.24, 1.0, p.x)) * fight_wake.w;
		water_albedo = mix(water_albedo, vec3(0.40, 0.48, 0.46), crest * 0.55);
		glint += vec3(0.15, 0.21, 0.20) * crest;
	}
	return glint;
}
