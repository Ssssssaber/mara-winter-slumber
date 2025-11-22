shader_type spatial;
uniform sampler2D noise_texture;
uniform float speed = 1.0;
uniform vec2 direction = vec2(1.0, 0.0);

render_mode shadows_disabled;

void fragment() {
  vec2 animated_uv = UV + (TIME * speed * direction);
  vec4 noise_color = texture(noise_texture, animated_uv);
  ALBEDO = noise_color.rgb;
}
