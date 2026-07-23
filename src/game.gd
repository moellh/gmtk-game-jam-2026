extends Node2D

const ROUND_TIME := 10.0

const BASE_VIEWPORT_SIZE := Vector2(384.0, 216.0)
const LEVEL_VIEW_RECT := Rect2(80.0, 16.0, 256.0, 128.0)

const LEVEL_SELECT := "res://src/level_select.tscn"

@export var next_level: PackedScene

@onready var player: CharacterBody2D = $Player
@onready var world_camera: Camera2D = $WorldCamera
@onready var timer_display: Label = %TimerDisplay
@onready var level_complete: CanvasLayer = $LevelComplete
@onready var outside_fill: OutsideFill = $OutsideFill
@onready var touch_controls: TouchControls = $TouchControls

var timer := ROUND_TIME
var completed := false

func _ready() -> void:
	get_viewport().size_changed.connect(update_world_camera)
	update_world_camera()

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

	if Input.is_action_just_pressed("clear"): clear()

	timer -= delta
	if timer <= 0.0 or Input.is_action_just_pressed("restart"): next_round()

	update_hud()

func update_hud() -> void:
	var displayed_tenths := roundi(maxf(timer, 0.0) * 10.0)
	var displayed_seconds := floori(displayed_tenths * 0.1)
	timer_display.text = "%d.%d" % [displayed_seconds, displayed_tenths % 10]

func clear() -> void:
	timer = ROUND_TIME
	get_tree().call_group("ghosts", "queue_free")
	player.reset()

func next_round() -> void:
	timer = ROUND_TIME

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset()


func complete_level() -> void:
	if completed:
		return
	completed = true
	level_complete.open(next_level)
