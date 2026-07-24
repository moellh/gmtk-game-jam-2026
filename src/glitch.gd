extends CanvasLayer

const DURATION := 0.25

@onready var rect: ColorRect = $Rect
@onready var _mat: ShaderMaterial = rect.material

var _tween: Tween

func play() -> void:
	if _tween: _tween.kill()
	rect.visible = true
	_mat.set_shader_parameter("strength", 1.0)
	_tween = create_tween()
	_tween.tween_property(_mat, "shader_parameter/strength", 0.0, DURATION)
	_tween.tween_callback(func() -> void: rect.visible = false)
