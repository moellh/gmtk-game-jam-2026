extends Figure

const GHOST_SCENE := preload("res://src/ghost.tscn")

var spawn: Vector2
var recording_start: Vector2
var recording: Array[Dictionary] = []

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group(&"player")
	spawn = global_position
	recording_start = spawn

func _physics_process(delta: float) -> void:
	var action: Dictionary = {
		MOVE_AXIS: Input.get_axis("move_left", "move_right"),
		JUMP_PRESSED: Input.is_action_just_pressed("jump"),
		JUMP_RELEASED: Input.is_action_just_released("jump"),
	}
	
	apply_action(action, delta)
	recording.append(action)

func spawn_ghost() -> Node:
	var ghost := GHOST_SCENE.instantiate()
	ghost.setup(recording, collision_shape, self)
	ghost.global_position = recording_start
	ghost.add_to_group("ghosts")
	return ghost

func reset() -> void:
	recording = []
	recording_start = spawn
	reset_figure(recording_start)
