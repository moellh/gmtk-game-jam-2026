extends StaticBody2D

signal crushed

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual

func set_open(open: bool) -> void:
	if not open and player_inside(): crushed.emit()
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
