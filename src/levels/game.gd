extends Node2D

const ROUND_TIME := 10.0
const TILE_SIZE := 16.0
const LEVEL_TRANSITION_TIME := 1.0
const DEATH_SCALE := Vector2.ONE * 3.0

const LIFE_HEART := preload("res://src/levels/life_heart.tscn")

const LEVEL_SELECT := "res://src/level_select.tscn"

@export var next_level: PackedScene
@export_range(1, 10, 1) var max_figures := 2

@onready var player: CharacterBody2D = $Player
@onready var timer_label: Label = %TimerDisplay
@onready var life_hearts: Node2D = %LifeHearts
@onready var level_complete: CanvasLayer = $LevelComplete

var timer := ROUND_TIME
var finished_figures := 0
var completed := false
var life_heart_icons: Array[AnimatedSprite2D] = []
var accepting_input := false
var dying := false

func _ready() -> void:
	player.reset()
	build_life_hearts()
	update_life_hearts()
	update_hud()
	play_level_intro()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file(LEVEL_SELECT)
		return

	if not accepting_input:
		return

	if Input.is_action_just_pressed("clear"):
		clear()
		update_hud()
		return

	timer -= delta
	if Input.is_action_just_pressed("restart"):
		next_round()
	elif timer <= 0.0:
		if remaining_figures() == 1:
			play_death()
		else:
			next_round()

	update_hud()

func update_hud() -> void:
	var displayed_tenths := roundi(maxf(timer, 0.0) * 10.0)
	var displayed_seconds := mini(floori(displayed_tenths * 0.1), 99)
	timer_label.text = "%d.%d" % [displayed_seconds, displayed_tenths % 10]

func play_level_intro() -> void:
	accepting_input = false
	player.set_physics_process(false)

	var opaque_modulate := player.modulate
	opaque_modulate.a = 1.0
	player.modulate = _faded(opaque_modulate)

	var tween := create_tween()
	tween.tween_property(player, "modulate", opaque_modulate, LEVEL_TRANSITION_TIME)
	await tween.finished

	accepting_input = true
	player.set_physics_process(true)

func play_death() -> void:
	if dying or completed or not accepting_input:
		return
	dying = true

	var normal_scale := player.scale
	var opaque_modulate := player.modulate
	var tween := _freeze_player()
	tween.tween_property(player, "scale", normal_scale * DEATH_SCALE, LEVEL_TRANSITION_TIME)
	tween.tween_property(player, "modulate", _faded(opaque_modulate), LEVEL_TRANSITION_TIME)
	await tween.finished

	player.scale = normal_scale
	player.modulate = opaque_modulate
	get_tree().paused = false
	next_round()
	player.set_physics_process(true)
	accepting_input = true
	dying = false

func clear() -> void:
	timer = ROUND_TIME
	finished_figures = 0
	get_tree().call_group("ghosts", "queue_free")
	player.reset()
	update_life_hearts()

func next_round() -> void:
	finished_figures += 1
	if finished_figures >= max_figures:
		clear()
		return

	timer = ROUND_TIME

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset()
	update_life_hearts()

func remaining_figures() -> int:
	return maxi(max_figures - finished_figures, 0)

func build_life_hearts() -> void:
	for index in max_figures:
		var slot := LIFE_HEART.instantiate()
		slot.position = Vector2(index * TILE_SIZE, 0.0)
		life_hearts.add_child(slot)
		life_heart_icons.append(slot.get_node(^"Heart") as AnimatedSprite2D)

func update_life_hearts() -> void:
	var visible_hearts := remaining_figures()
	for index in life_heart_icons.size():
		life_heart_icons[index].visible = index < visible_hearts

func complete_level(goal_position: Vector2) -> void:
	if completed or not accepting_input:
		return
	completed = true

	var tween := _freeze_player()
	tween.tween_property(player, "global_position", goal_position, LEVEL_TRANSITION_TIME)
	tween.tween_property(player, "modulate", _faded(player.modulate), LEVEL_TRANSITION_TIME)
	await tween.finished

	level_complete.open(next_level)

func _freeze_player() -> Tween:
	accepting_input = false
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	get_tree().paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	return tween

func _faded(base: Color) -> Color:
	base.a = 0.0
	return base
