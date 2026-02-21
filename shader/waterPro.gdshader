shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ─── Wave Parameters ───────────────────────────────────────────────
uniform float wave_speed      : hint_range(0.0, 5.0)   = 0.7;
uniform float wave_height     : hint_range(0.0, 2.0)   = 0.12;
uniform float wave_steepness  : hint_range(0.0, 1.0)   = 0.3;
uniform float wave_length     : hint_range(1.0, 100.0) = 18.0;

// ─── Water Color ───────────────────────────────────────────────────
uniform vec4  water_shallow_color : source_color = vec4(0.08, 0.78, 0.65, 0.72);
uniform vec4  water_mid_color     : source_color = vec4(0.02, 0.52, 0.72, 0.88);
uniform vec4  water_deep_color    : source_color = vec4(0.01, 0.18, 0.42, 0.97);
uniform vec4  foam_color          : source_color = vec4(0.98, 1.00, 1.00, 1.00);
uniform float water_clarity       : hint_range(0.0, 1.0)  = 0.7;
uniform float depth_fade_distance : hint_range(0.1, 30.0) = 8.0;

// ─── Foam ──────────────────────────────────────────────────────────
uniform bool  foam_enabled     = true;
uniform float foam_threshold   : hint_range(0.0, 1.0)  = 0.5;
uniform float foam_edge_scale  : hint_range(0.0, 8.0)  = 3.5;
uniform float foam_noise_scale : hint_range(0.1, 10.0) = 1.0;
uniform float foam_speed       : hint_range(0.0, 3.0)  = 0.35;
uniform float foam_sharpness   : hint_range(0.0, 1.0)  = 0.4;

// ─── Surface ───────────────────────────────────────────────────────
uniform float normal_scale      : hint_range(0.0, 3.0)  = 0.55;
uniform float normal_speed      : hint_range(0.0, 2.0)  = 0.3;
uniform float normal_tiling     : hint_range(0.1, 10.0) = 1.0;
uniform float roughness         : hint_range(0.0, 1.0)  = 0.04;
uniform float metallic          : hint_range(0.0, 1.0)  = 0.08;
uniform float specular_strength : hint_range(0.0, 2.0)  = 1.4;

// ─── Refraction ────────────────────────────────────────────────────
// refraction_strength: how much the normals distort the screen UV (0=none, 1=strong)
// refraction_scale:    how quickly refraction fades out at the shoreline
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.15;
uniform float refraction_scale    : hint_range(0.0, 2.0) = 0.4;

uniform sampler2D DEPTH_TEXTURE  : hint_depth_texture,  filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,  filter_linear_mipmap;

// ══════════════════════════════════════════════════════════════════
//  GRADIENT NOISE — quintic Perlin, no tiling
// ══════════════════════════════════════════════════════════════════

vec2 grad(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return normalize(sin(p) * 43758.5453);
}

float perlin(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	float a = dot(grad(i + vec2(0,0)), f - vec2(0,0));
	float b = dot(grad(i + vec2(1,0)), f - vec2(1,0));
	float c = dot(grad(i + vec2(0,1)), f - vec2(0,1));
	float d = dot(grad(i + vec2(1,1)), f - vec2(1,1));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y) * 0.5 + 0.5;
}

float fbm(vec2 p, int octaves) {
	float v = 0.0, a = 0.5, fr = 1.0;
	for (int i = 0; i < octaves; i++) {
		v  += a * perlin(p * fr);
		fr *= 2.13;
		a  *= 0.48;
	}
	return v;
}

float warped_fbm(vec2 p, int octaves) {
	vec2 q = vec2(fbm(p + vec2(0.0, 0.0), octaves - 1),
	              fbm(p + vec2(5.2, 1.3),  octaves - 1));
	vec2 r = vec2(fbm(p + 3.5 * q + vec2(1.7, 9.2), octaves - 1),
	              fbm(p + 3.5 * q + vec2(8.3, 2.8),  octaves - 1));
	return fbm(p + 2.2 * r, octaves);
}

// ══════════════════════════════════════════════════════════════════
//  GERSTNER WAVE
// ══════════════════════════════════════════════════════════════════

vec3 gerstner(vec2 pos, vec2 dir, float steepness, float wlen, float spd, float t) {
	float k = 6.28318 / wlen;
	float c = sqrt(9.8 / k);
	float f = k * (dot(dir, pos) - c * spd * t);
	float a = steepness / k;
	return vec3(dir.x * a * cos(f), a * sin(f), dir.y * a * cos(f));
}

// ══════════════════════════════════════════════════════════════════
//  VERTEX
// ══════════════════════════════════════════════════════════════════

varying float v_wave_y;
varying vec3  v_world_pos;
varying vec3  v_view_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float t = TIME * wave_speed;
	vec3 disp = vec3(0.0);
	disp += gerstner(v_world_pos.xz, normalize(vec2( 1.0,  0.6)), wave_steepness * 0.80, wave_length,        1.00, t);
	disp += gerstner(v_world_pos.xz, normalize(vec2(-0.5,  1.0)), wave_steepness * 0.50, wave_length * 0.75, 1.12, t);
	disp += gerstner(v_world_pos.xz, normalize(vec2( 0.3, -1.0)), wave_steepness * 0.30, wave_length * 0.45, 1.38, t);
	disp += gerstner(v_world_pos.xz, normalize(vec2(-1.0, -0.3)), wave_steepness * 0.20, wave_length * 0.28, 1.65, t);

	VERTEX    += disp * wave_height;
	v_wave_y   = disp.y;
	v_view_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// ══════════════════════════════════════════════════════════════════
//  FRAGMENT
// ══════════════════════════════════════════════════════════════════

void fragment() {
	vec2  wp = v_world_pos.xz * 0.018 * normal_tiling;
	float t  = TIME;

	// ── Procedural normal map (tangent space) ─────────────────────
	vec2 wp1 = wp       + vec2( t * normal_speed * 0.11,  t * normal_speed * 0.07);
	vec2 wp2 = wp * 2.3 + vec2(-t * normal_speed * 0.09,  t * normal_speed * 0.13);

	float nx = (warped_fbm(wp1, 4) * 2.0 - 1.0) * 0.6
	         + (warped_fbm(wp2, 3) * 2.0 - 1.0) * 0.4;
	float nz = (warped_fbm(wp1 + vec2(3.7, 8.1), 4) * 2.0 - 1.0) * 0.6
	         + (warped_fbm(wp2 + vec2(6.3, 2.9), 3) * 2.0 - 1.0) * 0.4;
	float ny  = 1.0 / max(normal_scale, 0.01);
	vec3  nm_ts = normalize(vec3(nx, ny, nz)); // tangent-space surface normal

	NORMAL_MAP       = nm_ts * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = normal_scale;

	// ── Unperturbed depth (for depth_diff & fallback) ─────────────
	float raw_depth  = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec4  ndc_far    = vec4(SCREEN_UV * 2.0 - 1.0, raw_depth, 1.0);
	vec4  view_far4  = INV_PROJECTION_MATRIX * ndc_far;
	view_far4.xyz   /= view_far4.w;
	float depth_diff = max(abs(v_view_pos.z) - abs(view_far4.z), 0.0);
	float depth_t    = clamp(depth_diff / depth_fade_distance, 0.0, 1.0);

	// ── Refraction ────────────────────────────────────────────────
	// The key fix: transform the tangent-space distortion into VIEW space
	// so the screen-UV offset is always correctly oriented.
	// TANGENT, BINORMAL, NORMAL are the surface TBN basis in view space (built-in).
	vec3 view_normal_perturbed = normalize(
		TANGENT  * nm_ts.x +
		BINORMAL * nm_ts.z +
		NORMAL
	);
	// view_normal_perturbed.xy gives us the screen-plane distortion direction
	// Scale down by VIEWPORT_SIZE to get proper UV-space magnitude
	vec2 refr_offset = view_normal_perturbed.xy
	                   * refraction_strength
	                   * clamp(depth_diff * refraction_scale, 0.0, 1.0);

	vec2 refr_uv = SCREEN_UV + refr_offset;

	// Guard: check that the refracted UV doesn't sample geometry that is
	// actually in FRONT of (above) the water surface — if so, fall back to
	// unperturbed UV to avoid sky/air leaking through the water.
	float refr_raw    = texture(DEPTH_TEXTURE, refr_uv).r;
	vec4  refr_ndc    = vec4(refr_uv * 2.0 - 1.0, refr_raw, 1.0);
	vec4  refr_vfar   = INV_PROJECTION_MATRIX * refr_ndc;
	refr_vfar.xyz    /= refr_vfar.w;
	float refr_ddiff  = abs(v_view_pos.z) - abs(refr_vfar.z);
	refr_uv = (refr_ddiff < 0.0) ? SCREEN_UV : refr_uv;

	vec3 refr_col = texture(SCREEN_TEXTURE, refr_uv).rgb;

	// ── 3-stop water colour gradient ──────────────────────────────
	vec4 wc = depth_t < 0.4
		? mix(water_shallow_color, water_mid_color,  depth_t / 0.4)
		: mix(water_mid_color,    water_deep_color, (depth_t - 0.4) / 0.6);
	wc.a = mix(water_shallow_color.a, water_deep_color.a, depth_t);

	// ── Foam ──────────────────────────────────────────────────────
	float foam_amt = 0.0;
	if (foam_enabled) {
		float shore   = 1.0 - smoothstep(0.0, foam_edge_scale, depth_diff);
		float crest_t = clamp(v_wave_y / max(wave_height, 0.001), 0.0, 1.0);
		float crest   = smoothstep(1.0 - foam_threshold, 1.0, crest_t);

		vec2 fwp1 = v_world_pos.xz * 0.025 * foam_noise_scale
		            + vec2( t * foam_speed * 0.055,  t * foam_speed * 0.028);
		vec2 fwp2 = v_world_pos.xz * 0.048 * foam_noise_scale
		            + vec2(-t * foam_speed * 0.038, -t * foam_speed * 0.062);
		float fn      = warped_fbm(fwp1, 5) * 0.6 + warped_fbm(fwp2, 4) * 0.4;
		float lo      = mix(0.38, 0.55, foam_sharpness);
		float hi      = mix(0.72, 0.62, foam_sharpness);
		foam_amt = clamp(shore + crest, 0.0, 1.0) * smoothstep(lo, hi, fn);
	}

	// ── Composite ─────────────────────────────────────────────────
	// shallow: refracted floor tinted by water colour (transparent/clear)
	// deep:    water colour takes over (opaque)
	vec3 col = mix(
		refr_col * mix(vec3(1.0), wc.rgb, water_clarity * 0.8),
		wc.rgb,
		depth_t * water_clarity
	);
	col = mix(col, foam_color.rgb, foam_amt);

	// ── Fresnel ───────────────────────────────────────────────────
	vec3  vd      = normalize(-v_view_pos);
	float NdotV   = clamp(dot(vd, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
	float fresnel = pow(1.0 - NdotV, 3.5);

	ALBEDO    = col;
	ALPHA     = clamp(mix(wc.a, 1.0, fresnel + foam_amt * 0.5), 0.0, 1.0);
	ROUGHNESS = mix(roughness, roughness * 0.15, fresnel);
	METALLIC  = metallic;
	SPECULAR  = specular_strength * fresnel;
}
