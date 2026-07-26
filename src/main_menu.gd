extends Control

@onready var buttons: VBoxContainer = %Buttons

const NORMAL_INFO := "Ghosts are harmless."
const HAUNTING_INFO := "Touching your ghost kills you."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ModeToggle.button_pressed = GameMode.haunting_enabled
	_update_mode_ui()
	
	for button in buttons.get_children():
		if not button is Button: continue
		button.mouse_entered.connect(button.grab_focus)
		if button.visible and get_viewport().gui_get_focus_owner() == null: 
			button.grab_focus()
	
func _level_selection() -> void:
	get_tree().change_scene_to_file("res://src/levels/level_select.tscn")

func _mode_toggle(pressed: bool) -> void:
	GameMode.haunting_enabled = pressed
	_update_mode_ui()

func _update_mode_ui() -> void:
	%ModeToggle.text = "Haunting Mode" if GameMode.haunting_enabled else "Normal Mode"
	%ModeInfo.text = HAUNTING_INFO if GameMode.haunting_enabled else NORMAL_INFO
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass