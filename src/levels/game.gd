extends Node2D

const ROUND_TIME := 10.0
const LEVEL_TRANSITION_TIME := 1.0
const DEATH_SCALE := Vector2.ONE * 3.0

@export var next_level: PackedScene

@onready var player: CharacterBody2D = $Player
@onready var timer_label: Label = %TimerDisplay
@onready var life_hearts: LifeHearts = %LifeHearts
@onready var level_complete: CanvasLayer = $LevelComplete

var timer := ROUND_TIME

func _ready() -> void:
	player.reset()
	update_hud()
	play_level_intro()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file("res://src/levels/level_select.tscn")
		return

	if Input.is_action_just_pressed("clear"):
		clear()
		update_hud()
		return

	timer -= delta
	if Input.is_action_just_pressed("restart"):
		next_round()
	elif timer <= 0.0:
		if life_hearts.remaining() == 1:
			play_death()
		else:
			next_round()

	update_hud()

func update_hud() -> void:
	var displayed_tenths := roundi(maxf(timer, 0.0) * 10.0)
	var displayed_seconds := mini(floori(displayed_tenths * 0.1), 99)
	timer_label.text = "%d.%d" % [displayed_seconds, displayed_tenths % 10]

func play_level_intro() -> void:
	get_tree().paused = true

	var opaque_modulate := player.modulate
	opaque_modulate.a = 1.0
	player.modulate = _faded(opaque_modulate)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(player, "modulate", opaque_modulate, LEVEL_TRANSITION_TIME)
	await tween.finished

	get_tree().paused = false

func play_death() -> void:
	if get_tree().paused: return

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

func clear() -> void:
	timer = ROUND_TIME
	life_hearts.reset()
	get_tree().call_group("ghosts", "queue_free")
	player.reset()

func next_round() -> void:
	life_hearts.use_figure()
	if life_hearts.remaining() == 0:
		clear()
		return

	timer = ROUND_TIME

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset()

func complete_level(goal_position: Vector2) -> void:
	if get_tree().paused:
		return

	var tween := _freeze_player()
	tween.tween_property(player, "global_position", goal_position, LEVEL_TRANSITION_TIME)
	tween.tween_property(player, "modulate", _faded(player.modulate), LEVEL_TRANSITION_TIME)
	await tween.finished

	level_complete.open(next_level)

func _freeze_player() -> Tween:
	player.velocity = Vector2.ZERO
	get_tree().paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	return tween

func _faded(base: Color) -> Color:
	base.a = 0.0
	return base
