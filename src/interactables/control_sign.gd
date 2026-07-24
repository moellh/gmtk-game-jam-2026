class_name ControlSign
extends Area2D

const SIGN_GROUP := &"control_signs"
const PROMPT_VERTICAL_GAP := 16.0

@export_multiline var instructions := ""
@export var prompt_horizontal_bounds := Vector2(80.0, 336.0)

@onready var prompt: Label = $Prompt
var player: CharacterBody2D


func _ready() -> void:
	add_to_group(SIGN_GROUP)
	prompt.text = instructions
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if is_instance_valid(player):
		_refresh_prompt_owner(player)
	elif player != null:
		player = null
		prompt.hide()


func _update_prompt_position() -> void:
	var centered_x := player.global_position.x - prompt.size.x * 0.5
	prompt.global_position = Vector2(
		roundf(
			clampf(
				centered_x,
				prompt_horizontal_bounds.x,
				prompt_horizontal_bounds.y - prompt.size.x,
			),
		),
		roundf(
			global_position.y
				- prompt.size.y
				- PROMPT_VERTICAL_GAP
		),
	)


func _refresh_prompt_owner(target: CharacterBody2D) -> void:
	if not is_instance_valid(target):
		return

	var candidates: Array[ControlSign] = []
	var winner: ControlSign
	var closest_distance := INF
	var closest_path := ""

	for node in get_tree().get_nodes_in_group(SIGN_GROUP):
		var candidate := node as ControlSign
		if candidate == null or candidate.player != target:
			continue

		candidates.append(candidate)
		var distance := candidate.global_position.distance_squared_to(
			target.global_position,
		)
		var candidate_path := str(candidate.get_path())
		if (
			winner == null
			or distance < closest_distance
			or (
				is_equal_approx(distance, closest_distance)
				and candidate_path < closest_path
			)
		):
			winner = candidate
			closest_distance = distance
			closest_path = candidate_path

	for candidate in candidates:
		if candidate == winner:
			candidate._update_prompt_position()
			candidate.prompt.show()
		else:
			candidate.prompt.hide()


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	player = body as CharacterBody2D
	if player == null:
		return
	_refresh_prompt_owner(player)


func _on_body_exited(body: Node2D) -> void:
	if body != player:
		return
	var exiting_player := player
	player = null
	prompt.hide()
	_refresh_prompt_owner(exiting_player)
