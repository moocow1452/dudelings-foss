class_name SceneSwitchingOverlay
extends CanvasLayer
# A black canvas overlay that covers the whole screen during scene transitions.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element

signal fade_in_complete
signal fade_out_complete

var _fade_color_rect: ColorRect = self._make_fade_color_rect()


func _init() -> void:
	self.set_layer(Globals.GameCanvasLayer.SCENE_SWITCHER)
	self.set_pause_mode(PAUSE_MODE_PROCESS)


# Block inputs during scene switching.
func _input(_event: InputEvent) -> void:
	if SceneController.is_switching_scenes():
		Globals.get_tree().set_input_as_handled()


# Block inputs during scene switching.
func _gui_input(_event: InputEvent) -> void:
	if SceneController.is_switching_scenes():
		_fade_color_rect.accept_event()


# Block inputs during scene switching.
func _unhandled_input(_event: InputEvent) -> void:
	if SceneController.is_switching_scenes():
		Globals.get_tree().set_input_as_handled()


func fade_in(fade_time: float) -> void:
	var fade_tween: SceneTreeTween = self.create_tween()
	var _a = fade_tween.tween_property(_fade_color_rect, "color:a", 1.0, fade_time)
	var _b = fade_tween.tween_callback(self, "_on_fade_in_complete")


func fade_out(fade_time: float) -> void:
	var fade_tween: SceneTreeTween = self.create_tween()
	var _a = fade_tween.tween_property(_fade_color_rect, "color:a", 0.0, fade_time)
	var _b = fade_tween.tween_callback(self, "_on_fade_out_complete")


func _on_fade_in_complete() -> void:
	self.emit_signal("fade_in_complete")


func _on_fade_out_complete() -> void:
	self.emit_signal("fade_out_complete")


func _make_fade_color_rect() -> ColorRect:
	var fade_color_rect := ColorRect.new()
	self.add_child(fade_color_rect)
	fade_color_rect.set_frame_color(Color(0.0, 0.0, 0.0, 0.0))
	fade_color_rect.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	fade_color_rect.set_focus_mode(Control.FOCUS_ALL)
	fade_color_rect.set_mouse_filter(Control.MOUSE_FILTER_STOP)  # Block mouse input during scene switching.
	fade_color_rect.call_deferred("grab_focus")  # Keep focus during scene transitions.
	return fade_color_rect
