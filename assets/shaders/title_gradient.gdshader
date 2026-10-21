shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.012, 0.024, 0.045, 1.0);

void fragment() {
	float a = smoothstep(0.62, 0.02, UV.x) * 0.68;
	a = max(a, smoothstep(0.55, 1.0, UV.y) * 0.45);
	a = max(a, smoothstep(0.0, 0.22, UV.y) * 0.25);
	COLOR = vec4(tint.rgb, a);
}
