shader_type sky;

uniform vec4 bg_color : source_color = vec4(0.02, 0.01, 0.05, 1.0);
uniform vec4 nebula_color1 : source_color = vec4(0.5, 0.1, 0.6, 1.0);
uniform vec4 nebula_color2 : source_color = vec4(0.1, 0.4, 0.7, 1.0);

uniform float star_density : hint_range(1.0, 100.0) = 50.0;
uniform float star_threshold : hint_range(0.0, 1.0) = 0.995;

// Basic 3D Noise function for nebulas and stars
float hash(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1, 0.1, 0.1));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 x) {
    vec3 i = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
                   mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
                   mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y), f.z);
}

void sky() {
    // EYEDIR represents the direction the camera is looking
    vec3 dir = EYEDIR;
    
    // 1. Create Nebula Colors using layered noise
    float n1 = noise(dir * 3.0);
    float n2 = noise(dir * 6.0 + vec3(2.0, 1.0, 4.0));
    
    vec3 nebula = mix(nebula_color1.rgb, nebula_color2.rgb, n2) * n1;
    vec3 final_color = mix(bg_color.rgb, nebula, 0.6);
    
    // 2. Generate Procedural Stars
    vec3 star_grid = floor(dir * star_density); // Store the grid position
    float star_noise = hash(star_grid);
    
    if (star_noise > star_threshold) {
        // Give stars slight brightness variations
        float intensity = (star_noise - star_threshold) / (1.0 - star_threshold);
        
        // FIX: Use the star_grid here so the entire star shares the same random seed!
        float rand = hash(star_grid + vec3(1.0)); 
        
        // Calculate twinkle using TIME
        float twinkle = 0.4 + 0.6 * sin(TIME * (rand) + rand * 10.0);
        
        final_color += vec3(intensity) * twinkle;
    }
    
    COLOR = final_color;
}