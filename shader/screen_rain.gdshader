shader_type canvas_item;
render_mode unshaded;

#define iResolution 1.0/SCREEN_PIXEL_SIZE
#define iTime TIME
#define fragColor COLOR

uniform sampler2D iChannel0 : hint_screen_texture, filter_linear_mipmap;
uniform float frequency : hint_range(-10.0, 4.0, 0.1) = 0.0;
uniform float size : hint_range(0.001, 0.05, 0.001) = 0.015;
// Defaults retain the continuous weather effect in Ocean.
uniform float effect_amount : hint_range(0.0, 1.0) = 1.0;
uniform bool splash_mode = false;
uniform float splash_age = 0.0;
uniform float splash_seed = 0.0;
uniform float splash_growth : hint_range(0.0, 1.0) = 1.0;
uniform float splash_density : hint_range(0.0, 1.0) = 1.0;

// Author: Élie Michel
// License: CC BY 3.0
// July 2017

vec2 rand(vec2 c){
    mat2 m = mat2(vec2(12.9898,.16180),vec2(78.233,.31415));
	return fract(sin(m * c) * vec2(43758.5453, 14142.1));
}

vec2 noise(vec2 p){
	vec2 co = floor(p);
	vec2 mu = fract(p);
	mu = 3.*mu*mu-2.*mu*mu*mu;
	vec2 a = rand((co+vec2(0.,0.)));
	vec2 b = rand((co+vec2(1.,0.)));
	vec2 c = rand((co+vec2(0.,1.)));
	vec2 d = rand((co+vec2(1.,1.)));
	return mix(mix(a, b, mu.x), mix(c, d, mu.x), mu.y);
}

void fragment()
{
	vec2 u = UV,
         v = UV * 0.1,
         n = noise(v*200. + vec2(splash_seed)); // Displacement
    
    fragColor = texture(iChannel0, u);
    
    // Loop through the different inverse sizes of drops
    for (float r = 4. ; r > frequency ; r--) {
        vec2 x = iResolution.xy * r * size,  // Number of potential drops (in a grid)
             p = 6.28 * u * x + (n - .5) * 2.,
             s = sin(p);
        
        // Current drop properties. Coordinates are rounded to ensure a
        // consistent value among the fragment of a given drop.
        //vec4 d = texture(iChannel1, round(u * x - 0.25) / x);
        vec2 v = round(u * x - 0.25) / x;
        vec4 d = vec4(noise(v*200.), noise(v));
        
        // Drop shape and fading
        float phase = splash_mode ? .06 + splash_age * (d.b + .1) * .12 : fract(iTime * (d.b + .1) + d.g);
        float t = (s.x+s.y) * max(0., 1. - phase * 2.);
        
        // d.r -> only x% of drops are kept on, with x depending on the size of drops
        // Raise the shape threshold at onset: each drop grows around its
        // own fixed center instead of scaling the whole screen's pattern.
        float cutoff = splash_mode ? mix(1.8, .5, splash_growth) : .5;
        float density = splash_mode ? splash_density : 1.0;
        if (d.r < (5.-r)*.08 * density && t > cutoff) {
            // Drop normal
            vec3 v = normalize(-vec3(cos(p), mix(.2, 2., t-.5)));
             //fragColor = vec4(v * 0.5 + 0.5, 1.0);  // show normals
            
            // Poor man's refraction (no visual need to do more)
            fragColor = texture(iChannel0, u - v.xy * .3);
        }
    }
    
    fragColor = mix(texture(iChannel0, u), fragColor, effect_amount);
    // Debug noise function
    //f = vec4(n, 0.0, 1.0);
}
