extends Node2D

const ROUND_TIME := 10.0
const BASE_VIEWPORT_SIZE := Vector2(384.0, 216.0)
const LEVEL_VIEW_SIZE := Vector2(384.0, 132.0)
const HUD_HEIGHT := BASE_VIEWPORT_SIZE.y - LEVEL_VIEW_SIZE.y

@onready var player: CharacterBody2D = $Player
@onready var world_camera: Camera2D = $WorldCamera
@onready var ghost_timer: Label = %GhostTimer
@onready var action_buttons: Dictionary[StringName, Button] = {
	&"move_left": %MoveLeftButton,
	&"move_right": %MoveRightButton,
	&"jump": %JumpButton,
	&"restart": %RestartButton,
	&"clear": %ClearButton,
}

var timer := ROUND_TIME

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
	var gameplay_size := Vector2(visible_size.x, visible_size.y - HUD_HEIGHT)
	var level_zoom := minf(
		gameplay_size.x / LEVEL_VIEW_SIZE.x,
		gameplay_size.y / LEVEL_VIEW_SIZE.y,
	)
	var gameplay_center := Vector2(visible_size.x * 0.5, gameplay_size.y * 0.5)
	var viewport_center := visible_size * 0.5

	world_camera.position = (
		LEVEL_VIEW_SIZE * 0.5
		- (gameplay_center - viewport_center) / level_zoom
	)
	world_camera.zoom = Vector2.ONE * level_zoom

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("clear"): clear()

	timer -= delta
	if timer <= 0.0 or Input.is_action_just_pressed("restart"): next_round()

	update_hud()

func update_hud() -> void:
	ghost_timer.text = "%.2f s" % maxf(timer, 0.0)
	for action: StringName in action_buttons:
		action_buttons[action].button_pressed = Input.is_action_pressed(action)

func clear() -> void:
	timer = ROUND_TIME
	get_tree().call_group("ghosts", "queue_free")
	player.reset()

func next_round() -> void:
	timer = ROUND_TIME

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset()
