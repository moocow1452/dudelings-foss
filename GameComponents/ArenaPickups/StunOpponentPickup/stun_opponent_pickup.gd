class_name StunOpponentPickup
extends ArenaPickup
# Stuns the other player.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _init() -> void:
	pickup_type = PickupType.STUN_OPPONENT


func _pickup_effect() -> void:
	if is_instance_valid(_activating_ball):
		var target_player: int = Globals.other_player(_activating_player)
		ArenaController.dudeling_row().stun_player(target_player)
		ArenaController.dudeling_row().stun_dudeling(ArenaController.dudeling_row().player_dudeling(target_player))
