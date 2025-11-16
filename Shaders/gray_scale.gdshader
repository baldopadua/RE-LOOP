shader_type canvas_item;

uniform float gray_amount : hint_range(0.0, 1.0) = 0.0; // 0 = color, 1 = grayscale

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    COLOR = vec4(mix(c.rgb, vec3(g), gray_amount), c.a);
}