extends Area2D

signal changed(is_pressed: bool)

const COLOR_UP := Color(0.95, 0.0, 0.207, 1.0)
const COLOR_DOWN := Color(0.0, 0.704, 0.152, 1.0)

var pressed := false
var overlaps := 0

@onready var visual: Polygon2D = $Polygon2D

func _ready() -> void:
	visual.color = COLOR_UP

func _on_entered(_node: Node2D) -> void:
	overlaps += 1
	set_pressed(overlaps > 0)

func _on_exited(_node: Node2D) -> void:
	overlaps = maxi(overlaps - 1, 0)
	set_pressed(overlaps > 0)

func set_pressed(value: bool) -> void:
	if pressed == value: return

	pressed = value
	visual.color = COLOR_DOWN if value else COLOR_UP
	changed.emit(value)
