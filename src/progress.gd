extends Node

const SAVE_PATH := "user://progress.cfg"

var _completed := {}

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK: return
	for path in cfg.get_value("progress", "completed", []): _completed[path] = true

func is_completed(scene_path: String) -> bool:
	return _completed.has(scene_path)

func mark_completed(scene_path: String) -> void:
	if scene_path.is_empty() or _completed.has(scene_path): return
	_completed[scene_path] = true

	var cfg := ConfigFile.new()
	cfg.set_value("progress", "completed", _completed.keys())
	cfg.save(SAVE_PATH)
