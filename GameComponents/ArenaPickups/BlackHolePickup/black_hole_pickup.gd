 class_name BlackHolePickup
extends TimedArenaPickup
# Moves the game ball to a random location.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

var _controlling_player: int = 0
var _ball_type: int = -1
var _ball_size: int = -1
var _velocity := Vector2()
var _angular_velocity: float = 0.0
var _applied_forces := Vector2()


func _init() -> void:
	pickup_type = PickupType.BLACK_HOLE
	_effect_time = 2.0


func _timed_pickup_effect() -> void:
	if is_instance_valid(_activating_ball):
		_controlling_player = _activating_ball.get_controlling_player()
		_ball_type = _activating_ball.get_game_ball_type()
		_ball_size = _activating_ball.get_game_ball_size()
		_velocity = _activating_ball.get_linear_velocity()
		_angular_velocity = _activating_ball.get_angular_velocity()
		_applied_forces = _activating_ball.get_applied_force()

		_activating_ball.queue_free()


func _timeout_effect() -> void:
	var new_ball = ArenaController.game_ball_spawner().spawn_game_ball(_controlling_player, _ball_type, _ball_size)

	if is_instance_valid(new_ball):
		new_ball.give_player_control(_controlling_player)
		new_ball.set_linear_velocity(_velocity)
		new_ball.set_angular_velocity(_angular_velocity)
		new_ball.set_applied_force(_applied_forces)
