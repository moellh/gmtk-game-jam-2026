extends AnimatedSprite2D

@export var frozen_color: Color
@export var ghost_color: Color

var recording: Array = []
var playback := 0
var solid_at_rest := false

var _is_solid := false

@onready var solid_shape: CollisionShape2D = $Solid/CollisionShape2D

func setup(rec: Array) -> void:
	recording = rec

func restart() -> void:
	playback = 0
	_is_solid = false
	modulate = ghost_color
	solid_shape.set_deferred("disabled", true)

func _physics_process(_delta: float) -> void:
	if playback >= recording.size():
		if solid_at_rest: _frozen()
		return
	_advance_recording()

func _frozen() -> void:
	if _is_solid: return
	_is_solid = true
	solid_shape.set_deferred("disabled", false)
	modulate = frozen_color
	pause()

func _advance_recording():
	var f: Dictionary = recording[playback]
	global_position = f.pos
	flip_h = f.flip
	play(f.anim)
	playback += 1
