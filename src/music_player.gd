extends AudioStreamPlayer

const INTRO := preload("res://assets/YATEOI - No Royals PLS - 01 En el pozo - Start.ogg")
const LOOP := preload("res://assets/YATEOI - No Royals PLS - 01 En el pozo - Looped.ogg")
const SAVE_PATH := "user://music_volume.cfg"

var muted := false
var _unmuted_volume := -6.0

func _ready() -> void:
	_unmuted_volume = load_volume()
	set_muted(load_muted())
	stream = INTRO
	play()
	finished.connect(_on_finished, CONNECT_ONE_SHOT)

func _on_finished() -> void:
	stream = LOOP
	play()
	finished.connect(func(): play())

func load_volume() -> float:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		return clamp(cfg.get_value("music", "volume_db", -6.0), -40.0, -6.0)
	return -6.0

func load_muted() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		return cfg.get_value("music", "muted", false)
	return false

func get_music_volume() -> float:
	return _unmuted_volume

func get_playback_volume() -> float:
	return -80.0 if muted else _unmuted_volume

func set_music_volume(value: float, apply := true) -> void:
	_unmuted_volume = clamp(value, -40.0, -6.0)
	if apply and not muted:
		volume_db = _unmuted_volume

func set_muted(value: bool, apply := true) -> void:
	muted = value
	if apply:
		volume_db = get_playback_volume()

func save_volume() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("music", "volume_db", _unmuted_volume)
	cfg.set_value("music", "muted", muted)
	cfg.save(SAVE_PATH)
