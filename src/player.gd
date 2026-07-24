extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -300.0
const ACCEL := 2000.0
const FRICTION := 2500.0
const LEDGE_TIME := 0.1
const JUMP_BUFFER := 0.1

const GHOST_SCENE := preload("res://src/ghost.tscn")

var ledge_timer := 0.0
var buffer_timer := 0.0

var spawn: Vector2
var recording: Array[Dictionary] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group(&"player")
	spawn = global_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	ledge_timer = LEDGE_TIME if is_on_floor() else ledge_timer - delta
	buffer_timer = JUMP_BUFFER if Input.is_action_just_pressed("jump") else buffer_timer - delta
	if buffer_timer > 0.0 and ledge_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		buffer_timer = 0.0
		ledge_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.4

	var move_axis := Input.get_axis("move_left", "move_right")
	if move_axis:
		velocity.x = move_toward(velocity.x, move_axis * SPEED, 1.5 * ACCEL * delta)
		sprite.flip_h = move_axis < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

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

func spawn_ghost() -> Node:
	var ghost := GHOST_SCENE.instantiate()
	ghost.setup(recording)
	ghost.global_position = spawn
	ghost.add_to_group(&"ghosts")
	return ghost

func reset() -> void:
	recording = []
	velocity = Vector2.ZERO
	global_position = spawn
