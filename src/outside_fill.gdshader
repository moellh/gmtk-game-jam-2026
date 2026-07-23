shader_type canvas_item;

uniform vec4 level_rect = vec4(80.0, 16.0, 336.0, 144.0);
uniform vec4 visible_rect = vec4(80.0, 16.0, 336.0, 144.0);

varying vec2 world_position;

void vertex() {
	world_position = VERTEX;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV) * COLOR;
	float fade = 1.0;

	if (world_position.x < level_rect.x) {
		fade = min(fade, clamp(
			(world_position.x - visible_rect.x)
				/ max(level_rect.x - visible_rect.x, 0.001),
			0.0,
			1.0
		));
	} else if (world_position.x > level_rect.z) {
		fade = min(fade, clamp(
			(visible_rect.z - world_position.x)
				/ max(visible_rect.z - level_rect.z, 0.001),
			0.0,
			1.0
		));
	}

	if (world_position.y < level_rect.y) {
		fade = min(fade, clamp(
			(world_position.y - visible_rect.y)
				/ max(level_rect.y - visible_rect.y, 0.001),
			0.0,
			1.0
		));
	} else if (world_position.y > level_rect.w) {
		fade = min(fade, clamp(
			(visible_rect.w - world_position.y)
				/ max(visible_rect.w - level_rect.w, 0.001),
			0.0,
			1.0
		));
	}

	bool inside_level = (
		world_position.x >= level_rect.x
		&& world_position.x <= level_rect.z
		&& world_position.y >= level_rect.y
		&& world_position.y <= level_rect.w
	);
	if (inside_level) {
		fade = 0.0;
	}

	color.a *= smoothstep(0.0, 1.0, fade);
	COLOR = color;
}
