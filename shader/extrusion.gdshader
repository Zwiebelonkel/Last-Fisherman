shader_type spatial;
render_mode unshaded;
uniform float extruded_alpha_cull : hint_range(0.0, 1.0) = 1.0;
uniform float extrude_scale : hint_range(0.0, 1.0) = 0.1;
uniform bool opaque_extrude = true;
uniform bool keep_image = true;
uniform float image_alpha_cull : hint_range(0.0, 1.0) = 1.0;
uniform vec2 offset = vec2(0.0);
uniform vec4 color_mix : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float mix_strength : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D Texture : source_color, filter_nearest;
uniform int texture_calls = 20;
uniform float ray_bias = 1.0;
uniform bool infinite_holes = false;
uniform int Hframes = 1;
uniform int Vframes = 1;
uniform int frame = 0;
uniform bool hide_sides = true;

struct imgPoint {
	vec4 color;
	vec2 uv;
};

bool isInImg(vec2 uv){
	return uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0;
}

vec2 getPositionAlongTheLine(vec2 a, vec2 b, float percentage) {
	return vec2(a.x * (1.0 - percentage) + b.x * percentage, a.y * (1.0 - percentage) + b.y * percentage);
}

vec2 lineImgIntersect(vec2 x, vec2 y){
	float t = 0.0;
	float xY = y.x; float yY = -y.y;
	float xX = x.x; float yX = -x.y;
	float xA = 0.0; float yA = -1.0;
	float xC = 1.0; float yC = -0.0;
	if(xY == xX) {
		t = max((yA - yX)/(yY - yX), (yC - yX)/(yY - yX));
	} else {
		if(yY == yX) {
			t = max((xA - xX)/(xY - xX), (xC - xX)/(xY - xX));
		} else {
			if(xY > xX) {
				if(yY > yX) t = min((xC - xX)/(xY - xX), (yC - yX)/(yY - yX));
				else t = min((xC - xX)/(xY - xX), (yA - yX)/(yY - yX));
			} else {
				if(yY > yX) t = min((xA - xX)/(xY - xX), (yC - yX)/(yY - yX));
				else t = min((xA - xX)/(xY - xX), (yA - yX)/(yY - yX));
			}
		}
	}
	return vec2(t * xY + (1.0 - t) * xX, -(t * yY + (1.0 - t) * yX));
}

vec2 frameUV(vec2 uv){
	int hFrame = frame % max(Hframes, 1);
	int vFrame = (frame / max(Hframes, 1)) % max(Vframes, 1);
	uv.x = uv.x/float(max(Hframes,1)) + float(hFrame)/float(max(Hframes,1));
	uv.y = uv.y/float(max(Vframes,1)) + float(vFrame)/float(max(Vframes,1));
	return uv;
}

vec2 flippedFrameUV(vec2 uv){
	float frameCenter = 0.5/float(max(Hframes,1)) + float(frame % max(Hframes,1))/float(max(Hframes,1));
	uv = frameUV(uv);
	uv.x = -(uv.x - frameCenter) + frameCenter;
	return uv;
}

imgPoint imgExtrude(vec2 pos_on_img, vec2 slope, bool flipped){
	vec4 color;
	slope.y *= -1.0;

	// FIX: Wenn slope fast null ist, direkt samplen und keine Extrusion versuchen
	if (length(slope) < 0.0001) {
		vec2 mapped = flipped ? flippedFrameUV(pos_on_img) : frameUV(pos_on_img);
		vec4 c = texture(Texture, mapped + offset);
		return imgPoint(c, pos_on_img);
	}

	vec2 edge = lineImgIntersect(pos_on_img, pos_on_img + slope);

	vec2 mapped_pos = flipped ? flippedFrameUV(pos_on_img) : frameUV(pos_on_img);
	vec2 mapped_edge = flipped ? flippedFrameUV(edge) : frameUV(edge);

	// FIX: Prüfe ob die Start-Position schon außerhalb liegt → nicht extrudieren
	if (!isInImg(pos_on_img)) {
		return imgPoint(vec4(0.0), pos_on_img);
	}

	bool extrude = false;
	vec2 point = mapped_edge;
	vec2 raw_point = edge;

	int calls = max(texture_calls, 1);

	// FIX: Einfacher linearer Scan für stabiles Verhalten bei extremen Winkeln
	vec4 best_color = vec4(0.0);
	vec2 best_point = mapped_pos;
	vec2 best_raw = pos_on_img;

	for (int i = 0; i < calls; i++){
		float percentage = float(i) / float(calls - 1 > 0 ? calls - 1 : 1);
		percentage = pow(percentage, max(ray_bias, 0.0001));

		vec2 raw_sample = getPositionAlongTheLine(pos_on_img, edge, percentage);

		// FIX: Nur samplen wenn raw UV im Bild-Bereich liegt
		if (!isInImg(raw_sample)) continue;

		vec2 mapped_sample = flipped ? flippedFrameUV(raw_sample) : frameUV(raw_sample);
		vec4 c = texture(Texture, mapped_sample + offset);

		if (c.a >= extruded_alpha_cull) {
			best_color = c;
			best_point = mapped_sample;
			best_raw = raw_sample;
			extrude = true;
		}
	}

	if (extrude) {
		if (opaque_extrude) best_color.a = 1.0;
		best_color = mix(best_color, color_mix, mix_strength);
		if (infinite_holes) return imgPoint(best_color, pos_on_img);
		return imgPoint(best_color, best_raw);
	}

	// FIX: Fallback → originale Farbe zurückgeben statt transparent/schwarz
	vec4 orig = texture(Texture, mapped_pos + offset);
	return imgPoint(orig, pos_on_img);
}

vec2 UVtoXY(vec2 uv){
	vec2 xy = uv * 2.0 - vec2(1.0);
	xy.y *= -1.0;
	return xy;
}
vec2 XYtoUV(vec2 xy){
	vec2 uv = (xy + vec2(1.0)) / 2.0;
	uv.y *= -1.0;
	return uv;
}

vec3 PlaneLineIntersection(vec3 plane_point, vec3 plane_normal, vec3 line_point, vec3 line_dir){
    vec3 dir_n = normalize(line_dir);
    float denom = dot(plane_normal, dir_n);

    if (abs(denom) < 0.01) { 
        return line_point;
    }

    float t = (dot(plane_normal, plane_point) - dot(plane_normal, line_point)) / denom;
    t = clamp(t, -10.0, 10.0);

    return line_point + dir_n * t;
}

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = 0.0;

	vec3 frag_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 camera_ray = normalize(frag_pos - CAMERA_POSITION_WORLD);
	vec3 model_ray_full = normalize((inverse(MODEL_MATRIX) * vec4(camera_ray, 0.0)).xyz);

	vec3 model_ray = vec3(model_ray_full.xy * extrude_scale, model_ray_full.z);

	ivec2 face = ivec2(UV / vec2(1.0/3.0, 1.0/2.0));
	face.x = clamp(face.x, 0, 2);
	face.y = clamp(face.y, 0, 1);

	vec2 adjusted_UV = mod(UV, vec2(1.0/3.0, 1.0/2.0)) * vec2(3.0, 2.0);
	// FIX: adjusted_UV clampen damit es nie exakt 1.0 überschreitet durch float-Fehler
	adjusted_UV = clamp(adjusted_UV, vec2(0.0), vec2(1.0));

	// FRONT (+Z)
	if (face.x == 0 && face.y == 0) {
		vec4 color = texture(Texture, frameUV(adjusted_UV));
		if (color.a >= image_alpha_cull && keep_image) {
			ALBEDO = color.rgb;
			ALPHA = color.a;
		} else {
			imgPoint first_pixel = imgExtrude(adjusted_UV, model_ray.xy, false);
			ALBEDO = first_pixel.color.rgb;
			ALPHA = first_pixel.color.a;

			vec3 point = vec3(UVtoXY(adjusted_UV), 2.0);
			vec3 ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, model_ray);
			vec2 uv_point = XYtoUV(ray_intersection.xy) + vec2(0.0, 1.0);

			if (isInImg(uv_point)) {
				imgPoint second_pixel = imgExtrude(uv_point, -model_ray.xy, false);
				if (model_ray.y <= 0.0 && second_pixel.uv.y < first_pixel.uv.y) ALPHA = 0.0;
				else if (model_ray.y > 0.0 && second_pixel.uv.y > first_pixel.uv.y) ALPHA = 0.0;
			}
		}
	}

	// BACK (-Z)
	else if (face.x == 2 && face.y == 0) {
		vec4 color = texture(Texture, flippedFrameUV(adjusted_UV));
		if (color.a >= image_alpha_cull && keep_image) {
			ALBEDO = color.rgb;
			ALPHA = color.a;
		} else {
			imgPoint first_pixel = imgExtrude(adjusted_UV, vec2(-model_ray.x, model_ray.y), true);
			ALBEDO = first_pixel.color.rgb;
			ALPHA = first_pixel.color.a;

			vec3 point = vec3(UVtoXY(vec2(-adjusted_UV.x, adjusted_UV.y)), -2.0);
			vec3 ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, model_ray);
			vec2 uv_point = XYtoUV(ray_intersection.xy) + vec2(1.0, 1.0);

			if (isInImg(uv_point)) {
				imgPoint second_pixel = imgExtrude(uv_point, -model_ray.xy, false);
				if (model_ray.y <= 0.0 && second_pixel.uv.y < first_pixel.uv.y) ALPHA = 0.0;
				else if (model_ray.y > 0.0 && second_pixel.uv.y > first_pixel.uv.y) ALPHA = 0.0;
			}
		}
	}

	// RIGHT (+X)
	else if (face.x == 1 && face.y == 0) {
		if (hide_sides) discard;
		vec3 point = vec3(0.0, UVtoXY(adjusted_UV).yx);
		vec3 ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, -model_ray);
		vec3 image_intersection = PlaneLineIntersection(vec3(0.0), vec3(1.0,0.0,0.0), ray_intersection, vec3(model_ray.xy, 0.0));
		vec2 new_uv = XYtoUV(image_intersection.xy) + vec2(0.5, 1.0);
		new_uv = clamp(new_uv, vec2(0.0), vec2(1.0));

		vec4 img_color = imgExtrude(new_uv, model_ray.xy, false).color;
		ALBEDO = img_color.rgb;
		ALPHA = img_color.a;

		vec2 xy = UVtoXY(adjusted_UV);
		if (model_ray.z > 0.0) point = vec3(1.0, xy.y, -1.0 - xy.x);
		else point = vec3(1.0, xy.y, 1.0 - xy.x);

		ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, model_ray);
		vec2 uv_point = XYtoUV(ray_intersection.xy) + vec2(0.0, 1.0);

		if (isInImg(uv_point)) {
			vec4 ic = imgExtrude(uv_point, -model_ray.xy, false).color;
			if (ic.a < 0.01) ALPHA = 0.0;
		}
	}

	// LEFT (-X)
	else if (face.x == 0 && face.y == 1) {
		if (hide_sides) discard;
		vec3 point = vec3(0.0, UVtoXY(adjusted_UV).yx);
		vec3 ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, -model_ray);
		vec3 image_intersection = PlaneLineIntersection(vec3(0.0), vec3(-1.0,0.0,0.0), ray_intersection, vec3(model_ray.xy, 0.0));
		vec2 new_uv = XYtoUV(image_intersection.xy) + vec2(-0.5, 1.0);
		new_uv = clamp(new_uv, vec2(0.0), vec2(1.0));

		vec4 img_color = imgExtrude(new_uv, model_ray.xy, false).color;
		ALBEDO = img_color.rgb;
		ALPHA = img_color.a;

		vec2 xy = UVtoXY(adjusted_UV);
		if (model_ray.z > 0.0) point = vec3(-1.0, xy.y, -1.0 + xy.x);
		else point = vec3(-1.0, xy.y, 1.0 + xy.x);

		ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, model_ray);
		vec2 uv_point = XYtoUV(ray_intersection.xy) + vec2(0.0, 1.0);

		if (isInImg(uv_point)) {
			vec4 ic = imgExtrude(uv_point, -model_ray.xy, false).color;
			if (ic.a < 0.01) ALPHA = 0.0;
		}
	}

	// TOP (+Y)
	else if (face.x == 1 && face.y == 1) {
		if (hide_sides) discard;
		vec2 rotated_UV = -UVtoXY(adjusted_UV);
		vec3 point = vec3(rotated_UV.x, 0.0, rotated_UV.y);

		vec3 ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, -model_ray);
		vec3 image_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,1.0,0.0), ray_intersection, vec3(model_ray.xy, 0.0));
		vec2 new_uv = XYtoUV(image_intersection.xy) + vec2(0.0, 0.5);
		new_uv = clamp(new_uv, vec2(0.0), vec2(1.0));

		vec4 img_color = imgExtrude(new_uv, model_ray.xy, false).color;
		ALBEDO = img_color.rgb;
		ALPHA = img_color.a;

		vec2 xy = UVtoXY(vec2(-adjusted_UV.x, adjusted_UV.y));
		if (model_ray.z > 0.0) point = vec3(xy.x, 1.0, xy.y - 1.0);
		else point = vec3(xy.x, 1.0, xy.y + 1.0);

		ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, model_ray);
		vec2 uv_point = XYtoUV(ray_intersection.xy) + vec2(1.0, 1.0);

		if (isInImg(uv_point)) {
			vec4 ic = imgExtrude(uv_point, -model_ray.xy, false).color;
			if (ic.a < 0.01) ALPHA = 0.0;
		}
	}

	// BOTTOM (-Y)
	else if (face.x == 2 && face.y == 1) {
		if (hide_sides) discard;
		vec2 XY = UVtoXY(adjusted_UV);
		vec3 point = vec3(XY.x, 0.0, XY.y);

		vec3 ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, -model_ray);
		vec3 image_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,-1.0,0.0), ray_intersection, vec3(model_ray.xy, 0.0));
		vec2 new_uv = XYtoUV(image_intersection.xy) + vec2(0.0, 1.5);
		new_uv = clamp(new_uv, vec2(0.0), vec2(1.0));

		vec4 img_color = imgExtrude(new_uv, model_ray.xy, false).color;
		ALBEDO = img_color.rgb;
		ALPHA = img_color.a;

		vec2 xy = UVtoXY(adjusted_UV);
		if (model_ray.z > 0.0) point = vec3(xy.x, -1.0, xy.y - 1.0);
		else point = vec3(xy.x, -1.0, xy.y + 1.0);

		ray_intersection = PlaneLineIntersection(vec3(0.0), vec3(0.0,0.0,1.0), point, model_ray);
		vec2 uv_point = XYtoUV(ray_intersection.xy) + vec2(0.0, 1.0);

		if (isInImg(uv_point)) {
			vec4 ic = imgExtrude(uv_point, -model_ray.xy, false).color;
			if (ic.a < 0.01) ALPHA = 0.0;
		}
	}

	if (ALPHA <= 0.01) discard;
}
