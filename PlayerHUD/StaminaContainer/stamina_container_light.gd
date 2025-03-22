class_name StaminaContainerLight
extends TextureRect
# A light that sits inside a stamina container and changes color to show if its charged or not.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element
const FLASH_SPEED: float = 0.1
const GREEN_LIGHT_TEXTURES: Array = [
	preload("resources/green_light_0.tres"),
	preload("resources/green_light_1.tres"),
	preload("resources/green_light_2.tres"),
	preload("resources/green_light_3.tres"),
]
const YELLOW_LIGHT_TEXTURES: Array = [
	preload("resources/yellow_light_0.tres"),
	preload("resources/yellow_light_1.tres"),
	preload("resources/yellow_light_2.tres"),
	preload("resources/yellow_light_3.tres"),
]

var _anim_frame: int = 0
var _is_charged: bool = true
var _flash_timer: Timer = self._make_flash_timer()


func set_charged(is_charged: bool, play_anim: bool = false) -> void:
	_is_charged = is_charged

	if play_anim:
		self._start_flashing()
	else:
		self._change_frame(0)


func _anim_set() -> Array:
	return GREEN_LIGHT_TEXTURES if _is_charged else YELLOW_LIGHT_TEXTURES


func _start_flashing() -> void:
	self._change_frame(0)
	_flash_timer.start(FLASH_SPEED)


func _change_frame(anim_frame: int) -> void:
	_anim_frame = anim_frame
	self.set_texture(self._anim_set()[_anim_frame])


func _make_flash_timer() -> Timer:
	var flash_timer := Timer.new()
	self.add_child(flash_timer)
	flash_timer.set_pause_mode(PAUSE_MODE_STOP)
	var _a = flash_timer.connect("timeout", self, "_on_flash_timer_timeout")
	return flash_timer


func _on_flash_timer_timeout() -> void:
	if _anim_frame + 1 > self._anim_set().size() - 1:
		_flash_timer.stop()
		self._change_frame(0)
		return

	self._change_frame(_anim_frame + 1)
