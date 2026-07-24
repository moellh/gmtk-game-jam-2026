extends CanvasLayer

@onready var screen: Control = $Screen

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"): return

	if screen.visible:
		get_viewport().set_input_as_handled()
		screen.hide()
		get_tree().paused = false
	elif not get_tree().paused:
		get_viewport().set_input_as_handled()
		screen.show()
		get_tree().paused = true

func _exit_tree() -> void:
	if screen.visible: get_tree().paused = false
