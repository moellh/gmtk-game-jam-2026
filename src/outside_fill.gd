@tool
class_name OutsideFill
extends Node2D

signal player_outside

const HASH_X := 73856093
const HASH_Y := 19349663
const HASH_SEED := 83492791

@export var atlas: Texture2D:
	set(value):
		atlas = value
		queue_redraw()
@export var atlas_cells: Array[Vector2i] = [
	Vector2i(16, 10),
	Vector2i(19, 9),
	Vector2i(19, 10),
	Vector2i(19, 11),
	Vector2i(19, 12),
]:
	set(value):
		atlas_cells = value
		queue_redraw()
@export_range(0.0, 1.0) var opacity := 0.45:
	set(value):
		opacity = value
		queue_redraw()
@export_range(1, 16) var density := 4:
	set(value):
		density = value
		queue_redraw()
@export var tile_size := 16.0:
	set(value):
		tile_size = value
		queue_redraw()
@export var atlas_stride := 17.0:
	set(value):
		atlas_stride = value
		queue_redraw()
@export var level_rect := Rect2(80.0, 16.0, 256.0, 128.0):
	set(value):
		level_rect = value
		queue_redraw()

var visible_world_rect := Rect2()


func _ready() -> void:
	if Engine.is_editor_hint(): return
	visible_world_rect = level_rect
	get_viewport().size_changed.connect(_update_visible_rect)
	_update_visible_rect.call_deferred()

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as CollisionObject2D
	if player == null: return

	var collision_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null: return

	var shape_transform := global_transform.affine_inverse() * collision_shape.global_transform
	var player_rect := shape_transform * collision_shape.shape.get_rect()
	if not level_rect.encloses(player_rect):
		player_outside.emit()

func _update_visible_rect() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null: return
	var world_size := get_viewport_rect().size / camera.zoom
	visible_world_rect = Rect2(camera.get_screen_center_position() - world_size * 0.5, world_size)
	queue_redraw()

func _draw() -> void:
	# In the editor, just outline the play area so the camera/tiles can be aligned to it.
	if Engine.is_editor_hint():
		draw_rect(level_rect, Color(0.3, 0.9, 1.0, 0.8), false)
		return

	if atlas == null or atlas_cells.is_empty(): return

	var first := Vector2i((visible_world_rect.position / tile_size).floor())
	var last := Vector2i((visible_world_rect.end / tile_size).ceil())

	for y in range(first.y, last.y):
		for x in range(first.x, last.x):
			var cell := Vector2i(x, y)
			var destination := Rect2(Vector2(cell) * tile_size, Vector2.ONE * tile_size)
			if destination.intersects(level_rect): continue

			var value := absi(cell.x * HASH_X ^ cell.y * HASH_Y ^ HASH_SEED)
			if posmod(value, maxi(density, 1)) != 0: continue

			var fade := _edge_fade(destination.get_center())
			if fade <= 0.0: continue

			var atlas_cell := atlas_cells[posmod(value >> 3, atlas_cells.size())]
			var source := Rect2(Vector2(atlas_cell) * atlas_stride, Vector2.ONE * tile_size)
			draw_texture_rect_region(atlas, destination, source, Color(1.0, 1.0, 1.0, opacity * fade))

func _edge_fade(point: Vector2) -> float:
	var fade := 1.0
	if point.x < level_rect.position.x:
		fade = minf(fade, (point.x - visible_world_rect.position.x) / maxf(level_rect.position.x - visible_world_rect.position.x, 0.001))
	elif point.x > level_rect.end.x:
		fade = minf(fade, (visible_world_rect.end.x - point.x) / maxf(visible_world_rect.end.x - level_rect.end.x, 0.001))
	if point.y < level_rect.position.y:
		fade = minf(fade, (point.y - visible_world_rect.position.y) / maxf(level_rect.position.y - visible_world_rect.position.y, 0.001))
	elif point.y > level_rect.end.y:
		fade = minf(fade, (visible_world_rect.end.y - point.y) / maxf(visible_world_rect.end.y - level_rect.end.y, 0.001))
	return smoothstep(0.0, 1.0, clampf(fade, 0.0, 1.0))
