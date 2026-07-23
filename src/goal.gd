extends Area2D

signal reached(goal_position: Vector2)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		reached.emit(global_position)
