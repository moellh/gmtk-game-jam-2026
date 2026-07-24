@tool
class_name LifeHearts
extends Node2D

const LIFE_HEART := preload("res://src/decorations/life_heart.tscn")
const SPACING := 16.0

@export_range(1, 10, 1) var lives := 2:
	set(value):
		lives = value
		_rebuild()

func _ready() -> void:
	_rebuild()

func set_remaining(count: int) -> void:
	for index in get_child_count(): (get_child(index) as AnimatedSprite2D).visible = index < count

func _rebuild() -> void:
	if not is_inside_tree(): return

	for child in get_children(): child.queue_free()

	for index in lives:
		var heart := LIFE_HEART.instantiate() as Node2D
		heart.position = Vector2(index * SPACING, 0.0)
		add_child(heart)
