class_name RoundTimer
extends Label

const DANGER_COLOR := Color(1.0, 0.25, 0.25)

@export var round_time := 10.0
@export var danger_curve := 5.0

var _time_left := 0.0

@onready var _base_position := position

func _ready() -> void:
	reset()

func _exit_tree() -> void:
	Glitch.set_danger(0.0)

func reset() -> void:
	_time_left = round_time
	_refresh()

func advance(delta: float) -> void:
	_time_left = maxf(_time_left - delta, 0.0)
	_refresh()

func is_expired() -> bool:
	return _time_left <= 0.0

func _refresh() -> void:
	var danger := pow(1.0 - _time_left / round_time, danger_curve)
	Glitch.set_danger(danger)

	var tenths := roundi(_time_left * 10.0)
	var seconds := mini(floori(tenths * 0.1), 99)
	text = "%d.%d" % [seconds, tenths % 10]
	position = _base_position + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * danger * 2.0
	self_modulate = Color.WHITE.lerp(DANGER_COLOR, danger)
