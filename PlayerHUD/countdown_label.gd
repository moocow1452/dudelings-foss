class_name CountdownLabel
extends Label
# A simple "timer" that shows a count down on the screen.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element
const TICK_SOUND: AudioStreamOGGVorbis = preload("res://Assets/PlayerHUD/audio/countdown_tick.ogg")

var _count_timer: Timer = self._make_countdown_timer()


func _ready() -> void:
	self.set_visible(false)


func count_down(starting_number: int) -> void:
	self._show_number(starting_number)
	self.set_visible(true)
	_count_timer.start()


func _decreese_number() -> void:
	var next_number: int = int(self.get_text()) - 1

	if next_number < 1:
		self.set_visible(false)
		_count_timer.stop()
		return

	self._show_number(next_number)


func _show_number(target_number: int) -> void:
	self.set_text(str(target_number))
	AudioController.play_universal_sound(TICK_SOUND)


func _make_countdown_timer() -> Timer:
	var count_timer := Timer.new()
	self.add_child(count_timer)
	count_timer.set_pause_mode(PAUSE_MODE_STOP)
	count_timer.set_wait_time(1.0)
	var _a = count_timer.connect("timeout", self, "_decreese_number")
	return count_timer
