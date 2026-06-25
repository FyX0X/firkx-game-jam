shader_type spatial;

render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D screen_tex;
uniform vec3 hologram_color : source_color;

void vertex() {
    mat4 modified_model_view = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = modified_model_view;
}

void fragment() {
    vec2 uv = UV;
    vec4 col = texture(screen_tex, uv);

    // hologram tint
    col.rgb = vec3(1.0, 1.0, 1.0) * col.a;

    // scanline effect
    float scan = sin(uv.y * 100.0 + TIME * 20.0) * 0.2;
    col.rgb += scan;

    ALBEDO = col.rgb * hologram_color;
    ALPHA = col.a * 0.5;
}