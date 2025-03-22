class_name CityStadium
extends Node2D
# The outside of the stadium.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const FLASH_SPEED: float = 0.25

var _flash_cycle_timer: CycleTimer = self._make_flash_cycle_timer()


func _ready() -> void:
	self.turn_lights_on()
	self._cycle_stadium_glow()


func turn_lights_on() -> void:
	for light in $StadiumLights.get_children():
		light.set_visible(true)


func turn_lights_off() -> void:
	for light in $StadiumLights.get_children():
		light.set_visible(false)


func randomize_lights() -> void:
	for light in $StadiumLights.get_children():
		light.set_visible(Globals.rng.randf() <= 0.5)


func start_flashing_lights(flash_time: float = -1.0) -> void:
	_flash_cycle_timer.start_cycle(flash_time, FLASH_SPEED)


func stop_flashing_lights() -> void:
	_flash_cycle_timer.stop_cycle()


func _cycle_stadium_glow() -> void:
	var glow_tween: SceneTreeTween = self.create_tween().set_parallel(true)
	var _a = glow_tween.tween_property($GlowLight, "modulate:a", Globals.rng.randf_range(0.0, 0.3), Globals.rng.randf_range(0.25, 0.75))
	var _b = glow_tween.chain().tween_property($GlowLight, "modulate:a", Globals.rng.randf_range(0.7, 1.0), Globals.rng.randf_range(0.25, 0.75))
	var _c = glow_tween.set_loops()


func _make_flash_cycle_timer() -> CycleTimer:
	var cycle_timer := CycleTimer.new()
	self.add_child(cycle_timer)
	var _a = cycle_timer.connect("timeout", self, "stop_flashing_lights")
	var _b = cycle_timer.connect("interval_timeout", self, "randomize_lights")
	return cycle_timer
