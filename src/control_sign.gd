extends Area2D

@export_multiline var instructions := ""
@export var prompt_horizontal_bounds := Vector2(80.0, 336.0)

@onready var prompt: Label = $Prompt
var player: CharacterBody2D


func _ready() -> void:
	prompt.text = instructions
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if is_instance_valid(player):
		var centered_x := player.global_position.x - prompt.size.x * 0.5
		prompt.global_position = Vector2(
			clampf(
				centered_x,
				prompt_horizontal_bounds.x,
				prompt_horizontal_bounds.y - prompt.size.x,
			),
			player.global_position.y - 42.0,
		)


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	player = body as CharacterBody2D
	prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body != player:
		return
	player = null
	prompt.visible = false
