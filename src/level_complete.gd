extends CanvasLayer

const LEVEL_SELECT := "res://src/level_select.tscn"

@onready var screen: Control = $Screen
@onready var next_button: Button = %NextLevel
@onready var selection_button: Button = %LevelSelection

var next_scene: PackedScene


func _ready() -> void:
	for button in [next_button, selection_button]:
		button.mouse_entered.connect(button.grab_focus)


func open(scene: PackedScene) -> void:
	next_scene = scene
	next_button.visible = next_scene != null
	screen.show()
	get_tree().paused = true

	if next_button.visible:
		next_button.grab_focus()
	else:
		selection_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if screen.visible and event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		_level_selection()


func _next_level() -> void:
	if next_scene == null:
		return
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_scene)


func _level_selection() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_SELECT)
