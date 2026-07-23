extends StaticBody2D

signal crushed

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual

func set_open(open: bool) -> void:
	if not open and player_inside(): crushed.emit()
	collision.set_deferred("disabled", open)
	visual.visible = not open

func player_inside() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision.shape
	query.transform = collision.global_transform
	query.exclude = [get_rid()] # skip our own static body

	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		if hit.collider is CharacterBody2D: return true
	return false
