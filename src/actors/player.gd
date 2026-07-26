class_name Player
extends CharacterBody2D

const SPEED := 150.0
const JUMP_VELOCITY := -270.0
const ACCEL := 900.0
const FRICTION := 2500.0
const LEDGE_TIME := 0.1
const JUMP_BUFFER := 0.1
const DROP_TIME := 0.2
const PLATFORM_LAYER := 3

const RISE_GRAVITY_SCALE := 0.8
const FALL_GRAVITY_SCALE := 1.5
const MAX_FALL_SPEED := 450.0

const TRANSITION_TIME := 1.0
const DEATH_SCALE := Vector2.ONE * 3.0

const GHOST_SCENE := preload("res://src/actors/ghost.tscn")

const SAFE_ZONE_HALF_SIZE := 24.0 # 3 tiles with 16px each. This ist half the size, so the full size is 48px. This is used to check if the player is in a safe zone when spawning a ghost.

var ledge_timer := 0.0
var buffer_timer := 0.0
var drop_timer := 0.0

var spawn: Vector2
var recording: Array[Dictionary] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group(&"player")
	spawn = global_position

func _physics_process(delta: float) -> void:
	# Gravity (falls harder than it rises, so jumps feel less floaty)
	if not is_on_floor():
		var gravity_scale := FALL_GRAVITY_SCALE if velocity.y > 0.0 else RISE_GRAVITY_SCALE
		velocity += get_gravity() * gravity_scale * delta
		velocity.y = minf(velocity.y, MAX_FALL_SPEED)

	# Jump (Incl. ledge tolerance)
	ledge_timer = LEDGE_TIME if is_on_floor() else ledge_timer - delta
	buffer_timer = JUMP_BUFFER if Input.is_action_just_pressed("jump") else buffer_timer - delta
	if buffer_timer > 0.0 and ledge_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		buffer_timer = 0.0
		ledge_timer = 0.0

	# Increase Jumpheight
	if Input.is_action_just_released("jump") and velocity.y < 0.0: velocity.y *= 0.4

	# XY Movement
	var move_axis := Input.get_axis("move_left", "move_right")
	if move_axis:
		velocity.x = move_toward(velocity.x, move_axis * SPEED, 1.5 * ACCEL * delta)
		sprite.flip_h = move_axis < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	# Platform Fallthrough
	if Input.is_action_just_pressed("drop") and is_on_floor(): drop_timer = DROP_TIME
	drop_timer -= delta
	set_collision_mask_value(PLATFORM_LAYER, drop_timer <= 0.0)

	move_and_slide()
	update_animation(move_axis)

	recording.append({ pos = global_position, flip = sprite.flip_h, anim = sprite.animation })

func update_animation(move_axis: float) -> void:
	if not is_on_floor():
		sprite.play(&"jump")
	elif move_axis != 0.0:
		sprite.play(&"run")
	else:
		sprite.play(&"idle")

func spawn_ghost(solid: bool) -> Node:
	var ghost := GHOST_SCENE.instantiate()
	ghost.setup(recording)
	ghost.solid_at_rest = solid
	ghost.global_position = spawn
	ghost.add_to_group(&"ghosts")
	return ghost

func reset() -> void:
	recording = []
	velocity = Vector2.ZERO
	global_position = spawn

func is_in_safe_zone() -> bool:
	return absf(global_position.x - spawn.x) <= SAFE_ZONE_HALF_SIZE and absf(global_position.y - spawn.y) <= SAFE_ZONE_HALF_SIZE

func play_spawn() -> void:
	var opaque := modulate
	opaque.a = 1.0
	modulate = _faded(opaque)
	var tween := _transition_tween()
	tween.tween_property(self, "modulate", opaque, TRANSITION_TIME)
	await tween.finished

func play_death() -> void:
	velocity = Vector2.ZERO
	var normal_scale := scale
	var opaque := modulate
	var tween := _transition_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", normal_scale * DEATH_SCALE, TRANSITION_TIME)
	tween.tween_property(self, "modulate", _faded(opaque), TRANSITION_TIME)
	await tween.finished
	scale = normal_scale
	modulate = opaque

func play_goal(goal_position: Vector2) -> void:
	velocity = Vector2.ZERO
	var tween := _transition_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", goal_position, TRANSITION_TIME)
	tween.tween_property(self, "modulate", _faded(modulate), TRANSITION_TIME)
	await tween.finished

func _transition_tween() -> Tween:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tween

func _faded(base: Color) -> Color:
	base.a = 0.0
	return base
