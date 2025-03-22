class_name HideHighlightPickup
extends TimedArenaPickup
# Hides player highlights on Dudelings.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

var _target_player: int = 0


func _init() -> void:
	pickup_type = PickupType.HIDE_HIGHLIGHT
	_effect_time = 10.0


func _timed_pickup_effect() -> void:
	if _activating_player == 0:
		return
	
	_target_player = Globals.other_player(_activating_player)
	ArenaController.dudeling_row().hide_dudeling_highlight(_target_player, _effect_time)


func _timeout_effect() -> void:
	pass  # This acts like a timed pickup but the timeout effect is handled by the highlihgt system.
