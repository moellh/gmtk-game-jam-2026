extends Control

@export var levels: Array[LevelInfo] = []

@onready var list: VBoxContainer = $Center/VBox/Levels

func _ready() -> void:
	for i in levels.size():
		var info := levels[i]
		var button := Button.new()

		button.text = info.name
		button.pressed.connect(get_tree().change_scene_to_packed.bind(info.scene))
		button.mouse_entered.connect(button.grab_focus)
		list.add_child(button)

		if i == 0: button.grab_focus()
