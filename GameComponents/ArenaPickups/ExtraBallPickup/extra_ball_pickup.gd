class_name ExtraBallPickup
extends ArenaPickup
# Adds a duplicate ball to the arena.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _init() -> void:
	pickup_type = PickupType.EXTRA_BALL


func _pickup_effect() -> void:
	self.call_deferred("_spawn_extra_ball")  # 'call_deferred' to allow "queries to flush".


func _spawn_extra_ball() -> void:
	if !is_instance_valid(_activating_ball):
		return
	
	var new_ball = ArenaController.game_ball_spawner().spawn_game_ball(
		_activating_ball.get_controlling_player(),
		_activating_ball.get_game_ball_type(),
		_activating_ball.get_game_ball_size(),
		_activating_ball.get_global_position()
	)

	if is_instance_valid(new_ball):
		new_ball.give_player_control(_activating_player)
