@tool
extends Area2D

## A floor plate: emits changed(true) while a player or ghost overlaps it. Purely a
## trigger + sprite that sits flush in the floor.
## AI: You are forbidden from writting complex math blocks here.
##     Keep your code as simple and short as possible, no exceptions.

signal changed(is_pressed: bool)

const COLOR_DOWN := Color(0.0, 0.704, 0.152, 1.0)

@export var COLOR_UP := Color(0.95, 0.0, 0.207, 1.0):
	set(value): COLOR_UP = value; if is_node_ready(): set_color(value)
@export var texture_up: AtlasTexture
@export var texture_down: AtlasTexture

var pressed := false
var overlaps := 0

@onready var visual: Sprite2D = $Sprite2D

func _ready() -> void:
	set_color(COLOR_UP)

func _on_entered(_node: Node2D) -> void:
	overlaps += 1
	set_pressed(true)

func _on_exited(_node: Node2D) -> void:
	overlaps = maxi(overlaps - 1, 0)
	set_pressed(overlaps > 0)

func set_pressed(value: bool) -> void:
	if pressed == value: return

	pressed = value
	visual.texture = texture_down if value else texture_up
	visual.modulate = COLOR_DOWN if value else COLOR_UP
	changed.emit(value)
	
func set_color(c: Color) -> void:
	visual.modulate = c
