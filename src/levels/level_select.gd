extends Control

const HINT_PLAY := "[<] [>] BROWSE     [ENTER] PLAY"
const HINT_LOCKED := "[<] [>] BROWSE     LOCKED"

@export var levels: Array[LevelInfo] = []

var _index := 0
var _thumbs := {}

@onready var _name_label: Label = $Window/VBox/Name
@onready var _preview: TextureRect = $Window/VBox/Row/PreviewFrame/Preview
@onready var _hint: Label = $Window/VBox/Hint
@onready var _glitch: ColorRect = $Glitch
@onready var _capture: SubViewport = $Capture

func _ready() -> void:
	_index = _frontier()
	_refresh()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"): _step(-1)
	elif event.is_action_pressed("ui_right"): _step(1)
	elif event.is_action_pressed("ui_accept") and not levels.is_empty():
		if _is_unlocked(_index): get_tree().change_scene_to_packed(levels[_index].scene)

func _frontier() -> int:
	for i in levels.size(): if not Progress.is_completed(levels[i].scene.resource_path): return i
	return maxi(levels.size() - 1, 0)

func _step(dir: int) -> void:
	if levels.is_empty(): return
	_index = wrapi(_index + dir, 0, levels.size())
	_refresh()

func _is_unlocked(index: int) -> bool:
	return index == 0 or Progress.is_completed(levels[index - 1].scene.resource_path)

func _refresh() -> void:
	if levels.is_empty(): return
	var index := _index
	var unlocked := _is_unlocked(index)
	_name_label.text = levels[index].name
	_hint.text = HINT_PLAY if unlocked else HINT_LOCKED
	_glitch.visible = not unlocked
	var texture := await _thumbnail(index)
	if index == _index: _preview.texture = texture

func _thumbnail(index: int) -> Texture2D:
	if _thumbs.has(index): return _thumbs[index]

	var instance := levels[index].scene.instantiate()
	_capture.add_child(instance)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var texture := ImageTexture.create_from_image(_capture.get_texture().get_image())
	instance.queue_free()
	
	# HACK: the instantiated scene pauses the root (also menu) => unpause
	get_tree().paused = false

	_thumbs[index] = texture
	return texture
