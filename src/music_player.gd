extends AudioStreamPlayer

const INTRO := preload("res://assets/YATEOI - No Royals PLS - 01 En el pozo - Start.ogg")
const LOOP := preload("res://assets/YATEOI - No Royals PLS - 01 En el pozo - Looped.ogg")
const SAVE_PATH := "user://music_volume.cfg"

func _ready() -> void:
	volume_db = load_volume()
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

func save_volume() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("music", "volume_db", volume_db)
	cfg.save(SAVE_PATH)
