extends Node2D

@export var next_level: PackedScene

@onready var player: Player = $Player
@onready var outside_fill: OutsideFill = $OutsideFill
@onready var round_timer: RoundTimer = %RoundTimer
@onready var life_hearts: LifeHearts = %LifeHearts
@onready var level_complete: CanvasLayer = $LevelComplete

func _ready() -> void:
	outside_fill.player_outside.connect(play_death)
	player.reset()
	play_level_intro()

func _process(delta: float) -> void:
	round_timer.advance(delta)

	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file("res://src/levels/level_select.tscn")
	elif Input.is_action_just_pressed("clear"):
		Glitch.play()
		clear()
	elif Input.is_action_just_pressed("freeze"):
		if life_hearts.remaining() == 1: play_death()
		else: Glitch.play(); next_round(true)
	elif Input.is_action_just_pressed("restart") or round_timer.is_expired():
		if life_hearts.remaining() == 1: play_death()
		else: Glitch.play(); next_round()

func play_level_intro() -> void:
	get_tree().paused = true
	await player.play_spawn()
	get_tree().paused = false

func play_death() -> void:
	if get_tree().paused: return
	get_tree().paused = true
	await player.play_death()
	get_tree().paused = false
	if life_hearts.remaining() > 1: next_round()
	else: clear()

func clear() -> void:
	round_timer.reset()
	life_hearts.reset()
	get_tree().call_group("ghosts", "queue_free")
	player.reset()

func next_round(solid: bool = false) -> void:
	life_hearts.use_figure()
	round_timer.reset()

	add_child(player.spawn_ghost(solid))
	get_tree().call_group("ghosts", "restart")

	player.reset()

func complete_level(goal_position: Vector2) -> void:
	if get_tree().paused: return
	get_tree().paused = true
	await player.play_goal(goal_position)
	level_complete.open(next_level)
