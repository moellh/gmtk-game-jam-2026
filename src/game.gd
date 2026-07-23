extends Node2D

const ROUND_TIME := 10.0

@onready var player: CharacterBody2D = $Player

var timer := ROUND_TIME

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("clear"): clear()

	timer -= delta
	if timer <= 0.0 or Input.is_action_just_pressed("restart"): next_round()

func clear() -> void:
	timer = ROUND_TIME
	get_tree().call_group("ghosts", "queue_free")
	player.reset()

func next_round() -> void:
	timer = ROUND_TIME

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset()
