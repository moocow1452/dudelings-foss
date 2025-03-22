class_name DudelingAIInputs
extends Node
# This script is used to allow the computer to control the dudeling row.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	IMPOSSIBLE,
}

const DO_STUFF_SPEED: Array = [0.3, 0.2, 0.2, 0.1]  # Smallest number must be >= 'dudeling_row.MIN_MOVE_TIME'.
const SKIP_STUFF_CHANCE: Array = [0.2, 0.1, 0.01, 0.01]
const HIGHLIGHT_HIDDEN_MOVEMENT_SCALE: float = 0.33
const MOVEMENT_SKIP_CHANCE: float = 0.3

var _controlling_player: int = 0
var _ai_difficulty: int = Difficulty.EASY
var _own_goal_pos: Vector2 = Vector2()
var _opponent_goal_pos: Vector2 = Vector2()
var _dash_rate: Array = [0.07, 0.1, 0.2, 0.2]
var _punch_rate: Array = [0.01, 0.02, 0.03, 0.03]
var _defend_goal_threshold: float = 250.0  # Each dudeling is 50px wide. Start at second dudeling in for good approximation.
var _do_stuff_timer: Timer = self._make_do_stuff_timer()


func _ready() -> void:
	add_to_group(Globals.AI_PLAYERS)
	_own_goal_pos = ArenaController.find_goal_pos(_controlling_player)
	_opponent_goal_pos = ArenaController.find_goal_pos(Globals.other_player(_controlling_player))
	_do_stuff_timer.set_wait_time(DO_STUFF_SPEED[_ai_difficulty])
	
	
	## DEBUG STUFF.
	# var debug_string: String = "\n%s %s initalized...\nDefending goal at %s. Attacking goal at %s.\n" % [
	# 	Difficulty.keys()[_ai_difficulty],
	# 	self._ai_name(),
	# 	str(_own_goal_pos),str(_opponent_goal_pos),
	# ]
	# self._debug_output(debug_string, false)

# Check if the gamefield is PIN_MODE, if it is, set the _defend_goal_threshold to 0(??)
func _update_defend_threshold() ->void:
	if ArenaController.current_game_field_index == ArenaController.GameField.PIN_GAME_FIELD:
		_defend_goal_threshold = 0

func _make_do_stuff_timer() -> Timer:
	var do_stuff_timer := Timer.new()
	self.add_child(do_stuff_timer)
	do_stuff_timer.set_pause_mode(PAUSE_MODE_STOP)
	var _a = do_stuff_timer.connect("timeout", self, "_on_do_stuff_timer_timeout")
	var _b = SceneController.connect("fade_out", do_stuff_timer, "start")
	var _c = ArenaController.connect("game_ended", do_stuff_timer, "stop")
	var _d = ArenaController.dudeling_row().connect("highlight_visibility_changed", self, "_on_highlight_visibility_changed")
	return do_stuff_timer


func _on_do_stuff_timer_timeout() -> void:
	if Globals.rng.randf() <= SKIP_STUFF_CHANCE[_ai_difficulty]:
		# self._debug_output(self._ai_name() + " SKIP do stuff step.", true, true)
		return

	self._do_stuff()


func _on_highlight_visibility_changed(target_player: int, highlight_visible: bool) -> void:
	if _controlling_player != target_player:
		return

	var wait_time: float = (
		DO_STUFF_SPEED[_ai_difficulty] if highlight_visible else
		DO_STUFF_SPEED[_ai_difficulty] / HIGHLIGHT_HIDDEN_MOVEMENT_SCALE
	)

	_do_stuff_timer.set_wait_time(wait_time)


# Do stuff order of priority. Return after action is preformed to keep at propper "tick".
func _do_stuff() -> void:
	pass  # Overridden by classes that inherit from this one.


## Helper Functions.

func _player_dudeling_index(target_player: int) -> int:
	return ArenaController.dudeling_row().player_dudeling(target_player).get_index()


func _player_dudeling_pos(target_player: int) -> Vector2:
	return ArenaController.dudeling_row().player_dudeling(target_player).get_global_position()


# Applys to snaping as well.
func _can_move(target_player: int) -> bool:
	return ArenaController.dudeling_row().player_can_move(target_player)


func _can_jump(target_player: int) -> bool:
	return ArenaController.dudeling_row().player_can_jump(target_player)


func _can_dash(target_player: int) -> bool:
	return ArenaController.dudeling_row().player_can_dash(target_player)


func _can_punch(target_player: int) -> bool:
	if !ArenaController.dudeling_row().player_is_highlighted(_controlling_player):
		return false
	
	if !ArenaController.dudeling_row().player_is_highlighted(Globals.other_player(_controlling_player)):
		return false

	return ArenaController.dudeling_row().player_can_punch(target_player)


func _dudeling_is_stunned(dudeling_index: int) -> bool:
	if dudeling_index < Globals.min_dudeling_index() || dudeling_index > Globals.max_dudeling_index():
		return false
	
	return ArenaController.dudeling_row().dudeling_at_index(dudeling_index).is_stunned()


# Checks if the player is at one of the first two dudeling row indexes.
func _player_is_near_left(target_player: int) -> bool:
	var dudeling_index: int = self._player_dudeling_index(target_player)
	return dudeling_index == ArenaController.dudeling_row().min_player_index(target_player) || dudeling_index == ArenaController.dudeling_row().min_player_index(target_player) + 1


# Checks if the player is at one of the last two dudeling row indexes.
func _player_is_near_right(target_player: int) -> bool:
	var dudeling_index: int = self._player_dudeling_index(target_player)
	return dudeling_index == ArenaController.dudeling_row().max_player_index(target_player) - 1 || dudeling_index == ArenaController.dudeling_row().max_player_index(target_player)


func _other_player_directly_left() -> bool:
	return self._player_dudeling_index(_controlling_player) == self._player_dudeling_index(Globals.other_player(_controlling_player)) + 1


func _other_player_directly_right() -> bool:
	return self._player_dudeling_index(_controlling_player) == self._player_dudeling_index(Globals.other_player(_controlling_player)) - 1


func _other_player_side() -> int:
	return 1 * int(sign(self._player_dudeling_index(Globals.other_player(_controlling_player)) - self._player_dudeling_index(_controlling_player)))


func _goal_side(target_goal_pos: Vector2) -> int:
	return (
		Globals.LEFT if target_goal_pos.x < self._player_dudeling_pos(_controlling_player).x else
		Globals.RIGHT
	)


func _game_ball_side(target_game_ball: GameBall) -> int:
	if !is_instance_valid(target_game_ball):
		return 0
	
	return (
		Globals.LEFT if target_game_ball.get_global_position().x < self._player_dudeling_pos(_controlling_player).x else
		Globals.RIGHT
	)


func _is_under_ball(target_game_ball: GameBall) -> bool:
	if !is_instance_valid(target_game_ball):
		return false
	
	return ArenaController.dudeling_row().player_dudeling(_controlling_player).is_under_ball(target_game_ball)


func _can_hit_ball(game_ball: GameBall) -> bool:
	return ArenaController.dudeling_row().player_dudeling(_controlling_player).can_hit_ball(game_ball)


func _can_hit_a_ball() -> bool:
	for game_ball in ArenaController.game_ball_spawner().get_game_balls():
		if self._can_hit_ball(game_ball):
			return true

	return false


# Does not work for hoop arena. Only called when checking defending on other fields.
func _player_is_near_goal(target_player: int) -> bool:
	return (
		self._player_is_near_left(_controlling_player) if target_player == 1 else
		self._player_is_near_right(_controlling_player) if target_player == 2 else
		false
	)


func _game_balls_near_goal(target_goal_pos: Vector2) -> Array:
	var game_balls: Array = []
	for game_ball in ArenaController.game_ball_spawner().get_game_balls():
		if abs(game_ball.get_global_position().x - target_goal_pos.x) < _defend_goal_threshold:
			game_balls.append(game_ball)

	return game_balls


func _find_closest_game_ball() -> GameBall:
	var game_balls: Array = ArenaController.game_ball_spawner().get_game_balls()
	
	match game_balls.size():
		0:
			return null
		1:
			if !is_instance_valid(game_balls[0]):
				return null
			
			self._highlight_target_ball(game_balls[0])
			return game_balls[0]
		_:
			var closest_game_ball: GameBall = null
			var last_length: float = 9999.9  # Number is larger than what max length can be to allow for propper first pass.
			for game_ball in game_balls:
				if !is_instance_valid(game_ball):
					continue
				
				var target_lenght: float = (game_ball.get_global_position() - self._player_dudeling_pos(_controlling_player)).length()

				if target_lenght < last_length:
					closest_game_ball = game_ball
				
				last_length = target_lenght
			
			self._highlight_target_ball(closest_game_ball)

			return closest_game_ball


func _game_ball_is_moving_towards_goal(game_ball: GameBall, goal_pos: Vector2) -> bool:
	# Check if game ball is moving. Ignore very small movements like bouncing.
	if abs(game_ball.get_linear_velocity().x) < 0.1:
		return false
	
	var is_moving_left: bool = game_ball.get_linear_velocity().x < 0.0
	var goal_is_on_left: bool = game_ball.get_global_position().x - goal_pos.x > 0.0

	return is_moving_left == goal_is_on_left


## Do stuff checks.

func _check_if_dudeling_stunned() -> bool:
	if self._dudeling_is_stunned(self._player_dudeling_index(_controlling_player)):
		self._debug_output(self._ai_name() + " CHECK IF DUDELING STUNNED. Dudeling is stunned:", true, true)

		var target_game_ball: GameBall = self._find_closest_game_ball()
		if self._game_ball_side(target_game_ball) == Globals.LEFT:
			self._try_moving_left()
			return true
		elif self._game_ball_side(target_game_ball) == Globals.RIGHT:
			self._try_moving_right()
			return true
		elif self._player_is_near_left(_controlling_player):
			self._try_moving_right()
			return true
		elif self._player_is_near_right(_controlling_player):
			self._try_moving_left()
			return true
		elif self._goal_side(_opponent_goal_pos) == Globals.LEFT:
			self._try_moving_left()
			return true
		elif self._goal_side(_opponent_goal_pos) == Globals.RIGHT:
			self._try_moving_right()
			return true
		
	return false


func _check_defending() -> bool:
	var game_balls_near_goal: Array = self._game_balls_near_goal(_own_goal_pos)

	if game_balls_near_goal.empty():
		return false

	for game_ball in game_balls_near_goal:
		if game_ball.get_controlling_player() != Globals.other_player(_controlling_player):
			continue

		if !self._game_ball_is_moving_towards_goal(game_ball, _own_goal_pos):
			continue
		
		self._debug_output(self._ai_name() + " CHECK DEFENDING. Opponents ball is moving towards goal:", true, true)

		if self._player_is_near_goal(_controlling_player):
			self._try_jumping()
			return true
		
		if _controlling_player == 1:
			self._try_snapping_left()
			
			# Add an extra dash/jump to block ball in time on volley field.
			if ArenaController.get_current_game_field_index() == ArenaController.GameField.VOLLEY_GAME_FIELD:
				self.call_deferred("_try_jumping")  # Call deferred to allow for snapping first.

			return true
		elif _controlling_player == 2:
			self._try_snapping_right()
			
			# Add an extra dash/jump to block ball in time on volley field.
			if ArenaController.get_current_game_field_index() == ArenaController.GameField.VOLLEY_GAME_FIELD:
				self.call_deferred("_try_jumping")  # Call deferred to allow for snapping first.
			
			return true

	return false


func _check_hitting_ball() -> bool:
	if !self._can_hit_a_ball():
		return false
		
	self._debug_output(self._ai_name() + " CHECK HITTING BALL. Can hit ball:", true, true)
	
	self._try_dashing_or_jumping()
	
	return true


func _check_moving() -> bool:
	if !self._can_move(_controlling_player):
		return false

	# if _ai_difficulty > Difficulty.MEDIUM && Globals.rng.randf() <= MOVEMENT_SKIP_CHANCE:
	# 	return false

	var target_game_ball: GameBall = self._find_closest_game_ball()

	if !is_instance_valid(target_game_ball):
		if self._other_player_side() == Globals.LEFT && !self._other_player_directly_left():
			self._debug_output(self._ai_name() + " CHECK MOVING. No game ball. Move left:", true, true)
			self._try_moving_left()
			return true
		elif self._other_player_side() == Globals.RIGHT && !self._other_player_directly_right():
			self._debug_output(self._ai_name() + " CHECK MOVING. No game ball. Move right:", true, true)
			self._try_moving_right()
			return true
		
		return false

	# This will fake an action that a player does when hidden.
	if !ArenaController.dudeling_row().player_is_highlighted(_controlling_player) && Globals.rng.randf() <= 0.1:
		self._try_jumping()
		return true

	var player_distance_to_ball: float = abs(target_game_ball.get_global_position().x - self._player_dudeling_pos(_controlling_player).x)
	var snap_target_distance_to_ball: float = (
		abs(target_game_ball.get_global_position().x - ArenaController.dudeling_row().min_player_dudeling(_controlling_player).global_position.x) if self._game_ball_side(target_game_ball) == Globals.LEFT else
		abs(target_game_ball.get_global_position().x - ArenaController.dudeling_row().max_player_dudeling(_controlling_player).global_position.x)
	)

	if self._game_ball_side(target_game_ball) == Globals.LEFT:
		self._debug_output(self._ai_name() + " CHECK MOVING. Closest game ball is left:", true, true)

		if snap_target_distance_to_ball < player_distance_to_ball && !self._player_is_near_left(_controlling_player):
			self._try_snapping_left()
		else:
			self._try_moving_left()

		return true
	elif self._game_ball_side(target_game_ball) == Globals.RIGHT:
		self._debug_output(self._ai_name() + " CHECK MOVING. Closest game ball is right:", true, true)

		if snap_target_distance_to_ball < player_distance_to_ball && !self._player_is_near_right(_controlling_player):
			self._try_snapping_right()
		else:
			self._try_moving_right()

		return true
	
	return false


func _check_punching() -> bool:
	if !self._can_punch(_controlling_player):
		return false

	if Globals.rng.randf() > _punch_rate[_ai_difficulty]:
		return false
	
	# Left.
	if self._other_player_directly_left() && !self._dudeling_is_stunned(self._player_dudeling_index(_controlling_player) - 1):
		self._debug_output(self._ai_name() + " CHECK PUNCHING. Other player is directly left:", true, true)
		self._try_punching_left()
		return true

	# Right.
	if self._other_player_directly_right() && !self._dudeling_is_stunned(self._player_dudeling_index(_controlling_player) + 1):
		self._debug_output(self._ai_name() + " CHECK PUNCHING. Other player is directly right:", true, true)
		self._try_punching_right()
		return true
	
	return false


## Try actions.

func _try_moving_left() -> void:
	self._debug_output(self._ai_name() + " TRY MOVING LEFT...")

	var min_index: int =  ArenaController.dudeling_row().min_player_index(_controlling_player)
	if self._player_dudeling_index(_controlling_player) == min_index:
		return
	elif self._player_is_near_left(_controlling_player) && self._player_dudeling_index(Globals.other_player(_controlling_player)) == min_index:
		return
	
	if self._can_move(_controlling_player):
		self._move(Globals.LEFT)


func _try_moving_right() -> void:
	self._debug_output(self._ai_name() + " TRY MOVING RIGHT...")

	var max_index: int = ArenaController.dudeling_row().max_player_index(_controlling_player)
	if self._player_dudeling_index(_controlling_player) == max_index:
		return
	elif self._player_is_near_right(_controlling_player) && self._player_dudeling_index(Globals.other_player(_controlling_player)) == max_index:
		return
		
	if self._can_move(_controlling_player):
		self._move(Globals.RIGHT)


func _try_snapping_left() -> void:
	self._debug_output(self._ai_name() + " TRY SNAPPING LEFT...")

	if self._player_is_near_left(_controlling_player):
		return

	if self._can_move(_controlling_player):
		self._snap(Globals.LEFT)


func _try_snapping_right() -> void:
	self._debug_output(self._ai_name() + " TRY SNAPPING RIGHT...")

	if self._player_is_near_right(_controlling_player):
		return

	if self._can_move(_controlling_player):
		self._snap(Globals.RIGHT)


func _try_jumping() -> void:
	self._debug_output(self._ai_name() + " TRY JUMPING...")

	if ArenaController.dudeling_row().player_dudeling(_controlling_player).is_in_air():
		return
	
	if self._can_jump(_controlling_player):
		self._jump()


func _try_dashing_or_jumping() -> void:
	self._debug_output(self._ai_name() + " TRY DASHING OR JUMPING...")

	if ArenaController.dudeling_row().player_dudeling(_controlling_player).is_in_air():
		return
	
	if self._can_dash(_controlling_player) && Globals.rng.randf() <= _dash_rate[_ai_difficulty]:
		self._dash()
	elif self._can_jump(_controlling_player):
		self._jump()


func _try_punching_left() -> void:
	self._debug_output(self._ai_name() + " TRY PUNCHING LEFT...")

	if self._can_punch(_controlling_player):
		self._punch(Globals.LEFT)


func _try_punching_right() -> void:
	self._debug_output(self._ai_name() + " TRY PUNCHING RIGHT...")
	
	if self._can_punch(_controlling_player):
		self._punch(Globals.RIGHT)


## Dudeling actions.

func _move(direction: int) -> void:
	ArenaController.dudeling_row().move_player(_controlling_player, direction)
	self._debug_output(self._ai_name() + " MOVE " + ("LEFT." if direction == Globals.LEFT else "RIGHT."))


func _snap(direction: int) -> void:
	ArenaController.dudeling_row().snap_player(_controlling_player, direction)
	self._debug_output(self._ai_name() + " SNAP "+ ("LEFT." if direction == Globals.LEFT else "RIGHT."))


func _jump() -> void:
	ArenaController.dudeling_row().start_player_jump(_controlling_player)
	self._debug_output(self._ai_name() + " JUMP.")


func _dash() -> void:
	ArenaController.dudeling_row().start_player_dash(_controlling_player)
	self._debug_output(self._ai_name() + " DASH.")


func _punch(direction: int) -> void:
	ArenaController.dudeling_row().player_punch(_controlling_player, direction)
	self._debug_output(self._ai_name() + " PUNCh " + ("LEFT." if direction == Globals.LEFT else "RIGHT."))


## DEBUGGING STUFF.

var _ai_type: String = "NO TYPE"
var _target_game_ball_highlight: ColorRect = null


func _debug_output(output_text: String, include_game_time: bool = true, new_line_above: bool = false) -> void:
	if(!Globals.ai_debug_state): return
	print(
		"%s %s %s" % [
			"\n" if new_line_above else "",
			self._game_run_time_string() + " -> " if include_game_time else "",
			output_text,
		]
	)


func _game_run_time_string() -> String:
	var run_time: int = ArenaController.get_game_run_time()
	var min_str: String = str(floor(run_time / 60.0)).pad_zeros(2)
	var sec_str: String = str(run_time % 60).pad_zeros(2)
	return min_str + ":" + sec_str


func _ai_name() -> String:
	return _ai_type + " AI " + str(_controlling_player)


func _highlight_target_ball(target_game_ball: GameBall) -> void:
	if(!Globals.ai_debug_state): return

	if !is_instance_valid(target_game_ball):
		return
	
	if is_instance_valid(_target_game_ball_highlight):
		_target_game_ball_highlight.queue_free()
		_target_game_ball_highlight = null
	
	_target_game_ball_highlight = ColorRect.new()
	target_game_ball.add_child(_target_game_ball_highlight)
	_target_game_ball_highlight.set_size(Vector2(10.0, 30.0) if _controlling_player == 1 else Vector2(30.0, 10.0))
	_target_game_ball_highlight.set_position(Vector2(-5.0, -15.0) if _controlling_player == 1 else Vector2(-15.0, -5.0))
	_target_game_ball_highlight.set_frame_color(Color.blue if _controlling_player == 1 else Color.red)
