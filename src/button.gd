extends Area2D

signal changed(is_pressed: bool)

const COLOR_UP := Color(0.95, 0.0, 0.207, 1.0)
const COLOR_DOWN := Color(0.0, 0.704, 0.152, 1.0)
const MAX_STEP_HEIGHT := 5.0
const STEP_INSET := 1.0

var pressed := false
var overlaps := 0

@export var texture_up: AtlasTexture
@export var texture_down: AtlasTexture

@onready var visual: Sprite2D = $Sprite2D
@onready var press_collision: CollisionShape2D = $CollisionShape2D
@onready var platform_collision: CollisionShape2D = $Platform/CollisionShape2D

func _ready() -> void:
	visual.texture = texture_up
	visual.position = Vector2.ZERO
	visual.modulate = COLOR_UP

func _on_entered(_node: Node2D) -> void:
	overlaps += 1
	set_pressed(true)

func _on_exited(_node: Node2D) -> void:
	overlaps = maxi(overlaps - 1, 0)
	set_pressed(overlaps > 0)

func _on_step_body_entered(body: Node2D) -> void:
	# Defer movement until the physics query has finished.
	_step_body_onto_platform.call_deferred(body)

func _step_body_onto_platform(body: Node2D) -> void:
	if not is_instance_valid(body):
		return

	var character := body as CharacterBody2D
	if character == null or not character.is_on_floor() or character.velocity.y < 0.0:
		return

	var collision_shape := character.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return

	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle == null:
		return

	var platform_rect := platform_collision.shape.get_rect()
	var platform_top_y := platform_collision.to_global(Vector2(0.0, platform_rect.position.y)).y
	var body_bottom_y := collision_shape.to_global(Vector2(0.0, rectangle.size.y * 0.5)).y
	var step_height := body_bottom_y - platform_top_y
	if step_height <= 0.0 or step_height > MAX_STEP_HEIGHT:
		return

	character.global_position.y -= step_height
	var local_character_x := to_local(character.global_position).x
	var maximum_step_x := (platform_rect.size.x + rectangle.size.x) * 0.5 - STEP_INSET
	# Pull grounded bodies one pixel onto the platform past its side collision.
	if absf(local_character_x) > maximum_step_x:
		character.global_position.x = to_global(
			Vector2(signf(local_character_x) * maximum_step_x, 0.0)
		).x
	character.velocity.y = 0.0

func set_pressed(value: bool) -> void:
	if pressed == value: return

	pressed = value
	visual.texture = texture_down if value else texture_up
	visual.position = press_collision.position if value else Vector2.ZERO
	visual.modulate = COLOR_DOWN if value else COLOR_UP
	changed.emit(value)
