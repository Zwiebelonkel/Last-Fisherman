shader_type sky;

// Wird vom AnimationPlayer gesteuert (0.0 = Mitternacht, 0.5 = Mittag, 1.0 = Mitternacht)
uniform float time_of_day : hint_range(0.0, 1.0) = 0.35;

// Tag-Farben
uniform vec4 day_zenith   : source_color = vec4(0.18, 0.48, 0.90, 1.0);
uniform vec4 day_horizon  : source_color = vec4(0.72, 0.90, 1.00, 1.0);

// Sonnenaufgang/Untergang
uniform vec4 sunset_zenith  : source_color = vec4(0.25, 0.12, 0.28, 1.0);
uniform vec4 sunset_horizon : source_color = vec4(1.00, 0.45, 0.10, 1.0);
uniform vec4 sunset_glow    : source_color = vec4(1.00, 0.70, 0.20, 1.0);

// Nacht-Farben
uniform vec4 night_zenith  : source_color = vec4(0.01, 0.01, 0.06, 1.0);
uniform vec4 night_horizon : source_color = vec4(0.03, 0.04, 0.12, 1.0);

// Sonne & Mond
uniform float sun_size       : hint_range(0.001, 0.15) = 0.025;
uniform float sun_glow_power : hint_range(1.0, 16.0)   = 4.5;
uniform float moon_size      : hint_range(0.001, 0.1)  = 0.018;

// Wolken
uniform float cloud_speed   : hint_range(0.0, 1.0) = 0.015;
uniform float cloud_scale   : hint_range(0.1, 4.0) = 1.1;
uniform float cloud_density : hint_range(0.0, 1.0) = 0.50;

// ─────────────────────────────────────────────
// Noise
// ─────────────────────────────────────────────
float hash(vec2 p) {
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i),             hash(i + vec2(1,0)), u.x),
        mix(hash(i+vec2(0,1)),   hash(i + vec2(1,1)), u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0; float a = 0.5;
    mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
    for (int i = 0; i < 5; i++) { v += a * vnoise(p); p = rot * p * 2.1; a *= 0.48; }
    return v;
}

float cloud_shape(vec2 uv, float t, float offset) {
    vec2 p = uv * cloud_scale + vec2(t + offset, offset * 0.3);
    vec2 q = vec2(fbm(p), fbm(p + vec2(5.2, 1.3)));
    float raw = fbm(p + q);
    return step(cloud_density + offset * 0.04, raw);
}

// ─────────────────────────────────────────────
// SKY
// ─────────────────────────────────────────────
void sky() {
    vec3 dir = normalize(EYEDIR);

    // time_of_day: 0=Nacht, 0.25=Sonnenaufgang, 0.5=Mittag, 0.75=Sonnenuntergang, 1=Nacht
    float tod = time_of_day;

    // Sonne dreht sich über den Himmel (Y-Kurve)
    float sun_angle = tod * TAU;
    vec3 sun_dir = normalize(vec3(sin(sun_angle), cos(sun_angle) * 0.8, -0.6));

    // Mond ist gegenüber der Sonne
    vec3 moon_dir = -sun_dir;

    // Wie hoch steht die Sonne? 0=Horizont/unter, 1=Zenit
    float sun_height = clamp(sun_dir.y, 0.0, 1.0);
    float sun_below  = clamp(-sun_dir.y, 0.0, 1.0); // Sonne unter Horizont = Nacht

    // Tageszeit-Phasen
    float is_day     = smoothstep(0.0, 0.15, sun_height);
    float is_night   = smoothstep(0.0, 0.15, sun_below);
    float is_sunset  = 1.0 - smoothstep(0.0, 0.22, abs(sun_dir.y)); // nahe Horizont

    // ── Himmels-Gradient ──────────────────────────────────────────
    float up = clamp(dir.y, 0.0, 1.0);

    vec3 c_zenith  = mix(mix(night_zenith.rgb,  sunset_zenith.rgb,  is_sunset), day_zenith.rgb,  is_day);
    vec3 c_horizon = mix(mix(night_horizon.rgb, sunset_horizon.rgb, is_sunset), day_horizon.rgb, is_day);

    vec3 sky_col = mix(c_horizon, c_zenith, smoothstep(0.0, 0.6, up));

    // Sonnenuntergangs-Glow am Horizont (Richtung Sonne)
    float sun_horiz_dot = dot(dir, sun_dir) * 0.5 + 0.5;
    sky_col += sunset_glow.rgb * pow(sun_horiz_dot, 8.0) * is_sunset * 0.8 * (1.0 - up * 2.0);

    // ── Sterne (nur nachts) ───────────────────────────────────────
    float star_brightness = is_night * (1.0 - is_sunset * 2.0);
    if (dir.y > 0.0) {
        vec2 star_uv = dir.xz / max(dir.y, 0.001) * 0.5;
        float s1 = pow(clamp(hash(floor(star_uv * 60.0)), 0.0, 1.0), 120.0);
        float s2 = pow(clamp(hash(floor(star_uv * 120.0) + vec2(13.7)), 0.0, 1.0), 200.0);
        float twinkle = sin(TIME * 2.0 + hash(floor(star_uv * 60.0)) * 10.0) * 0.3 + 0.7;
        sky_col += vec3(0.9, 0.92, 1.0) * (s1 + s2 * 0.5) * star_brightness * twinkle * 3.0;
    }

    // ── Milchstraße-Andeutung (nachts) ───────────────────────────
    if (dir.y > 0.05) {
        vec2 mw_uv = dir.xz / dir.y * 0.3;
        float mw = fbm(mw_uv * 0.4 + vec2(1.3, 2.7)) * 0.06 * star_brightness;
        sky_col += vec3(0.5, 0.55, 0.8) * mw;
    }

    // ── Sonne ─────────────────────────────────────────────────────
    float sun_dot  = dot(dir, sun_dir);
    float sun_disc = step(1.0 - sun_size, sun_dot);

    // Glow-Ringe (harte Stufen für leichten Stylize-Look)
    float g1 = step(1.0 - sun_size * 3.0,  sun_dot) * 0.25;
    float g2 = step(1.0 - sun_size * 8.0,  sun_dot) * 0.12;
    float g3 = step(1.0 - sun_size * 18.0, sun_dot) * 0.06;
    float g4 = pow(clamp(sun_dot, 0.0, 1.0), sun_glow_power) * 0.5;

    // Sonnenfarbe: weiß-gelb bei Tag, orange-rot bei Untergang
    vec3 sun_col = mix(vec3(1.0, 0.55, 0.1), vec3(1.0, 0.97, 0.85), sun_height);
    sky_col += sun_col * (sun_disc + g1 + g2 + g3 + g4) * (1.0 - is_night);

    // ── Mond ──────────────────────────────────────────────────────
    float moon_dot  = dot(dir, moon_dir);
    float moon_disc = step(1.0 - moon_size, moon_dot);
    float moon_glow = step(1.0 - moon_size * 5.0, moon_dot) * 0.08;
    float moon_atm  = pow(clamp(moon_dot, 0.0, 1.0), 12.0) * 0.15;
    // Mondsichel via zweiter Kreis-Subtraktion
    vec3 moon_offset_dir = normalize(moon_dir + vec3(moon_size * 3.5, moon_size * 1.0, 0.0));
    float moon_cut = step(1.0 - moon_size * 1.1, dot(dir, moon_offset_dir));
    float moon_shape = clamp(moon_disc - moon_cut, 0.0, 1.0);

    sky_col += vec3(0.92, 0.94, 1.0) * (moon_shape * 1.8 + moon_glow + moon_atm) * is_night;

    // ── Wolken ────────────────────────────────────────────────────
    float cloud_mask = smoothstep(-0.02, 0.15, dir.y);
    float y_s = max(abs(dir.y), 0.015);
    vec2 c_uv = dir.xz / y_s * 0.4;
    float t   = TIME * cloud_speed;

    float clouds = 0.0;
    float shads  = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi  = float(i);
        float sf  = 1.0 - fi * 0.2;
        float af  = 1.0 - fi * 0.28;
        float c   = cloud_shape(c_uv * sf, t * (1.0 - fi * 0.22), fi * 2.3);
        float sh  = cloud_shape(c_uv * sf + vec2(0.0, 0.018), t * (1.0 - fi * 0.22), fi * 2.3 + 0.1);
        clouds   += c  * af;
        shads    += max(sh - c, 0.0) * af * 0.5;
    }
    clouds = clamp(clouds, 0.0, 1.0) * cloud_mask;
    shads  = clamp(shads,  0.0, 1.0) * cloud_mask;

    // Wolkenfarbe abhängig von Tageszeit
    vec3 cloud_day    = vec3(1.0, 0.98, 0.96);
    vec3 cloud_sunset = vec3(1.0, 0.60, 0.25);
    vec3 cloud_night  = vec3(0.12, 0.14, 0.22);
    vec3 cloud_bot_d  = vec3(0.72, 0.76, 0.82);
    vec3 cloud_bot_n  = vec3(0.05, 0.06, 0.10);

    vec3 cloud_top = mix(mix(cloud_night, cloud_sunset, is_sunset), cloud_day, is_day);
    vec3 cloud_bot = mix(cloud_bot_n, cloud_bot_d, is_day);

    vec3 cloud_col = mix(cloud_bot, cloud_top, clamp(dir.y * 3.0, 0.0, 1.0));
    sky_col = mix(sky_col, cloud_col,      clouds);
    sky_col = mix(sky_col, cloud_bot * 0.6, shads * (1.0 - clouds));

    // ── Posterize (leicht, für stilisierten Look) ─────────────────
    float ps = 18.0; // mehr Stufen als Pixel-Shader → weicher
    float r = floor(sky_col.r * ps) / ps;
    float g = floor(sky_col.g * ps) / ps;
    float b = floor(sky_col.b * ps) / ps;

    COLOR = vec3(r, g, b);
}
