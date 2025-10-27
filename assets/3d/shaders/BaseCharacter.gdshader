shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // White outline
uniform float line_thickness : hint_range(0, 10) = 1.0;

// Manually define the texture size (adjust based on your sprite's resolution)
const vec2 TEXTURE_SIZE = vec2(128.0, 128.0);  // Replace with your sprite's resolution

const vec2 OFFSETS[8] = {
    vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1),
    vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
    // Calculate the pixel size based on the texture size
    vec2 size = line_thickness / TEXTURE_SIZE;

    float outline = 0.0;

    // Sample neighboring pixels using ALBEDO_TEXTURE
    for (int i = 0; i < OFFSETS.length(); i++) {
        outline += texture(ALBEDO_TEXTURE, UV + size * OFFSETS[i]).a;
    }
    outline = min(outline, 1.0);

    // Sample the current pixel using ALBEDO_TEXTURE
    vec4 color = texture(ALBEDO, UV);

    // Mix the original color with the outline color
    ALBEDO = mix(color.rgb, line_color.rgb, outline - color.a);
    ALPHA = color.a;
}
