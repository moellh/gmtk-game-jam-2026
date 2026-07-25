extends CanvasLayer

@onready var screen: Control = $Screen
@onready var buttons: VBoxContainer = %Buttons
@onready var continue_button: Button = %Continue

func _ready() -> void:
	for button in buttons.get_children():
		if button is Button: button.mouse_entered.connect(button.grab_focus)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"): return

	if screen.visible:
		get_viewport().set_input_as_handled()
		_continue()
	elif not get_tree().paused:
		get_viewport().set_input_as_handled()
		screen.show()
		get_tree().paused = true
		continue_button.grab_focus()

func _continue() -> void:
	screen.hide()
	get_tree().paused = false

func _return_to_level_selection() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(&"res://src/levels/level_select.tscn")

func _exit_tree() -> void:
	if screen.visible: get_tree().paused = false
