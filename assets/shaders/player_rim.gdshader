shader_type canvas_item;
render_mode unshaded;

// Cheap alpha-edge rim used by the player's backlight silhouette.
// The source is the same sprite sheet as the bear, so the glow follows every
// animation frame without a second set of authored art.

uniform vec4 rim_color : source_color = vec4(1.0, 0.82, 0.42, 1.0);
uniform float rim_width_px : hint_range(0.5, 6.0) = 4.0;
uniform float rim_strength : hint_range(0.0, 2.0) = 1.5;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (base.a < 0.05) {
		discard;
	}
	vec2 px = TEXTURE_PIXEL_SIZE * rim_width_px;
	float edge = 0.0;
	edge += max(0.0, base.a - texture(TEXTURE, UV + vec2(px.x, 0.0)).a);
	edge += max(0.0, base.a - texture(TEXTURE, UV - vec2(px.x, 0.0)).a);
	edge += max(0.0, base.a - texture(TEXTURE, UV + vec2(0.0, px.y)).a);
	edge += max(0.0, base.a - texture(TEXTURE, UV - vec2(0.0, px.y)).a);
	edge += max(0.0, base.a - texture(TEXTURE, UV + px).a);
	edge += max(0.0, base.a - texture(TEXTURE, UV - px).a);
	edge += max(0.0, base.a - texture(TEXTURE, UV + vec2(px.x, -px.y)).a);
	edge += max(0.0, base.a - texture(TEXTURE, UV + vec2(-px.x, px.y)).a);
	edge = clamp(edge, 0.0, 1.0);
	COLOR = vec4(rim_color.rgb, edge * rim_strength);
}
