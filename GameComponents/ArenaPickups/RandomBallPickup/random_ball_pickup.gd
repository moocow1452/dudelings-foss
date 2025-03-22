class_name RandomBallPickup
extends ArenaPickup
# Turns activating ball into a random ball type.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _init() -> void:
	pickup_type = PickupType.RANDOM_BALL


func _pickup_effect() -> void:
	self.call_deferred("_change_game_ball_type")  # 'call_deferred' to allow "queries to flush".


func _change_game_ball_type() -> void:
	if !is_instance_valid(_activating_ball):
		return
	
	var current_linear_velocity: Vector2 = _activating_ball.get_linear_velocity()
	var current_angular_velocity: float = _activating_ball.get_angular_velocity()
	var current_applied_forces: Vector2 = _activating_ball.get_applied_force()

	var new_ball_options: Array = GameBall.GameBallType.values()
	new_ball_options.erase(_activating_ball.get_game_ball_type())
	new_ball_options.erase(GameBall.GameBallType.RANDOM_BALL)
	var new_ball_type: int = new_ball_options[Globals.rng.randi_range(0, new_ball_options.size() - 1)]

	var new_ball = ArenaController.game_ball_spawner().spawn_game_ball(
		_activating_ball.get_controlling_player(),
		new_ball_type, _activating_ball.get_game_ball_size(),
		_activating_ball.get_global_position()
	)

	_activating_ball.queue_free()

	if is_instance_valid(new_ball):
		new_ball.set_linear_velocity(current_linear_velocity)
		new_ball.set_angular_velocity(current_angular_velocity)
		new_ball.set_applied_force(current_applied_forces)
		
		if _activating_player > 0:
			new_ball.give_player_control(_activating_player)
