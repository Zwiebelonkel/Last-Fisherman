shader_type canvas_item;

uniform vec2 shadow_offset = vec2(8.0, 8.0);
uniform vec4 shadow_color = vec4(0.0, 0.0, 0.0, 0.5);

// 🆕 Bobbing Parameters
uniform float bobbing_amplitude = 5.0;   // Höhe der Bewegung in Pixeln
uniform float bobbing_speed = 2.0;        // Geschwindigkeit
uniform bool enable_bobbing = true;

// 🆕 Sway (Schwanken) Parameters
uniform float sway_amplitude = 3.0;       // Horizontale Schwankung
uniform float sway_speed = 1.5;           // Geschwindigkeit des Schwankens
uniform bool enable_sway = false;

// 🆕 Pulse (Pulsieren) - für seltene Items
uniform float pulse_amount = 0.1;         // Wie stark pulsiert (0.0 - 1.0)
uniform float pulse_speed = 3.0;          // Geschwindigkeit
uniform bool enable_pulse = false;

void fragment() {
    vec2 uv = UV;
    float scale = 1.0;
    
    // 🆕 Bobbing-Effekt (Auf und Ab)
    if (enable_bobbing) {
        float bob_offset = sin(TIME * bobbing_speed) * (bobbing_amplitude / vec2(textureSize(TEXTURE, 0)).y);
        uv.y += bob_offset;
    }
    
    // 🆕 Sway-Effekt (Links-Rechts Schwanken)
    if (enable_sway) {
        float sway_offset = sin(TIME * sway_speed + 1.5) * (sway_amplitude / vec2(textureSize(TEXTURE, 0)).x);
        uv.x += sway_offset;
    }
    
    // 🆕 Pulse-Effekt (Größe pulsiert)
    if (enable_pulse) {
        scale = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
        // UV vom Zentrum aus skalieren
        uv = (uv - 0.5) / scale + 0.5;
    }
    
    // Original-Icon-Farbe mit Effekten
    vec4 tex_color = texture(TEXTURE, uv);
    
    // Shadow sampling mit Offset UND Effekten
    vec2 offset_uv = uv + shadow_offset / vec2(textureSize(TEXTURE, 0));
    vec4 shadow_tex = texture(TEXTURE, offset_uv);
    
    // Alpha des Schattens = Icon-Alpha * Shadow-Alpha
    vec4 shadow = vec4(shadow_color.rgb, shadow_tex.a * shadow_color.a);
    
    // Shadow unter Icon mischen
    COLOR = shadow + tex_color;
    
    // 🆕 Optional: Leichtes Glühen bei Pulse
    if (enable_pulse) {
        float glow = sin(TIME * pulse_speed) * 0.2 + 0.8;
        COLOR.rgb *= glow;
    }
}
