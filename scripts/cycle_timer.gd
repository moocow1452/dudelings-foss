class_name CycleTimer
extends Timer
# A timer that cycles in set intervals for a period of time.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element

signal interval_timeout

var interval_timer: Timer = self._make_interval_timer() setget , get_interval_timer


func get_interval_timer() -> Timer:
	return interval_timer


func _init() -> void:
	self.set_pause_mode(PAUSE_MODE_STOP)
	self.set_one_shot(true)
	var _a = self.connect("timeout", self, "_on_self_timeout")


func set_interval_time(time: float) -> void:
	interval_timer.set_wait_time(time)


func start_cycle(time: float, interval_time: float, reset_if_running: bool = true) -> void:
	# Run intervals indefinitely if time is not set.
	if time <= 0.0:
		self.stop()
	elif self.is_stopped() || reset_if_running:
		self.start(time)
	
	interval_timer.start(interval_time)


func stop_cycle() -> void:
	self.stop()
	interval_timer.stop()


func _make_interval_timer() -> Timer:
	var timer := Timer.new()
	self.add_child(timer)
	timer.set_pause_mode(PAUSE_MODE_STOP)
	var _a = timer.connect("timeout", self, "_on_interval_timer_timeout")
	return timer


func _on_self_timeout() -> void:
	interval_timer.stop()


func _on_interval_timer_timeout() -> void:
	self.emit_signal("interval_timeout")
