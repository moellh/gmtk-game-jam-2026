extends Node2D

const ROUND_TIME := 10.0
const TILE_SIZE := 16.0

const HEART_TEXTURE := preload("res://assets/monochrome_tilemap_transparent.png")
const HEART_ATLAS_COORDS := [
	Vector2i(0, 2),
	Vector2i(1, 2),
	Vector2i(2, 2),
]
const HEART_ATLAS_PITCH := 17.0
const HEART_COLOR := Color(0.95, 0.0, 0.207, 1.0)
const HEART_ANIMATION := &"default"

const BASE_VIEWPORT_SIZE := Vector2(384.0, 216.0)
const LEVEL_VIEW_RECT := Rect2(80.0, 16.0, 256.0, 128.0)

const LEVEL_SELECT := "res://src/level_select.tscn"

@export var next_level: PackedScene
@export_range(1, 10, 1) var max_figures := 2
@export var figure_spawn_offsets: Array[Vector2] = []

@onready var player: CharacterBody2D = $Player
@onready var world_camera: Camera2D = $WorldCamera
@onready var timer_display: Label = %TimerDisplay
@onready var life_hearts: Node2D = %LifeHearts
@onready var level_complete: CanvasLayer = $LevelComplete
@onready var outside_fill: OutsideFill = $OutsideFill
@onready var touch_controls: TouchControls = $TouchControls

var timer := ROUND_TIME
var finished_figures := 0
var completed := false
var life_heart_icons: Array[AnimatedSprite2D] = []

func _ready() -> void:
	get_viewport().size_changed.connect(update_world_camera)
	update_world_camera()
	player.reset(live_attempt_spawn_offset(0))
	build_life_hearts()
	update_life_hearts()
	update_hud()

func update_world_camera() -> void:
	var window_size := Vector2(get_window().size)
	if window_size.x <= 0.0 or window_size.y <= 0.0: return

	var width_scale := window_size.x / BASE_VIEWPORT_SIZE.x
	var height_scale := window_size.y / BASE_VIEWPORT_SIZE.y
	var fit_scale := minf(width_scale, height_scale)
	var visible_size := window_size / fit_scale
	touch_controls.layout_for_size(visible_size)
	var gameplay_size := Vector2(
		visible_size.x,
		maxf(
			visible_size.y - touch_controls.reserved_bottom_height,
			LEVEL_VIEW_RECT.size.y,
		),
	)
	var level_zoom := minf(
		gameplay_size.x / LEVEL_VIEW_RECT.size.x,
		gameplay_size.y / LEVEL_VIEW_RECT.size.y,
	)
	var viewport_center := visible_size * 0.5
	var gameplay_center := Vector2(
		visible_size.x * 0.5,
		gameplay_size.y * 0.5,
	)
	world_camera.position = (
		LEVEL_VIEW_RECT.get_center()
		- (gameplay_center - viewport_center) / level_zoom
	)
	world_camera.zoom = Vector2.ONE * level_zoom
	var visible_world_size := visible_size / level_zoom
	outside_fill.set_visible_world_rect(
		Rect2(
			world_camera.position - visible_world_size * 0.5,
			visible_world_size,
		),
	)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file(LEVEL_SELECT)
		return

	if Input.is_action_just_pressed("clear"):
		clear()
		update_hud()
		return

	timer -= delta
	if timer <= 0.0 or Input.is_action_just_pressed("restart"): next_round()

	update_hud()

func update_hud() -> void:
	var displayed_tenths := roundi(maxf(timer, 0.0) * 10.0)
	var displayed_seconds := floori(displayed_tenths * 0.1)
	timer_display.text = "%d.%d" % [displayed_seconds, displayed_tenths % 10]

func clear() -> void:
	timer = ROUND_TIME
	finished_figures = 0
	get_tree().call_group("ghosts", "queue_free")
	player.reset(live_attempt_spawn_offset(0))
	update_life_hearts()

func next_round() -> void:
	finished_figures += 1
	if finished_figures >= max_figures:
		clear()
		return

	timer = ROUND_TIME

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset(live_attempt_spawn_offset(finished_figures))
	update_life_hearts()

func remaining_figures() -> int:
	return maxi(max_figures - finished_figures, 0)

func live_attempt_spawn_offset(completed_figures: int) -> Vector2:
	if completed_figures < figure_spawn_offsets.size():
		return figure_spawn_offsets[completed_figures]
	return Vector2.ZERO

func build_life_hearts() -> void:
	var frames := SpriteFrames.new()
	frames.set_animation_speed(HEART_ANIMATION, 6.0)
	frames.set_animation_loop(HEART_ANIMATION, true)

	for atlas_coordinates in HEART_ATLAS_COORDS:
		var texture := AtlasTexture.new()
		texture.atlas = HEART_TEXTURE
		texture.region = Rect2(
			Vector2(atlas_coordinates) * HEART_ATLAS_PITCH,
			Vector2.ONE * TILE_SIZE,
		)
		frames.add_frame(HEART_ANIMATION, texture)

	for index in max_figures:
		var slot := Node2D.new()
		slot.position = Vector2(index * TILE_SIZE, 0.0)
		life_hearts.add_child(slot)

		var background := Polygon2D.new()
		background.polygon = PackedVector2Array([
			Vector2(-9.0, -9.0),
			Vector2(9.0, -9.0),
			Vector2(9.0, 9.0),
			Vector2(-9.0, 9.0),
		])
		background.color = Color.BLACK
		slot.add_child(background)

		var heart := AnimatedSprite2D.new()
		heart.sprite_frames = frames
		heart.modulate = HEART_COLOR
		heart.z_index = 1
		heart.play(HEART_ANIMATION)
		slot.add_child(heart)
		life_heart_icons.append(heart)

func update_life_hearts() -> void:
	var visible_hearts := remaining_figures()
	for index in life_heart_icons.size():
		life_heart_icons[index].visible = index < visible_hearts

func complete_level() -> void:
	if completed:
		return
	completed = true
	level_complete.open(next_level)
