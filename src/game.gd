extends Node2D

const ROUND_TIME := 10.0

@onready var player: CharacterBody2D = $Player
@onready var ghost_timer: Label = %GhostTimer
@onready var action_buttons: Dictionary[StringName, Button] = {
	&"move_left": %MoveLeftButton,
	&"move_right": %MoveRightButton,
	&"jump": %JumpButton,
	&"restart": %RestartButton,
	&"clear": %ClearButton,
}

var timer := ROUND_TIME

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("clear"): clear()

	timer -= delta
	if timer <= 0.0 or Input.is_action_just_pressed("restart"): next_round()

	update_hud()

func update_hud() -> void:
	ghost_timer.text = "Next ghost in %.1f s" % maxf(timer, 0.0)
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
