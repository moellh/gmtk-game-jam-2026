extends AnimatedSprite2D

var recording: Array = []
var playback := 0

func setup(rec: Array) -> void:
	recording = rec

func restart() -> void:
	playback = 0

func _physics_process(_delta: float) -> void:
	if playback >= recording.size(): return # Freeze on end

	var f: Dictionary = recording[playback]
	global_position = f.pos
	flip_h = f.flip
	play(f.anim)

	playback += 1
