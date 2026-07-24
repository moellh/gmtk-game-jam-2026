@tool
extends Area2D

@export_multiline var text := "Controls":
	set(value):
		text = value
		if is_node_ready(): prompt.text = value
@export var prompt_offset := Vector2.ZERO:
	set(value):
		prompt_offset = value
		if is_node_ready(): prompt.position = _base_position + value

@onready var prompt: Label = $Prompt
var _base_position: Vector2

func _ready() -> void:
	_base_position = prompt.position - prompt_offset
	prompt.text = text
	if not Engine.is_editor_hint(): prompt.hide() # Display text in level editor

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player": prompt.hide()
