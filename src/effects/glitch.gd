extends CanvasLayer

const BURST_TIME := 0.25
const VISIBLE_STRENGTH := 0.02
const MAX_VOLUME_DB := -6.0
const MIN_ACTIVE_VOLUME_DB := -36.0
const SILENT_VOLUME_DB := -80.0
const STOP_VOLUME_DB := -60.0
const VOLUME_ATTACK_SMOOTHING := 16.0
const VOLUME_RELEASE_SMOOTHING := 6.0

@onready var rect: ColorRect = $Rect
@onready var _mat: ShaderMaterial = rect.material
@onready var _sound: AudioStreamPlayer = $Sound

var _burst := 0.0
var _danger := 0.0
var _sound_strength := 0.0
var _target_volume_db := SILENT_VOLUME_DB
var _tween: Tween

func _process(delta: float) -> void:
	if not _sound.playing: return
	var smoothing := VOLUME_ATTACK_SMOOTHING if _target_volume_db > _sound.volume_db else VOLUME_RELEASE_SMOOTHING
	var weight := 1.0 - exp(-smoothing * delta)
	_sound.volume_db = lerpf(_sound.volume_db, _target_volume_db, weight)
	if _target_volume_db == SILENT_VOLUME_DB and _sound.volume_db <= STOP_VOLUME_DB:
		_sound.stop()
		_sound.volume_db = SILENT_VOLUME_DB

func play() -> void:
	if _tween: _tween.kill()
	_set_burst(1.0)
	_tween = create_tween()
	_tween.tween_method(_set_burst, 1.0, 0.0, BURST_TIME)

func set_danger(value: float) -> void:
	_danger = clampf(value, 0.0, 1.0)
	_apply()

func set_sound_strength(value: float) -> void:
	_sound_strength = clampf(value, 0.0, 1.0)
	_apply()

func _set_burst(value: float) -> void:
	_burst = value
	_apply()

func _apply() -> void:
	var glitch := maxf(_burst, _danger)
	var gameplay_sound_strength := inverse_lerp(VISIBLE_STRENGTH, 1.0, glitch) if glitch > VISIBLE_STRENGTH else 0.0
	var sound_strength := maxf(gameplay_sound_strength, _sound_strength)
	rect.visible = glitch > VISIBLE_STRENGTH
	_mat.set_shader_parameter("strength", glitch)
	_mat.set_shader_parameter("red", _danger)
	_target_volume_db = _volume_for_strength(sound_strength)
	if sound_strength > 0.0 and not _sound.playing:
		_sound.volume_db = SILENT_VOLUME_DB
		_sound.play()

func _volume_for_strength(strength: float) -> float:
	if strength <= 0.0: return SILENT_VOLUME_DB
	return maxf(linear_to_db(sqrt(strength)) + MAX_VOLUME_DB, MIN_ACTIVE_VOLUME_DB)
