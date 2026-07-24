@tool
class_name LifeHearts
extends Node2D

const LIFE_HEART := preload("res://src/decorations/life_heart.tscn")
const SPACING := 16.0

@export_range(1, 10, 1) var lives := 2:
	set(value):
		lives = value
		_rebuild()

var _used := 0

func _ready() -> void:
	_rebuild()

func remaining() -> int:
	return maxi(lives - _used, 0)

func use_figure() -> void:
	_used += 1
	_refresh()

func reset() -> void:
	_used = 0
	_refresh()

func _refresh() -> void:
	var beating_index := remaining() - 1
	for index in get_child_count():
		var heart := get_child(index) as AnimatedSprite2D
		heart.visible = index <= beating_index
		if index == beating_index:
			heart.play()
		else:
			heart.stop()

func _rebuild() -> void:
	if not is_inside_tree(): return

	for child in get_children():
		remove_child(child)
		child.queue_free()

	for index in lives:
		var heart := LIFE_HEART.instantiate() as Node2D
		heart.position = Vector2(index * SPACING, 0.0)
		add_child(heart)

	_refresh()
