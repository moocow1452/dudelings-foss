class_name DudelingPlayerInputs
extends Node
# Abstract class for players to control dudelings.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const MOVE_WAIT_TIME: float = 0.2

var _press_timer: Timer = self._make_press_timer()
var _controlling_player: int = 0
var _move_left: String = ""
var _move_right: String = ""
var _snap_left: String = ""
var _snap_right: String = ""
var _jump: String = ""
var _dash: String = ""
var _punch_left: String = ""
var _punch_right: String = ""


# Virtual method.
func _inputs() -> void:
	pass


func _init() -> void:
	var _a = ArenaController.dudeling_row().connect("action_denied", self, "_on_action_denied")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if ArenaController.current_game_state_contains(ArenaController.GameState.GAME_PAUSED | ArenaController.GameState.GAME_OVER):
		return

	self._check_movement(_move_left, Globals.LEFT)
	
	self._check_movement(_move_right, Globals.RIGHT)

	if Input.is_action_just_pressed(_snap_left):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().snap_player(_controlling_player, Globals.LEFT)
		self._stop_moving()
	
	if Input.is_action_just_pressed(_snap_right):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().snap_player(_controlling_player, Globals.RIGHT)
		self._stop_moving()

	if Input.is_action_just_pressed(_jump):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().start_player_jump(_controlling_player)
		self._stop_moving()
	elif Input.is_action_just_released(_jump):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().stop_player_jump(_controlling_player)
		self._stop_moving()

	if Input.is_action_just_pressed(_dash):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().start_player_dash(_controlling_player)
		self._stop_moving()

	if Input.is_action_just_pressed(_punch_left):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().player_punch(_controlling_player, Globals.LEFT)
		self._stop_moving()
	
	if Input.is_action_just_pressed(_punch_right):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().player_punch(_controlling_player, Globals.RIGHT)
		self._stop_moving()


func _check_movement(action: String, direction: int) -> void:
	if Input.is_action_just_pressed(action):
		Globals.get_tree().set_input_as_handled()
		ArenaController.dudeling_row().move_player(_controlling_player, direction)
		if _press_timer.is_stopped():
			_press_timer.start(MOVE_WAIT_TIME)
	elif Input.is_action_pressed(action):
		if _press_timer.is_stopped():
			ArenaController.dudeling_row().move_player(_controlling_player, direction)
	elif Input.is_action_just_released(action):
		if !Input.is_action_pressed(_move_left if action == _move_right else _move_right):
			_press_timer.stop()


func _stop_moving() -> void:
	Input.action_release(_move_left)
	Input.action_release(_move_right)


func _on_action_denied(target_player: int) -> void:
	if target_player != _controlling_player:
		return

	if Input.is_action_pressed(_move_left):
		Input.action_release(_move_left)

	if Input.is_action_pressed(_move_right):
		Input.action_release(_move_right)


func _make_press_timer() -> Timer:
	var press_timer := Timer.new()
	self.add_child(press_timer)
	press_timer.set_pause_mode(PAUSE_MODE_STOP)
	press_timer.set_one_shot(true)
	return press_timer
