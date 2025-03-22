class_name OffensiveAI
extends DudelingAIInputs
# AI that will try to score goals.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _init(target_player: int, trarget_difficulty: int) -> void:
	_controlling_player = target_player
	_ai_difficulty = trarget_difficulty
	_defend_goal_threshold = 200.0
	_ai_type = "Offensive"  # FOR DEBUGGING.
	_update_defend_threshold()


func _do_stuff() -> void:
	if self._check_if_dudeling_stunned():
		return

	if self._check_hitting_ball():
		return

	if self._check_punching():
		return

	if ArenaController.get_current_game_field_index() != ArenaController.GameField.HOOP_GAME_FIELD:
		if self._check_defending():
			return
	
	if self._check_moving():
		return
