shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

float rand(vec2 c) {
	return fract(sin(dot(c, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	float band = floor(uv.y * 20.0);
	float tick = floor(TIME * 20.0);
	float shift = (rand(vec2(band, tick)) - 0.5) * 0.08 * strength;
	shift *= step(0.5, rand(vec2(tick, band)));
	uv.x += shift;

	float sep = 0.01 * strength;
	float r = texture(screen_tex, uv + vec2(sep, 0.0)).r;
	float g = texture(screen_tex, uv).g;
	float b = texture(screen_tex, uv - vec2(sep, 0.0)).b;
	COLOR = vec4(r, g, b, 1.0);
}
