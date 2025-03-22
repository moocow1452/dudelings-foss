class_name SmallerBallPickup
extends ArenaPickup
# Makes the activating game ball bigger.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _pickup_effect() -> void:
	if is_instance_valid(_activating_ball):
		_activating_ball.set_game_ball_size(_activating_ball.get_game_ball_size() - 1)
