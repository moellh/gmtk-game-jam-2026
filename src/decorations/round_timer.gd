@tool
class_name RoundTimer
extends Label

const DANGER_COLOR := Color(1.0, 0.25, 0.25)

@export var round_time := 10.0:
	set(value): round_time = value; text = "%d.%d" % [mini(int(value), 99), int(value * 10.0) % 10]
@export var danger_curve: Curve

var _time_left := 0.0

@onready var _base_position := position

func _ready() -> void:
	if Engine.is_editor_hint(): return
	reset()

func _exit_tree() -> void:
	if Engine.is_editor_hint(): return
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
	var elapsed := 1.0 - _time_left / round_time
	var danger := clampf(danger_curve.sample(elapsed), 0.0, 1.0) if danger_curve else elapsed
	Glitch.set_danger(danger)

	var tenths := roundi(_time_left * 10.0)
	var seconds := mini(floori(tenths * 0.1), 99)
	text = "%d.%d" % [seconds, tenths % 10]
	position = _base_position + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * danger * 2.0
	self_modulate = Color.WHITE.lerp(DANGER_COLOR, danger)
