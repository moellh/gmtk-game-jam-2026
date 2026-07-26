@tool
extends Area2D

@export_multiline var text := "Controls":
	set(value):
		text = value
		if is_node_ready(): prompt.text = value

@onready var prompt: Label = $TextViewport/Prompt
@onready var _sprite: Sprite2D = $PromptSprite

func _ready() -> void:
	prompt.text = text
	_sprite.texture = $TextViewport.get_texture()
	if not Engine.is_editor_hint():
		_sprite.hide()
		$TextViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if $TextViewport.render_target_update_mode == SubViewport.UPDATE_DISABLED:
			$TextViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		_sprite.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		_sprite.hide()
