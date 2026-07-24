@tool
extends StaticBody2D

signal crushed

@export var color := Color(0.5, 0.3, 0.15, 1.0):
	set(value): color = value; if is_node_ready(): set_color(value)
@export var inverted := false

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var bottom: Sprite2D = $Visual/Bottom
@onready var top: Sprite2D = $Visual/Top

func _ready() -> void:
	set_color(color)
	if not Engine.is_editor_hint(): _apply_open(inverted)

func set_open(pressed: bool) -> void:
	var open := pressed != inverted
	if not open and player_inside(): crushed.emit()
	_apply_open(open)

func _apply_open(open: bool) -> void:
	collision.set_deferred("disabled", open)
	visual.visible = not open

func player_inside() -> bool:
	var world := get_world_2d()
	if world == null: return false # no physics world (e.g. during scene teardown)

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision.shape
	query.transform = collision.global_transform
	query.exclude = [get_rid()] # skip our own static body

	for hit in world.direct_space_state.intersect_shape(query):
		var collider := hit.collider as Node
		if collider != null and collider.is_in_group(&"player"):
			return true
	return false

func set_color(c: Color) -> void:
	bottom.modulate = c
	top.modulate = c
