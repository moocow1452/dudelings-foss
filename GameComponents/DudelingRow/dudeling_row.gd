class_name DudelingRow
extends Node2D
# The collection of all playable dudelings in the current arena.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal dash_triggered(target_player)
signal stamina_changed(target_player, old_value, new_value)
signal highlight_visibility_changed(target_player, highlight_visible)
signal action_denied(target_player)
signal punch_thrown(thrower, receiver, is_reciever_other_team)

const MIN_MOVE_TIME: float = 0.1
const MIN_JUMP_TIME: float = 0.3
const TOTAL_STAMINA: int = 3
const DASH_STAMINA_USE: int = 2  # Must be less than 'TOTAL_STAMINA'.
const PUNCH_STAMINA_USE: int = 1  # Must be less than 'TOTAL_STAMINA'.
const PUNCH_STAMINA_DRAIN: int = 2  # Amount removed form other player.
const PUNCH_STUN_DUDELING_TIME: float = 10.0
const PUNCH_STUN_PLAYER_TIME: float = 2.0  # Must be lower than dudeling stun time.
const STAMINA_CHARGE_TIME: float = 3.0
const GOAL_CELEBRATION_TIME: float = 3.0
const DUDELING_SCENE: PackedScene = preload("../Dudelings/Dudeling.tscn")
const ACTION_DENIED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/DudelingRow/audio/action_denied.ogg")

export(bool) var _remove_center_dudeling: bool = false

var _player_one_dudeling: Dudeling = null
var _player_two_dudeling: Dudeling = null
var _player_one_stamina: int = TOTAL_STAMINA
var _player_two_stamina: int = TOTAL_STAMINA
var _player_one_highlight_timer: Timer = self._make_highlight_timer(1)
var _player_two_highlight_timer: Timer = self._make_highlight_timer(2)
var _player_one_stun_timer: Timer = self._make_stun_timer()
var _player_two_stun_timer: Timer = self._make_stun_timer()
var _player_one_move_timer: Timer = self._make_move_timer()
var _player_two_move_timer: Timer = self._make_move_timer()
var _player_one_jump_timer: Timer = self._make_jump_timer()
var _player_two_jump_timer: Timer = self._make_jump_timer()
var _player_one_punch_timer: Timer = self._make_punch_timer()
var _player_two_punch_timer: Timer = self._make_punch_timer()
var _player_one_stamina_timer: Timer = self._make_stamina_timer(1)
var _player_two_stamina_timer: Timer = self._make_stamina_timer(2)

onready var player_one_min_index: int = Globals.min_dudeling_index()  # Inclusive.
onready var player_one_max_index: int = Globals.center_dudeling_index() - 1 if _remove_center_dudeling else Globals.max_dudeling_index()  # Inclusive.
onready var player_two_min_index: int = Globals.center_dudeling_index() if _remove_center_dudeling else Globals.min_dudeling_index()  # Inclusive.
onready var player_two_max_index: int = Globals.max_dudeling_index()  # Inclusive.


func _init() -> void:
	self.add_to_group(Globals.DUDELING_ROW_GROUP)
	var _a = ArenaController.connect("player_scored", self, "_on_goal_scored")


func _ready() -> void:
	self._instance_dudelings()
	self._setup_players()


func _instance_dudelings() -> void:
	for i in $DudelingPositions.get_child_count():
		if i == Globals.center_dudeling_index() && _remove_center_dudeling:
			continue

		var dudeling: Dudeling = DUDELING_SCENE.instance()
		$DudelingContainer.add_child(dudeling)
		dudeling.set_global_position($DudelingPositions.get_child(i).get_global_position())


func _setup_players() -> void:
	self._change_player_dudeling(1, $DudelingContainer.get_child(player_one_min_index))
	self._change_player_dudeling(2, $DudelingContainer.get_child(player_two_max_index))
	self.show_dudeling_highlight(1)
	self.show_dudeling_highlight(2)


func _make_stun_timer() -> Timer:
	var stun_timer := Timer.new()
	self.add_child(stun_timer)
	stun_timer.set_pause_mode(PAUSE_MODE_STOP)
	stun_timer.set_one_shot(true)
	return stun_timer


func _make_highlight_timer(target_player: int) -> Timer:
	var highlight_timer := Timer.new()
	self.add_child(highlight_timer)
	highlight_timer.set_pause_mode(PAUSE_MODE_STOP)
	highlight_timer.set_one_shot(true)
	var _a = highlight_timer.connect("timeout", self, "show_dudeling_highlight", [target_player])
	return highlight_timer


func _make_move_timer() -> Timer:
	var move_timer := Timer.new()
	self.add_child(move_timer)
	move_timer.set_pause_mode(PAUSE_MODE_STOP)
	move_timer.set_one_shot(true)
	return move_timer


func _make_jump_timer() -> Timer:
	var jump_timer := Timer.new()
	self.add_child(jump_timer)
	jump_timer.set_pause_mode(PAUSE_MODE_STOP)
	jump_timer.set_one_shot(true)
	return jump_timer


func _make_punch_timer() -> Timer:
	var punch_timer := Timer.new()
	self.add_child(punch_timer)
	punch_timer.set_pause_mode(PAUSE_MODE_STOP)
	punch_timer.set_one_shot(true)
	return punch_timer


func _make_stamina_timer(target_player: int) -> Timer:
	var stamina_timer := Timer.new()
	self.add_child(stamina_timer)
	stamina_timer.set_pause_mode(PAUSE_MODE_STOP)
	var _a = stamina_timer.connect("timeout", self, "_on_stamina_timer_timeout", [target_player])
	return stamina_timer


## Helpers.

func min_player_index(target_player: int) -> int:
	if(target_player == 1): return player_one_min_index
	if(target_player == 2): return player_two_min_index
	return -1;
	# return (
	# 	player_one_min_index if target_player == 1 else
	# 	player_two_min_index if target_player == 2 else
	# 	-1
	# )


func max_player_index(target_player: int) -> int:
	if(target_player == 1): return player_one_max_index
	if(target_player == 2): return player_two_max_index
	return -1;
	# return (
	# 	player_one_max_index if target_player == 1 else
	# 	player_two_max_index if target_player == 2 else
	# 	-1
	# )


func min_player_dudeling(target_player: int) -> Dudeling:
	return self.dudeling_at_index(self.min_player_index(target_player))


func max_player_dudeling(target_player: int) -> Dudeling:
	return self.dudeling_at_index(self.max_player_index(target_player))


func player_dudeling(target_player: int) -> Dudeling:
	return (
		_player_one_dudeling if target_player == 1 else
		_player_two_dudeling if target_player == 2 else
		null
	)


func other_dudeling(target_player: int) -> Dudeling:
	return (
		_player_two_dudeling if target_player == 1 else
		_player_one_dudeling if target_player == 2 else
		null
	)


func dudeling_at_index(row_index: int) -> Dudeling:
	if row_index < 0 || row_index > $DudelingContainer.get_child_count() - 1:
		return null

	return $DudelingContainer.get_child(row_index) as Dudeling



func player_stamina(target_player: int) -> int:
	return (
		_player_one_stamina if target_player == 1 else
		_player_two_stamina if target_player == 2 else
		0
	)


func player_is_highlighted(target_player: int) -> bool:
	return (
		_player_one_highlight_timer.is_stopped() if target_player == 1 else
		_player_two_highlight_timer.is_stopped() if target_player == 2 else
		false
	)


func player_is_stunned(target_player: int) -> bool:
	return (
		!_player_one_stun_timer.is_stopped() if target_player == 1 else
		!_player_two_stun_timer.is_stopped() if target_player == 2 else
		false
	)


func player_can_move(target_player: int) -> bool:
	return self._player_can_move(target_player) == 1


# -1 == false | 0 == false WITH '_action_denied' | 1 == true
func _player_can_move(target_player: int) -> int:
	return (
		0 if self.player_is_stunned(target_player) else
		-1 if self.player_dudeling(target_player).is_dashing() else
		1 if _player_one_move_timer.is_stopped() && target_player == 1 else
		-1 if !_player_one_move_timer.is_stopped() && target_player == 1 else
		1 if _player_two_move_timer.is_stopped() && target_player == 2 else
		-1 if !_player_two_move_timer.is_stopped() && target_player == 2 else
		-1
	)


func player_can_snap(target_player: int) -> bool:
	return self._player_can_snap(target_player) == 1


# -1 == false | 0 == false WITH '_action_denied' | 1 == true
func _player_can_snap(target_player: int) -> int:
	return (
		0 if self.player_dudeling(target_player).is_stunned() else
		1
	)


func player_can_jump(target_player: int) -> bool:
	return self._player_can_jump(target_player) == 1

const ACTION_FALSE = -1;
const ACTION_DENIED = 0;
const ACTION_TRUE = 1;

# -1 == false | 0 == false WITH '_action_denied' | 1 == true
func _player_can_jump(target_player: int) -> int:
	if(self.player_dudeling(target_player).is_stunned()):
		return ACTION_DENIED
	
	if(!self.player_dudeling(target_player).can_jump()):
		return ACTION_FALSE
	
	if(_player_one_jump_timer.is_stopped() && target_player == 1):
		return ACTION_TRUE
	
	if(!_player_one_jump_timer.is_stopped() && target_player == 1):
		return ACTION_FALSE
	
	
	
	return (
		0 if self.player_dudeling(target_player).is_stunned() else  # Handle stuned seperate from 'can_jump'.
		-1 if !self.player_dudeling(target_player).can_jump() else
		1 if _player_one_jump_timer.is_stopped() && target_player == 1 else
		-1 if !_player_one_jump_timer.is_stopped() && target_player == 1 else
		1 if _player_two_jump_timer.is_stopped() && target_player == 2 else
		-1 if !_player_two_jump_timer.is_stopped() && target_player == 2 else
		-1
	)


func player_can_dash(target_player: int) -> bool:
	return self._player_can_dash(target_player) == 1


# -1 == false | 0 == false WITH '_action_denied' | 1 == true
func _player_can_dash(target_player: int) -> int:
	return (
		0 if _player_one_stamina < DASH_STAMINA_USE && target_player == 1 else
		0 if _player_two_stamina < DASH_STAMINA_USE && target_player == 2 else
		self._player_can_jump(target_player)
	)


func player_can_punch(target_player: int) -> bool:
	return self._player_can_punch(target_player) == 1


# -1 == false | 0 == false WITH '_action_denied' | 1 == true
func _player_can_punch(target_player) -> int:
	if ArenaController.get_current_game_field_index() == ArenaController.GameField.VOLLEY_GAME_FIELD:
		return -1

	if self.player_dudeling(target_player).is_stunned():
		return 0

	if target_player == 1:
		if !_player_one_punch_timer.is_stopped():
			return -1
		elif _player_one_stamina < PUNCH_STAMINA_USE:
			return 0
		else:
			return 1
	elif target_player == 2:
		if !_player_two_punch_timer.is_stopped():
			return -1
		elif _player_two_stamina < PUNCH_STAMINA_USE:
			return 0
		else:
			return 1
	
	return -1


## Actions.

func change_stamina(target_player: int, new_value: int) -> void:
	if target_player == 1:
		var old_value: int = _player_one_stamina
		_player_one_stamina = int(clamp(new_value, 0, TOTAL_STAMINA))
		
		if _player_one_stamina >= TOTAL_STAMINA:
			_player_one_stamina_timer.stop()
		elif _player_one_stamina_timer.is_stopped():
			_player_one_stamina_timer.start(STAMINA_CHARGE_TIME)
	
		self.emit_signal("stamina_changed", 1, old_value, _player_one_stamina)
	elif target_player == 2:
		var old_value: int = _player_two_stamina
		_player_two_stamina = int(clamp(new_value, 0, TOTAL_STAMINA))
		
		if _player_two_stamina >= TOTAL_STAMINA:
			_player_two_stamina_timer.stop()
		elif _player_two_stamina_timer.is_stopped():
			_player_two_stamina_timer.start(STAMINA_CHARGE_TIME)
		
		self.emit_signal("stamina_changed", 2, old_value, _player_two_stamina)


func hide_dudeling_highlight(target_player: int, hide_time: float) -> void:
	if target_player == 1:
		_player_one_highlight_timer.start(hide_time)
	elif target_player == 2:
		_player_two_highlight_timer.start(hide_time)

	self.player_dudeling(target_player).update_highlight(false)
	self.emit_signal("highlight_visibility_changed", target_player, false)


func show_dudeling_highlight(target_player: int) -> void:
	if target_player == 1:
		_player_one_highlight_timer.stop()
	elif target_player == 2:
		_player_two_highlight_timer.stop()

	self.player_dudeling(target_player).update_highlight(true)
	self.emit_signal("highlight_visibility_changed", target_player, true)


func stun_dudeling(dudeling: Dudeling) -> void:
	if !is_instance_valid(dudeling):
		return

	dudeling.stun(PUNCH_STUN_DUDELING_TIME)


func stun_player(target_player: int) -> void:
	self.change_stamina(target_player, self.player_stamina(target_player) - PUNCH_STAMINA_DRAIN)
	
	if target_player == 1:
		_player_one_stun_timer.start(PUNCH_STUN_PLAYER_TIME)
	elif target_player == 2:
		_player_two_stun_timer.start(PUNCH_STUN_PLAYER_TIME)


func move_player(target_player: int, move_direction: int) -> void:
	match self._player_can_move(target_player):
		-1:
			return
		0:
			self._action_denied(target_player)
			return

	var current_dudeling: Dudeling = self.player_dudeling(target_player)
	var target_index: int = current_dudeling.get_index() + move_direction

	# Skip over other player.
	if target_index == self.other_dudeling(current_dudeling.get_controlling_player()).get_index():
		target_index += move_direction

	if target_index < self.min_player_index(target_player) || target_index > self.max_player_index(target_player):
		self._action_denied(target_player)
		return

	var target_dudeling: Dudeling = $DudelingContainer.get_child(target_index) as Dudeling

	if is_instance_valid(target_dudeling):
		self._change_player_dudeling(target_player, target_dudeling)
		if target_player == 1:
			_player_one_move_timer.start(MIN_MOVE_TIME)
		elif target_player == 2:
			_player_two_move_timer.start(MIN_MOVE_TIME)


func snap_player(target_player: int, direction: int) -> void:
	match self._player_can_snap(target_player):
		-1:
			return
		0:
			self._action_denied(target_player)
			return

	self.player_dudeling(target_player).snap_effect(-direction)
	
	var target_index: int = (
		self.min_player_index(target_player) if direction == Globals.LEFT else
		self.max_player_index(target_player)
	)

	# Shift in one index if snap index is occupied by other player.
	if self.other_dudeling(target_player).get_index() == target_index:
		target_index -= direction
	
	self._change_player_dudeling(target_player, self.dudeling_at_index(target_index))
	
	self.player_dudeling(target_player).shake(5.0 * direction, 0.2, 2)


func start_player_jump(target_player: int) -> void:
	match self._player_can_jump(target_player):
		-1:
			return
		0:
			self._action_denied(target_player)
			return
	
	if target_player == 1:
		self.player_dudeling(target_player).start_jump()
		_player_one_jump_timer.start(MIN_JUMP_TIME)
	elif target_player == 2:
		self.player_dudeling(target_player).start_jump()
		_player_two_jump_timer.start(MIN_JUMP_TIME)


# This will stop dash as well.
func stop_player_jump(target_player: int) -> void:
	self.player_dudeling(target_player).stop_jump()


func start_player_dash(target_player: int) -> void:
	match self._player_can_dash(target_player):
		-1:
			return
		0:
			self._action_denied(target_player)
			return
	
	self.player_dudeling(target_player).start_dash()
	self.change_stamina(target_player, self.player_stamina(target_player) - DASH_STAMINA_USE)
	self.emit_signal("dash_triggered", target_player)


func stop_player_dash(target_player: int) -> void:
	self.player_dudeling(target_player).stop_dash()


func player_punch(player: int, direction: int) -> void:
	match self._player_can_punch(player):
		-1:
			return
		0:
			self._action_denied(player)
			return
	
	var target_dudeling: Dudeling = self.player_dudeling(player).punch(direction)
	self.change_stamina(player, self.player_stamina(player) - PUNCH_STAMINA_USE)
	
	# Lock player movement while punching.
	if player == 1:
		_player_one_move_timer.start(DudelingFist.punch_time())
		_player_one_punch_timer.start(DudelingFist.punch_time())
	elif player == 2:
		_player_two_move_timer.start(DudelingFist.punch_time())
		_player_two_punch_timer.start(DudelingFist.punch_time())
	
	if is_instance_valid(target_dudeling):
		if target_dudeling == self.other_dudeling(player):
			self.stun_player(Globals.other_player(player))
		
		self.stun_dudeling(target_dudeling)
		target_dudeling.tilt(direction, 5.0, 0.4)
		emit_signal("punch_thrown", player, target_dudeling, target_dudeling == self.other_dudeling(player))



func _action_denied(player: int) -> void:
	var start_direction: int = (
		Globals.LEFT if self.player_dudeling(player).get_index() < self.max_player_index(player) / 2.0 else
		Globals.RIGHT
	)
	self.player_dudeling(player).shake(5.0 * start_direction, 0.1, 3)
	InputController.pulse_controller(player, 0.5, 0.0, 0.1, 0.1, 3, false)
	AudioController.play_game_sound(ACTION_DENIED_SOUND, player)
	self.emit_signal("action_denied", player)


func _change_player_dudeling(target_player: int, target_dudeling: Dudeling) -> void:
	if is_instance_valid(self.player_dudeling(target_player)):
		self.player_dudeling(target_player).remove_player_control()

	if target_player == 1:
		_player_one_dudeling = target_dudeling
		_player_one_dudeling.give_player_control(target_player)
	else:
		_player_two_dudeling = target_dudeling
		_player_two_dudeling.give_player_control(target_player)


func _on_goal_scored(scoring_player: int) -> void:
	for i in range(self.min_player_index(scoring_player), self.max_player_index(scoring_player) + 1):
		if i == self.other_dudeling(scoring_player).get_index():
			continue
		
		var celebrate_time: float = (
			-1.0 if ArenaController.player_score(scoring_player) == GameplayController.get_points_to_win() else
			GOAL_CELEBRATION_TIME
		)
		$DudelingContainer.get_child(i).celebrate(celebrate_time)


func _on_stamina_timer_timeout(target_player: int) -> void:
	self.change_stamina(target_player, self.player_stamina(target_player) + 1)
