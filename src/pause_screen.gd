extends CanvasLayer

@onready var screen: Control = $Screen
@onready var buttons: VBoxContainer = %Buttons
@onready var continue_button: Button = %Continue
@onready var volume_slider: HSlider = $Screen/Center/VBox/VolumeSlider

var transitioning := false

func _make_square_texture(color: Color, size: int) -> ImageTexture:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func _ready() -> void:
	volume_slider.value = MusicPlayer.volume_db
	volume_slider.add_theme_icon_override(&"grabber", _make_square_texture(Color(0.85, 0.85, 0.85, 1), 12))
	volume_slider.add_theme_icon_override(&"grabber_highlight", _make_square_texture(Color(1, 1, 1, 1), 12))
	for button in buttons.get_children():
		if button is Button: button.mouse_entered.connect(button.grab_focus)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"): return
	if transitioning: return

	if screen.visible:
		get_viewport().set_input_as_handled()
		_continue()
	elif not get_tree().paused:
		get_viewport().set_input_as_handled()
		_pause()

func _pause() -> void:
	screen.show()
	continue_button.grab_focus()
	transitioning = true
	var tween := create_tween()
	tween.tween_property(MusicPlayer, ^"volume_db", -80.0, 1.0)
	tween.tween_callback(func():
		get_tree().paused = true
		transitioning = false
	)

func _continue() -> void:
	screen.hide()
	get_tree().paused = false
	transitioning = true
	var tween := create_tween()
	tween.tween_property(MusicPlayer, ^"volume_db", volume_slider.value, 1.0)
	tween.tween_callback(func(): transitioning = false)

func _return_to_level_selection() -> void:
	transitioning = true
	get_tree().paused = false
	var tween := create_tween()
	tween.tween_property(MusicPlayer, ^"volume_db", volume_slider.value, 1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(&"res://src/levels/level_select.tscn")
	)

func _exit_tree() -> void:
	if screen.visible: get_tree().paused = false
	MusicPlayer.volume_db = volume_slider.value

func _on_volume_changed(value: float) -> void:
	MusicPlayer.volume_db = value
	MusicPlayer.save_volume()
