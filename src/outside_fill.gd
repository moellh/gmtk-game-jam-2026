class_name OutsideFill
extends Node2D

const TILE_SIZE := 16.0
const ATLAS_STRIDE := 17.0
const LEVEL_RECT := Rect2(80.0, 16.0, 256.0, 128.0)
const ATLAS := preload("res://assets/monochrome_tilemap_transparent.png")

const TILE_CHOICES: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(0, 2),
	Vector2i(1, 2),
	Vector2i(2, 2),
]

var visible_world_rect := LEVEL_RECT


func set_visible_world_rect(rect: Rect2) -> void:
	visible_world_rect = rect
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter(
		"visible_rect",
		Vector4(rect.position.x, rect.position.y, rect.end.x, rect.end.y),
	)
	queue_redraw()


func _draw() -> void:
	var first := Vector2i((visible_world_rect.position / TILE_SIZE).floor())
	var last := Vector2i((visible_world_rect.end / TILE_SIZE).ceil())

	for y in range(first.y, last.y):
		for x in range(first.x, last.x):
			var cell := Vector2i(x, y)
			var destination := Rect2(
				Vector2(cell) * TILE_SIZE,
				Vector2.ONE * TILE_SIZE,
			)

			if destination.intersects(LEVEL_RECT):
				continue

			var value := absi(
				cell.x * 73856093
				^ cell.y * 19349663
				^ 83492791
			)
			if posmod(value, 4) == 0:
				continue

			var atlas_cell := TILE_CHOICES[
				posmod(value >> 3, TILE_CHOICES.size())
			]
			var source := Rect2(
				Vector2(atlas_cell) * ATLAS_STRIDE,
				Vector2.ONE * TILE_SIZE,
			)
			draw_texture_rect_region(
				ATLAS,
				destination,
				source,
				Color(1.0, 1.0, 1.0, 0.45),
			)
