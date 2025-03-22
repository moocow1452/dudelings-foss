class_name GameCamera
extends Camera2D
# The main camera for the game arena scene. Shakes when a goal is scored.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

var MAX_SHAKE_STRENGHT: float = 10.0
var SHAKE_DECAY_RATE: float = 1.0
var SHAKE_NOISE_SPEED: float = 30.0
var SHAKE_NOIDSE_STRENGHT: float = 60.0

var _noise := OpenSimplexNoise.new()
var _noise_i: float = 0.0
var _shake_strenght: float = 0.0
var _shake_timer: Timer = self._make_shake_timer()


func _init() -> void:
	var _a = ArenaController.connect("player_scored", self, "_on_player_scored")
	self.add_to_group(Globals.GAME_CAMERA_GROUP)
	_noise.set_seed(Globals.rng.randi())
	_noise.set_period(2)


func _physics_process(delta: float) -> void:
	if _shake_strenght > 0.0:
		_shake_strenght = lerp(_shake_strenght, 0.0, SHAKE_DECAY_RATE * delta)
		self.set_offset(self._offset_from_noise(delta))


func shake_screen(shake_time: float) -> void:
	if !DisplayController.get_screen_shake_enabled():
		return

	_shake_strenght = MAX_SHAKE_STRENGHT
	_shake_timer.start(shake_time)


func stop_shaking_screen() -> void:
	_shake_timer.stop()
	_shake_strenght = 0.0
	self.set_offset(Vector2())


func _offset_from_noise(delta: float) -> Vector2:
	_noise_i += SHAKE_NOISE_SPEED * delta
	return Vector2(_noise.get_noise_2d(1.0, _noise_i) * _shake_strenght, _noise.get_noise_2d(100.0, _noise_i) * _shake_strenght)


func _on_player_scored(scoring_player: int) -> void:
	if scoring_player == 1:
		self.shake_screen(0.5)
	elif scoring_player == 2:
		self.shake_screen(0.5)

func _make_shake_timer() -> Timer:
	var shake_timer := Timer.new()
	self.add_child(shake_timer)
	shake_timer.set_pause_mode(PAUSE_MODE_STOP)
	shake_timer.set_one_shot(true)
	var _a = shake_timer.connect("timeout", self, "stop_shaking_screen")
	return shake_timer
