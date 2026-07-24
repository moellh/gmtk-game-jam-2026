class_name RoundTimer
extends Label

@export var round_time := 10.0

var _time_left := 0.0

func _ready() -> void:
	reset()

func reset() -> void:
	_time_left = round_time
	_refresh()

func advance(delta: float) -> void:
	_time_left = maxf(_time_left - delta, 0.0)
	_refresh()

func is_expired() -> bool:
	return _time_left <= 0.0

func _refresh() -> void:
	var tenths := roundi(_time_left * 10.0)
	var seconds := mini(floori(tenths * 0.1), 99)
	text = "%d.%d" % [seconds, tenths % 10]
