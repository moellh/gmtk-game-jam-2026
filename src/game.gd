extends Node2D

const ROUND_TIME := 10.0

@onready var player: CharacterBody2D = $Player

var timer := ROUND_TIME

func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0: next_round()

func next_round() -> void:
	timer = ROUND_TIME

	add_child(player.spawn_ghost())
	get_tree().call_group("ghosts", "restart")

	player.reset()
