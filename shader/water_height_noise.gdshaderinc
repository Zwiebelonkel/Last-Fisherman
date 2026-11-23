// Integer hashing keeps geometry noise identical on the GPU and CPU sampler.
float hash(vec2 p) {
	uvec2 cell = uvec2(ivec2(p));
	uint h = cell.x * 374761393u + cell.y * 668265263u;
	h = (h ^ (h >> 13u)) * 1274126177u;
	h = h ^ (h >> 16u);
	return float(h & 16777215u) / 16777215.0;
}

float noise(vec2 x) {
	vec2 p = floor(x);
	vec2 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(p), hash(p + vec2(1.0, 0.0)), f.x),
		mix(hash(p + vec2(0.0, 1.0)), hash(p + vec2(1.0)), f.x), f.y);
}

float fbm(vec2 x) {
	float height = 0.0;
	float amplitude = 0.5;
	float frequency = 3.0;
	for (int i = 0; i < 6; i++) {
		height += noise(x * frequency) * amplitude;
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return height;
}
