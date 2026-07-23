class_name TouchControls
extends CanvasLayer

const BUTTON_NAMES: Array[StringName] = [
	&"Left",
	&"Right",
	&"Jump",
	&"Loop",
	&"Reset",
]
const PORTRAIT_MIN_ZONE := 128.0
const PORTRAIT_MAX_ZONE := 176.0

@export var force_visible_in_debug := false

@onready var controls: Control = $Root
@onready var portrait_zone: ColorRect = $Root/PortraitZone
@onready var visuals: Control = $Root/Visuals
@onready var hit_targets: Node2D = $Root/HitTargets

var touch_enabled := false
var reserved_bottom_height := 0.0
var idle_opacity := 1.0


func _ready() -> void:
	touch_enabled = (
		OS.has_feature("mobile")
		or (
			OS.has_feature("web")
			and DisplayServer.is_touchscreen_available()
		)
		or (
			OS.is_debug_build()
			and force_visible_in_debug
		)
	)

	for button_name in BUTTON_NAMES:
		var target := _target(button_name)
		target.pressed.connect(_set_pressed.bind(button_name, true))
		target.released.connect(_set_pressed.bind(button_name, false))


func layout_for_size(view_size: Vector2) -> void:
	if not touch_enabled:
		controls.hide()
		reserved_bottom_height = 0.0
		return

	controls.show()
	var portrait := view_size.y > view_size.x
	reserved_bottom_height = (
		clampf(view_size.y * 0.22, PORTRAIT_MIN_ZONE, PORTRAIT_MAX_ZONE)
		if portrait else 0.0
	)

	portrait_zone.visible = portrait
	if portrait:
		portrait_zone.position = Vector2(
			0.0,
			view_size.y - reserved_bottom_height,
		)
		portrait_zone.size = Vector2(
			view_size.x,
			reserved_bottom_height,
		)

	var margin := 8.0
	var main_size := Vector2(60.0, 56.0)
	var jump_size := Vector2(64.0, 56.0)
	var auxiliary_size := Vector2(64.0, 36.0)
	var bottom := view_size.y - margin

	_set_button_rect(
		&"Left",
		Rect2(Vector2(margin, bottom - main_size.y), main_size),
	)
	_set_button_rect(
		&"Right",
		Rect2(
			Vector2(margin + main_size.x + 6.0, bottom - main_size.y),
			main_size,
		),
	)
	_set_button_rect(
		&"Jump",
		Rect2(
			Vector2(
				view_size.x - margin - jump_size.x,
				bottom - jump_size.y,
			),
			jump_size,
		),
	)

	var auxiliary_width := auxiliary_size.x * 2.0 + 8.0
	if portrait:
		var auxiliary_y := view_size.y - reserved_bottom_height + 12.0
		var auxiliary_x := (view_size.x - auxiliary_width) * 0.5
		_set_button_rect(
			&"Loop",
			Rect2(Vector2(auxiliary_x, auxiliary_y), auxiliary_size),
		)
		_set_button_rect(
			&"Reset",
			Rect2(
				Vector2(auxiliary_x + auxiliary_size.x + 8.0, auxiliary_y),
				auxiliary_size,
			),
		)
	else:
		_set_button_rect(
			&"Loop",
			Rect2(Vector2(margin, margin), auxiliary_size),
		)
		_set_button_rect(
			&"Reset",
			Rect2(
				Vector2(view_size.x - margin - auxiliary_size.x, margin),
				auxiliary_size,
			),
		)

	_apply_visual_style(portrait)


func _set_button_rect(button_name: StringName, rect: Rect2) -> void:
	var target := _target(button_name)
	var visual := _visual(button_name)
	var shape := target.shape as RectangleShape2D

	target.position = rect.get_center()
	shape.size = rect.size
	visual.position = rect.position
	visual.size = rect.size


func _apply_visual_style(portrait: bool) -> void:
	idle_opacity = 0.82 if portrait else 0.76
	for button_name in BUTTON_NAMES:
		var target := _target(button_name)
		_set_pressed(
			button_name,
			Input.is_action_pressed(target.action),
		)


func _set_pressed(button_name: StringName, value: bool) -> void:
	_visual(button_name).modulate = Color(
		1.0,
		1.0,
		1.0,
		1.0 if value else idle_opacity,
	)


func _target(button_name: StringName) -> TouchScreenButton:
	return hit_targets.get_node(NodePath(button_name)) as TouchScreenButton


func _visual(button_name: StringName) -> Label:
	return visuals.get_node(NodePath("%sVisual" % button_name)) as Label
