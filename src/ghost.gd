extends Figure

var recording: Array[Dictionary] = []
var playback := 0
var spawn: Vector2
var live_player: PhysicsBody2D

func setup(
	actions: Array[Dictionary],
	source_collision: CollisionShape2D,
	player: PhysicsBody2D,
) -> void:
	recording.assign(actions)
	live_player = player

	var collision_shape := get_node("CollisionShape2D") as CollisionShape2D
	collision_shape.position = source_collision.position
	collision_shape.shape = source_collision.shape

func _ready() -> void:
	spawn = global_position
	add_collision_exception_with(live_player)
	reset_figure(spawn)

func restart() -> void:
	playback = 0
	reset_figure(spawn)

func _physics_process(delta: float) -> void:
	if playback >= recording.size():
		return

	apply_action(recording[playback], delta)
	playback += 1
