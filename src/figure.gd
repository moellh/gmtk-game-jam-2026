class_name Figure
extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -300.0
const ACCEL := 2000.0
const FRICTION := 2500.0
const LEDGE_TIME := 0.1
const JUMP_BUFFER := 0.1

const MOVE_AXIS := &"move_axis"
const JUMP_PRESSED := &"jump_pressed"
const JUMP_RELEASED := &"jump_released"

var ledge_timer := 0.0
var buffer_timer := 0.0
var first_step_after_reset := true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func apply_action(action: Dictionary, delta: float) -> void:
	if not is_on_floor(): velocity += get_gravity() * delta

	ledge_timer = LEDGE_TIME if is_on_floor() else ledge_timer - delta
	buffer_timer = JUMP_BUFFER if action[JUMP_PRESSED] else buffer_timer - delta
	if buffer_timer > 0.0 and ledge_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		buffer_timer = 0.0
		ledge_timer = 0.0

	if action[JUMP_RELEASED] and velocity.y < 0.0:
		velocity.y *= 0.4

	var move_axis: float = action[MOVE_AXIS]
	if move_axis:
		velocity.x = move_toward(velocity.x, move_axis * SPEED, 1.5 * ACCEL * delta)
		sprite.flip_h = move_axis < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	move_and_slide()
	update_animation(move_axis)

func reset_figure(spawn_position: Vector2) -> void:
	velocity = Vector2.ZERO
	global_position = spawn_position

func update_animation(move_axis: float) -> void:
	if not is_on_floor():
		sprite.play(&"jump")
	elif move_axis != 0.0:
		sprite.play(&"run")
	else:
		sprite.play(&"idle")
