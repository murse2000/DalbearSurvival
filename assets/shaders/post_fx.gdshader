shader_type canvas_item;
render_mode unshaded;

// Full-screen post FX: bloom, chromatic aberration, impact warp, grading,
// hurt vignette, grain and a flash. Screen texture is sampled once per tap.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float bloom_strength : hint_range(0.0, 4.0) = 0.95;
uniform float aberration : hint_range(0.0, 0.04) = 0.0;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 0.94, 0.78, 1.0);
uniform float warp : hint_range(0.0, 0.5) = 0.0;
uniform float hurt : hint_range(0.0, 1.0) = 0.0;
uniform float vignette : hint_range(0.0, 1.5) = 0.62;
uniform float grain : hint_range(0.0, 0.2) = 0.022;
uniform vec4 grade_color : source_color = vec4(0.6, 0.35, 0.9, 1.0);
uniform float grade_amount : hint_range(0.0, 1.0) = 0.0;
uniform float zoom : hint_range(1.0, 1.15) = 1.0;
uniform float shock : hint_range(0.0, 1.0) = 0.0;
uniform float speed_lines : hint_range(0.0, 1.0) = 0.0;
uniform vec4 speed_color : source_color = vec4(1.0, 0.82, 0.45, 1.0);
uniform float saturation : hint_range(0.0, 1.6) = 1.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv = (uv - 0.5) / max(zoom, 1.0) + 0.5;
	vec2 c = uv - 0.5;
	float r2 = dot(c, c);

	// big-impact lens warp + radial shock ring
	uv = 0.5 + c * (1.0 - warp * r2 * 2.4);
	vec2 radial = normalize(c + vec2(0.0001));
	uv += radial * shock * 0.018 * sin(length(c) * 34.0 - TIME * 12.0);

	// radial chromatic aberration
	float ab = aberration * (0.35 + r2 * 2.2);
	vec3 col;
	col.r = texture(screen_texture, uv + radial * ab).r;
	col.g = texture(screen_texture, uv).g;
	col.b = texture(screen_texture, uv - radial * ab).b;

	// cheap two-ring bloom
	vec3 glow = vec3(0.0);
	for (int i = 0; i < 8; i++) {
		float a = float(i) * 0.785398;
		vec2 o = vec2(cos(a), sin(a));
		glow += texture(screen_texture, uv + o * 0.0034).rgb;
		glow += texture(screen_texture, uv + o * 0.0078).rgb * 0.65;
	}
	glow /= 13.2;
	glow = max(glow - 0.60, 0.0) * 1.75;
	col += glow * bloom_strength;

	// radial anime speed lines (combo / dash / ultimate / boss finish)
	float ang = atan(c.y, c.x);
	float lines = pow(max(0.0, sin(ang * 52.0 + TIME * 6.5)), 24.0);
	float line_edge = smoothstep(0.14, 0.62, length(c));
	col += speed_color.rgb * speed_lines * lines * line_edge * 1.7;

	// punchy combo color grading
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, saturation);

	// color grade for bosses / dawn
	col = mix(col, col * grade_color.rgb + grade_color.rgb * 0.10, grade_amount);

	// hurt edges
	float edge = smoothstep(0.38, 0.74, length(c));
	col = mix(col, vec3(0.88, 0.07, 0.10), edge * hurt * 0.42);

	// vignette
	col *= mix(1.0, 0.40, smoothstep(0.32, 0.86, length(c)) * vignette);

	// film grain
	float n = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
	col += (n - 0.5) * grain;

	col = mix(col, flash_color.rgb, clamp(flash, 0.0, 1.0));
	COLOR = vec4(col, 1.0);
}
