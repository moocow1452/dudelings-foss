class_name TimedArenaPickup
extends ArenaPickup
# An abstract class for arena pickup that has a timed effect.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _timed_pickup_effect() -> void:
	pass  # Virtual method.


func _timeout_effect() -> void:
	pass  # Virtual method.


func _pickup_effect() -> void:
	self._timed_pickup_effect()


func _activate_animation_finished() -> void:
	var effect_timer: SceneTreeTimer = Globals.get_tree().create_timer(_effect_time, false)
	var _a = effect_timer.connect("timeout", self, "_on_effect_timer_timeout")


func _on_effect_timer_timeout() -> void:
	if ArenaController.current_game_state_contains(ArenaController.GameState.GAME_OVER):
		return
	
	self._timeout_effect()
	self.queue_free()
