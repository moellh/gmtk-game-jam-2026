extends CanvasLayer

const BURST_TIME := 0.25

@onready var rect: ColorRect = $Rect
@onready var _mat: ShaderMaterial = rect.material

var _burst := 0.0
var _danger := 0.0
var _tween: Tween

func play() -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_burst, 1.0, 0.0, BURST_TIME)

func set_danger(value: float) -> void:
	_danger = clampf(value, 0.0, 1.0)
	_apply()

func _set_burst(value: float) -> void:
	_burst = value
	_apply()

func _apply() -> void:
	var glitch := maxf(_burst, _danger)
	rect.visible = glitch > 0.001
	_mat.set_shader_parameter("strength", glitch)
	_mat.set_shader_parameter("red", _danger)
