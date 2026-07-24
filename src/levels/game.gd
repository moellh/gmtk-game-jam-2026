extends Node2D

@export var next_level: PackedScene

@onready var player: Player = $Player
@onready var round_timer: RoundTimer = %RoundTimer
@onready var life_hearts: LifeHearts = %LifeHearts
@onready var level_complete: CanvasLayer = $LevelComplete

func _ready() -> void:
	player.reset()
	play_level_intro()

func _process(delta: float) -> void:
	round_timer.advance(delta)

	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file("res://src/levels/level_select.tscn")
	elif Input.is_action_just_pressed("clear"):
		clear()
	elif Input.is_action_just_pressed("restart") or round_timer.is_expired():
		if life_hearts.remaining() == 1: play_death()
		else: next_round()

func play_level_intro() -> void:
	get_tree().paused = true
	await player.play_spawn()
	get_tree().paused = false

func play_death() -> void:
	if get_tree().paused: return
	get_tree().paused = true
	await player.play_death()
	get_tree().paused = false
	clear()

func clear() -> void:
	round_timer.reset()
	life_hearts.reset()
	get_tree().call_group("ghosts", "queue_free")
	player.reset()

func next_round() -> void:
	life_hearts.use_figure()
	round_timer.reset()

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset()

func complete_level(goal_position: Vector2) -> void:
	if get_tree().paused: return
	get_tree().paused = true
	await player.play_goal(goal_position)
	level_complete.open(next_level)
