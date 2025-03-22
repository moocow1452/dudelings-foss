tool
class_name GameBallSpawningArea
extends Node2D
# Area to randomly spawn game balls.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal ball_spawned(game_ball)

const TIME_BETWEEN_GOALS: float = 1.0
const GAME_BALL_SCENES: Array = [  # Indexing must match 'GameBall.GameBallType' NOT including "RANDOM_BALL".
	preload("../BasicBall/BasicBall.tscn"),
	preload("../BeachBall/BeachBall.tscn"),
	preload("../BowlingBall/BowlingBall.tscn"),
	preload("../BalloonBall/BalloonBall.tscn"),
]


func _init() -> void:
	self.add_to_group(Globals.GAME_BALL_SPAWNER_GROUP)


func _ready() -> void:
	if !Engine.editor_hint:
		var _a = ArenaController.connect("game_started", self, "_on_game_started")
		var _b = ArenaController.connect("player_scored", self, "_on_goal_scored")

		$PlayerOneSpawnArea.set_frame_color(Color(0.0, 0.0, 0.0, 0.0))
		$PlayerTwoSpawnArea.set_frame_color(Color(0.0, 0.0, 0.0, 0.0))

		self._start_check_balls_in_bounds_timer()


func get_game_balls() -> Array:
	return self.get_tree().get_nodes_in_group(Globals.ACTIVE_GAME_BALL_GROUP)


func game_ball_count() -> int:
	return self.get_game_balls().size()


func all_game_balls_are_tiny() -> bool:
	for game_ball in self.get_game_balls():
		if game_ball.get_game_ball_size() != GameBall.GameBallSize.SMALL:
			return false
	
	return true


func all_game_balls_are_huge() -> bool:
	for game_ball in self.get_game_balls():
		if game_ball.get_game_ball_size() != GameBall.GameBallSize.LARGE:
			return false
	return true


func spawn_game_ball(spawn_area: int = -1, game_ball_type: int = GameplayController.get_base_game_ball_type(), game_ball_size: int = GameplayController.get_base_game_ball_size(), spawn_position: Vector2 = Vector2(-9999.9, -9999.9)) -> GameBall:
	if ArenaController.current_game_state_contains(ArenaController.GameState.GAME_OVER):
		return null

	if self.game_ball_count() > GameplayController.MAX_GAME_BALL_COUNT:
		return null

	var new_ball_type: int = (
		game_ball_type if game_ball_type != GameBall.GameBallType.RANDOM_BALL else
		Globals.rng.randi_range(0, GameBall.GameBallType.size() - 2)  # -2 to take out "RANDOM_BALL".
	)
	var new_ball_size: int = (
		game_ball_size if game_ball_size != GameBall.GameBallSize.RANDOM else
		Globals.rng.randi_range(0, GameBall.GameBallSize.size() - 2)  # -2 to take out "RANDOM".
	)
	var game_ball: GameBall = GAME_BALL_SCENES[new_ball_type].instance()
	game_ball.set_game_ball_size(new_ball_size)
	$GameBalls.add_child(game_ball)

	var target_position: Vector2 = self._choose_spawn_position(spawn_area) if spawn_position == Vector2(-9999.9, -9999.9) else spawn_position
	game_ball.set_global_position(target_position)

	self.emit_signal("ball_spawned", game_ball)

	return game_ball


func _choose_spawn_position(spawn_area: int) -> Vector2:
	var target_spawn_area: ColorRect = (
		$PlayerOneSpawnArea if spawn_area == 1 else
		$PlayerTwoSpawnArea if spawn_area == 2 else
		$PlayerOneSpawnArea if Globals.rng.randf() <= 0.5 else
		$PlayerTwoSpawnArea
	)

	var pos_x: float = Globals.rng.randf_range(target_spawn_area.get_global_rect().position.x, target_spawn_area.get_global_rect().end.x)
	var pos_y: float = Globals.rng.randf_range(target_spawn_area.get_global_rect().position.y, target_spawn_area.get_global_rect().end.y)
	
	return Vector2(pos_x, pos_y)


func _on_game_started() -> void:
	self._game_started_ball_spawn()


func _game_started_ball_spawn() -> void:
	while self.game_ball_count() < GameplayController.get_min_game_balls():
		var _a = self.spawn_game_ball()


func _on_goal_scored(scoring_player: int) -> void:
	if self.game_ball_count() < GameplayController.get_min_game_balls():
		var wait_timer: SceneTreeTimer = Globals.get_tree().create_timer(TIME_BETWEEN_GOALS, false)
		var next_spawn_area: int = (
			Globals.other_player(scoring_player) if ArenaController.get_current_game_field_index() == ArenaController.GameField.VOLLEY_GAME_FIELD else
			-1
		)
		var _a = wait_timer.connect("timeout", self, "spawn_game_ball", [next_spawn_area])


func _start_check_balls_in_bounds_timer() -> void:
	var timer := Timer.new()
	self.add_child(timer)
	timer.set_pause_mode(PAUSE_MODE_STOP)
	var _a = timer.connect("timeout", self, "_check_balls_in_bounds")
	timer.start(3.0)


func _check_balls_in_bounds() -> void:
	for game_ball in self.get_game_balls():
		if game_ball.get_global_position().x < 0.0:
			game_ball.global_position.x = game_ball.game_ball_radius()
		
		if game_ball.get_global_position().x > 1280.0:
			game_ball.global_position.x = 1280.0 - game_ball.game_ball_radius()
		
		if game_ball.get_global_position().y < 0.0:
			game_ball.global_position.y = game_ball.game_ball_radius()
		
		if game_ball.get_global_position().y > 640.0:  # Arena ground is at 640.0
			game_ball.global_position.y = 640.0 - game_ball.game_ball_radius()
