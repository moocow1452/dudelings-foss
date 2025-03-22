tool
class_name ArenaGoal
extends Area2D
# The target for the game ball. Each player has a goal to attack and a goal to defend.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

export(int, 0, 2) var defending_player: int = 0 setget set_defending_player, get_defending_player
export(bool) var _is_hoop: bool = false
export(bool) var _is_volley: bool = false
export(bool) var _is_pin: bool = false

func set_defending_player(new_value: int) -> void:
	defending_player = int(clamp(new_value, 0, 2))


func get_defending_player() -> int:
	return defending_player


func _init() -> void:
	self.add_to_group(Globals.ARENA_GOAL_GROUP)
	var _a = self.connect("body_entered", self, "_on_body_entered")


func score_goal(game_ball: GameBall) -> void:
	if !ArenaController.current_game_state_contains(ArenaController.GameState.IN_GAME):
		return
	
	if !is_instance_valid(game_ball):
		return

	var controlling_player: int = game_ball.get_controlling_player()

	if controlling_player == 0:
		return

	if defending_player != 0 && controlling_player != Globals.other_player(defending_player):
		return
	
	self._play_goal_scored_anim(game_ball)
	ArenaController.give_points(controlling_player, 1)  # Give points AFTER game ball anim is played so ball is removed from group.
	$AudioStreamPlayer.play()


func _play_goal_scored_anim(game_ball: GameBall) -> void:
	if game_ball.is_in_group(Globals.ACTIVE_GAME_BALL_GROUP):
		game_ball.remove_from_group(Globals.ACTIVE_GAME_BALL_GROUP)
	
	game_ball.get_node("Hitbox/CollisionShape2D").call_deferred("set_disabled", true)
	
	if !_is_hoop:
		game_ball.get_node("CollisionShape2D").call_deferred("set_disabled", true)
	
	if game_ball.has_node("AudioStreamPlayer2D"):
		game_ball.get_node("AudioStreamPlayer2D").queue_free()
	
	if _is_hoop:
		# var ball_timer: SceneTreeTimer = Globals.get_tree().create_timer(0.1, false)
		# var _a = ball_timer.connect("timeout", game_ball, "queue_free")
		game_ball._despawn()
	elif _is_volley:
		self._move_game_ball(game_ball, game_ball.get_global_position() + Vector2(-100.0 * self.get_scale().x, 0.0))
	elif _is_pin:
		# var ball_timer: SceneTreeTimer = Globals.get_tree().create_timer(0.1, false)
		# var _a = ball_timer.connect("timeout", game_ball, "queue_free")
		game_ball._despawn()
	else:
		self._move_game_ball(game_ball, self.get_global_position() + Vector2(-100.0 * self.get_scale().x, 0.0))


func _move_game_ball(game_ball: GameBall, move_to: Vector2) -> void:
	var move_tween: SceneTreeTween = self.create_tween()
	var _a = move_tween.tween_property(game_ball, "global_position", move_to, 0.1)
	var _b = move_tween.tween_callback(game_ball, "queue_free")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GAME_BALL_GROUP):
		self.score_goal(body)
