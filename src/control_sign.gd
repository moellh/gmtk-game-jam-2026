extends Area2D

@export_multiline var instructions := ""

@onready var prompt: Label = $Prompt
var player: CharacterBody2D


func _ready() -> void:
	prompt.text = instructions
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if is_instance_valid(player):
		prompt.global_position = player.global_position + Vector2(-90.0, -42.0)


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
