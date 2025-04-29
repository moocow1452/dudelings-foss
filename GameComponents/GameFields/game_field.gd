class_name GameField
extends Node2D
# This script gets attached to a game field scene and controls the flow of the game. All the
# node references need to be added into the target scene by hand.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

func _init() -> void:
	self.add_to_group(Globals.GAME_FIELD_GROUP)


func _ready() -> void:
	# Player one inputs.
	instantiate_player_controls(InputController.get_player_one_control_option(), 1)
	instantiate_player_controls(InputController.get_player_two_control_option(), 2)
	var _a = ArenaController.connect("bg_opacity_update", self, "_on_bg_opacity_update")
	_on_bg_opacity_update(0.0)

func _on_bg_opacity_update(value):
	$ColorRect.color.a = value

func instantiate_player_controls(controller_type: int, player_int: int) -> void:
	match controller_type:
		InputController.PlayerOptions.KEYBOARD:
			var keyboard_inputs := DudelingKeyboardInputs.new(player_int)
			self.add_child(keyboard_inputs)
		InputController.PlayerOptions.CONTROLLER_ONE, InputController.PlayerOptions.CONTROLLER_TWO:
			var controller_inputs := DudelingControllerInputs.new(player_int)
			self.add_child(controller_inputs)
		InputController.PlayerOptions.AI_EASY:
			var ai_inputs: Node = self._choose_ai_type(player_int, DudelingAIInputs.Difficulty.EASY)
			self.add_child(ai_inputs)
		InputController.PlayerOptions.AI_MEDIUM:
			var ai_inputs: Node = self._choose_ai_type(player_int, DudelingAIInputs.Difficulty.MEDIUM)
			self.add_child(ai_inputs)
		InputController.PlayerOptions.AI_HARD:
			var ai_inputs: Node = self._choose_ai_type(player_int, DudelingAIInputs.Difficulty.HARD)
			self.add_child(ai_inputs)
		InputController.PlayerOptions.AI_IMPOSSIBLE:
			var ai_inputs: Node = self._choose_ai_type(player_int, DudelingAIInputs.Difficulty.IMPOSSIBLE)
			self.add_child(ai_inputs)

func _choose_ai_type(player_number: int, ai_difficulty: int) -> Node:
	if Globals.rng.randf() <= 0.05 && !ArenaController.get_current_game_field_index() == ArenaController.GameField.VOLLEY_GAME_FIELD:
		return AggressiveAI.new(player_number, ai_difficulty)
	elif Globals.rng.randf() <= 0.33:
		return OffensiveAI.new(player_number, ai_difficulty)
	elif Globals.rng.randf() <= 0.33:
		return DefensiveAI.new(player_number, ai_difficulty)

	return BalancedAI.new(player_number, ai_difficulty)

func get_game_rules() -> Dictionary:
	return GameplayController.rule_defaults
