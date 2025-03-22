tool
class_name Fireworks
extends ColorRect
# This class launches fireworks into a determined area at a specified rate. It is designed to
# be run as a tool in the editor. A firework is an abstract scene that is preloaded here.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const SCALE_RANDOMNESS: float = 0.5
const FIREWORK_SCENE: PackedScene = preload("scenes/Firework.tscn")

export(float) var _firework_scale: float = 1.0
export(float) var _min_time_between: float = 0.5
export(float) var _max_time_between: float = 1.0

var _launch_cycle_timer: CycleTimer = self._make_launch_cycle_timer()


func _ready() -> void:
	if Engine.editor_hint:
		self.set_frame_color(Color(1.0, 0.5, 0.5, 0.5))
	else:
		self.set_frame_color(Color(0.0, 0.0, 0.0, 0.0))


func start_launching(launch_time: float = -1.0) -> void:
	_launch_cycle_timer.start_cycle(launch_time, Globals.rng.randf_range(_min_time_between, _max_time_between))


func stop_launching() -> void:
	_launch_cycle_timer.stop_cycle()


func _launch_firework() -> void:
	var firework: Firework = FIREWORK_SCENE.instance()
	self.add_child(firework)
	firework.set_scale(Vector2(_firework_scale, _firework_scale) * Globals.rng.randf_range(1.0 - SCALE_RANDOMNESS, 1.0))

	var pos_x = Globals.rng.randf_range(self.get_global_rect().position.x, self.get_global_rect().end.x)
	var pos_y = Globals.rng.randf_range(self.get_global_rect().position.y, self.get_global_rect().end.y)
	firework.set_global_position(Vector2(pos_x, pos_y))


func _on_launch_cycle_timer_interval_timeout() -> void:
	self._launch_cycle_timer.set_interval_time(Globals.rng.randf_range(_min_time_between, _max_time_between))
	self._launch_firework()


func _make_launch_cycle_timer() -> CycleTimer:
	var cycle_timer := CycleTimer.new()
	self.add_child(cycle_timer)
	var _a = cycle_timer.connect("timeout", self, "stop_launching")
	var _b = cycle_timer.connect("interval_timeout", self, "_on_launch_cycle_timer_interval_timeout")
	return cycle_timer
