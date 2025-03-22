class_name SwitchConrolPickup
extends ArenaPickup
# Switches which player is controlling the ball.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _init() -> void:
	pickup_type = PickupType.SWITCH_CONTROL


func _pickup_effect() -> void:
	if is_instance_valid(_activating_ball):
		_activating_ball.give_player_control(Globals.other_player(_activating_player))
