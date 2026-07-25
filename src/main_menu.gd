extends Control

@onready var buttons: VBoxContainer = %Buttons

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for button in buttons.get_children():
		if not button is Button: continue
		button.mouse_entered.connect(button.grab_focus)
		if button.visible and get_viewport().gui_get_focus_owner() == null: 
			button.grab_focus()
	
func _level_selection() -> void:
	get_tree().change_scene_to_file("res://src/levels/level_select.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
