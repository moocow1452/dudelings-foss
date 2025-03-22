class_name CityBuilding
extends Node2D
# An arena background object that can turn off and on its lights as well as flash them.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const FLASH_SPEED: float = 0.5
const WINDOW_LIGHT_ON_COLORS: Array =[
	Color(0.996078, 1, 0.890196),
	Color(0.890196, 0.686275, 0.309804),
]
const WINDOW_LIGHT_OFF_COLOR := Color(0, 0.047059, 0)

var _flash_cycle_timer: CycleTimer = self._make_flash_cycle_timer()


func _ready() -> void:
	self.turn_lights_off()


func turn_lights_on() -> void:
	for window in $BuildingSprite/Windows.get_children():
		window.set_frame_color(self._choose_light_on_color())


func turn_lights_off() -> void:
	for window in $BuildingSprite/Windows.get_children():
		window.set_frame_color(WINDOW_LIGHT_OFF_COLOR)


func randomize_lights() -> void:
	for window in $BuildingSprite/Windows.get_children():
		window.set_frame_color(self._choose_light_on_color() if Globals.rng.randf() <= 0.5 else WINDOW_LIGHT_OFF_COLOR)


func start_flashing_lights(flash_time: float = -1.0) -> void:
	_flash_cycle_timer.start_cycle(flash_time, FLASH_SPEED, false)


func stop_flashing_lights() -> void:
	_flash_cycle_timer.stop_cycle()


func _choose_light_on_color() -> Color:
	return WINDOW_LIGHT_ON_COLORS[Globals.rng.randi_range(0, WINDOW_LIGHT_ON_COLORS.size() - 1)]


func _make_flash_cycle_timer() -> CycleTimer:
	var cycle_timer := CycleTimer.new()
	self.add_child(cycle_timer)
	var _a = cycle_timer.connect("timeout", self, "stop_flashing_lights")
	var _b = cycle_timer.connect("interval_timeout", self, "randomize_lights")
	return cycle_timer
