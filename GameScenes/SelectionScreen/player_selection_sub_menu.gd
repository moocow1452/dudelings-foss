class_name PlayerSelectonSubMenu
extends SubMenu
# A sub menu to select who is playing the game. Note: team == player for this class.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const GAME_TYPE_SUB_MENU_SCENE: PackedScene = preload("GameTypeSubMenu.tscn")

var can_select_controller: bool = true setget set_can_select_controller, get_can_select_controller

onready var _home_controller_options: Control = $Players/HomeTeam/ControllerOptions
onready var _away_controller_options: Control = $Players/AwayTeam/ControllerOptions
onready var _home_controller_choice: TextureRect = $Players/HomeTeam/ControllerChoice
onready var _away_controller_choice: TextureRect = $Players/AwayTeam/ControllerChoice
onready var _home_ai_selector: EnumSelectorElement = $Players/HomeTeam/AIEnumSelectorElement
onready var _away_ai_selector: EnumSelectorElement = $Players/AwayTeam/AIEnumSelectorElement
onready var _continue_button: ButtonElement = $ContinueButtonElement


func set_can_select_controller(new_value: bool) -> void:
	can_select_controller = new_value
	
	self._change_controller_options(1, InputController.get_player_one_control_option())
	_home_ai_selector.set_visible(!can_select_controller && self._option_is_ai(InputController.get_player_one_control_option()))
	
	self._change_controller_options(2, InputController.get_player_two_control_option())
	_away_ai_selector.set_visible(!can_select_controller && self._option_is_ai(InputController.get_player_two_control_option()))

	self._update_control_focus_for_ai_selectors()
	self._toggle_continue_button()  # Call AFTER setting arrows visible so it can find the node path.


func get_can_select_controller() -> bool:
	return can_select_controller


func _ready() -> void:
	DisplayController.show_virtual_gamepad(DisplayController.VGP_NAVIGATION_MODE)

	# Block '_process' for a second to prevent unwanted input.
	self.set_process(false)
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(0.1)
	var _z = timer.connect("timeout", self, "set_process", [true])

	# "Unasign" both players.
	InputController.set_player_one_control_option(InputController.PlayerOptions.AI_EASY)
	InputController.set_player_two_control_option(InputController.PlayerOptions.AI_EASY)

	# Call these before connecting signals to avoid triggering them.
	_home_ai_selector.set_options(DudelingAIInputs.Difficulty.keys())
	_home_ai_selector.set_value(DudelingAIInputs.Difficulty.EASY)

	_away_ai_selector.set_options(DudelingAIInputs.Difficulty.keys())
	_away_ai_selector.set_value(DudelingAIInputs.Difficulty.EASY)

	# Connect signals.
	var _a = _home_ai_selector.connect("value_changed", self, "_on_HomeAI_value_changed")
	var _b = _away_ai_selector.connect("value_changed", self, "_on_AwayAI_value_changed")
	var _c = _continue_button.connect("pressed", self, "_on_ContinueButtonElement_pressed")
	
	self.set_can_select_controller(true)
	
	update_button_context_bar()

func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		self._handle_ui_accept_input()

	if Input.is_action_just_pressed("ui_sub_menu"):
		SteamWrapper.RemotePlayTogetherSetup(true)

	self._check_for_inputs("keyboard_left_arrow", 1)
	self._check_for_inputs("controller_one_move_left", 1)
	self._check_for_inputs("controller_two_move_left", 1)
	
	self._check_for_inputs("keyboard_right_arrow", 2)
	self._check_for_inputs("controller_one_move_right", 2)
	self._check_for_inputs("controller_two_move_right", 2)


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	if can_select_controller:
		InputController.button_context_bar().show_select("NEXT" if self._two_players_selected() else "CHOOSE A.I.")
	
	InputController.button_context_bar().show_close("MAIN MENU")
	
	if(SteamWrapper.is_steam_enabled()):
		InputController.button_context_bar().show_sub_menu("INVITE")


func _menu_close_action() -> void:
	if can_select_controller:
		# Keep menu on screen durring scene transition.
		self.emit_signal("sub_menu_closed")
	else:
		self.set_can_select_controller(true)


func _team_choice(team: int) -> int:
	return (
		InputController.get_player_one_control_option() if team == 1 else
		InputController.get_player_two_control_option()
	)


func _player_option_from_input_action(input_action: String) -> int:
	return (
		InputController.PlayerOptions.CONTROLLER_ONE if input_action.find("one") != -1 else
		InputController.PlayerOptions.CONTROLLER_TWO if input_action.find("two") != -1 else
		InputController.PlayerOptions.KEYBOARD
	)


func _option_is_ai(player_option: int) -> bool:
	return player_option > InputController.PlayerOptions.CONTROLLER_TWO


func _two_players_selected() -> bool:
	return !self._option_is_ai(InputController.get_player_one_control_option()) && !self._option_is_ai(InputController.get_player_two_control_option())


func _check_for_inputs(input_action: String, team: int) -> void:
	if Input.is_action_just_pressed(input_action):
		if !can_select_controller:
			return

		var player_option: int = self._player_option_from_input_action(input_action)
		
		# Unassign choice if input is from the correct player.
		if self._team_choice(team) == player_option:
			self._change_team_choice(team, InputController.PlayerOptions.AI_EASY)
			AudioController.play_ui_sound(ButtonElement.DISABLED_SOUND)
		# Assign choice if allowed.
		elif self._team_choice(team) > InputController.PlayerOptions.CONTROLLER_TWO:
			self._change_team_choice(team, player_option)
			AudioController.play_ui_sound(ButtonElement.PRESSED_SOUND)
			InputController.vibrate_controller(team, 0.0, 1.0, 0.3)


func _change_team_choice(team: int, player_option: int) -> void:
	# Change old choice to A.I. if switching from one team to the other. Only allowed if new team is NOT assigned to a player.
	if !self._option_is_ai(player_option) && self._team_choice(Globals.other_player(team)) == player_option:
		self._change_team_choice(Globals.other_player(team), InputController.PlayerOptions.AI_EASY)

	if team == 1:
		InputController.set_player_one_control_option(player_option)
	elif team == 2:
		InputController.set_player_two_control_option(player_option)

	self._change_controller_options(team, player_option)
	self._toggle_continue_button()


func _change_controller_options(team: int, player_option: int) -> void:
	var rect_y_pos = (
		150.0 if InputController.guess_controller_type(InputController.controller_index(team)) == InputController.ControllerType.XBOX else
		450.0 if InputController.guess_controller_type(InputController.controller_index(team)) == InputController.ControllerType.PLAYSTATION else
		0.0
	)
	if team == 1:
		if !self._option_is_ai(player_option):
			_home_controller_choice.get_texture().set_region(Rect2(0.0, rect_y_pos, 150.0, 150.0))

		_home_controller_options.set_visible(self._option_is_ai(player_option) && can_select_controller)
		_home_controller_choice.set_visible(!self._option_is_ai(player_option))
	if team == 2:
		if !self._option_is_ai(player_option):
			_away_controller_choice.get_texture().set_region(Rect2(0.0, rect_y_pos, 150.0, 150.0))

		_away_controller_options.set_visible(self._option_is_ai(player_option) && can_select_controller)
		_away_controller_choice.set_visible(!self._option_is_ai(player_option))


func _update_control_focus_for_ai_selectors() -> void:
	if _home_ai_selector.is_visible_in_tree():
		_home_ai_selector.get_node("RightSelectorArrowElement").focus_neighbour_right = (
			_away_ai_selector.get_node("LeftSelectorArrowElement").get_path() if _away_ai_selector.is_visible_in_tree() else
			_home_ai_selector.get_node("RightSelectorArrowElement").get_path()
		)
		_home_ai_selector.get_node("RightSelectorArrowElement").focus_next = (
			_away_ai_selector.get_node("LeftSelectorArrowElement").get_path() if _away_ai_selector.is_visible_in_tree() else
			_continue_button.get_path()
		)

	if _away_ai_selector.is_visible_in_tree():
		_away_ai_selector.get_node("LeftSelectorArrowElement").focus_neighbour_left = (
			_home_ai_selector.get_node("RightSelectorArrowElement").get_path() if _home_ai_selector.is_visible_in_tree() else
			_away_ai_selector.get_node("LeftSelectorArrowElement").get_path()
		)
		_away_ai_selector.get_node("LeftSelectorArrowElement").focus_previous = (
			_home_ai_selector.get_node("RightSelectorArrowElement").get_path() if _home_ai_selector.is_visible_in_tree() else
			_away_ai_selector.get_node("LeftSelectorArrowElement").get_path()
		)
	
	if _home_ai_selector.is_visible_in_tree():
		_home_ai_selector.get_node("RightSelectorArrowElement").call_deferred("grab_focus")
	elif _away_ai_selector.is_visible_in_tree():
		_away_ai_selector.get_node("RightSelectorArrowElement").call_deferred("grab_focus")


func _toggle_continue_button() -> void:
	_continue_button.set_visible(!can_select_controller || self._two_players_selected())

	_continue_button.focus_neighbour_top = (
		_home_ai_selector.get_node("RightSelectorArrowElement").get_path() if _home_ai_selector.is_visible_in_tree() else
		_away_ai_selector.get_node("LeftSelectorArrowElement").get_path() if _away_ai_selector.is_visible_in_tree() else
		_continue_button.get_path()
	)
	_continue_button.focus_previous = (
		_away_ai_selector.get_node("RightSelectorArrowElement").get_path() if _away_ai_selector.is_visible_in_tree() else
		_home_ai_selector.get_node("RightSelectorArrowElement").get_path() if _home_ai_selector.is_visible_in_tree() else
		_continue_button.get_path()
	)

	if _continue_button.is_visible_in_tree() && !_home_ai_selector.is_visible_in_tree() && !_away_ai_selector.is_visible_in_tree():
		_continue_button.call_deferred("grab_focus")
	else:
		self.update_button_context_bar()


func _handle_ui_accept_input() -> void:
	if !can_select_controller:
		return

	if self._two_players_selected():
		self._open_game_type_sub_menu()
		return
	
	self.set_can_select_controller(false)


func _open_game_type_sub_menu() -> void:
	var sub_menu: GameTypeSubMenu = GAME_TYPE_SUB_MENU_SCENE.instance()
	self.get_parent().add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "show")
	
	self.hide()


## Button Actions.

func _on_HomeAI_value_changed(value: int) -> void:
	InputController.set_player_one_control_option(value + InputController.PlayerOptions.AI_EASY)  # Skip over player choices.


func _on_AwayAI_value_changed(value: int) -> void:
	InputController.set_player_two_control_option(value + InputController.PlayerOptions.AI_EASY)  # Skip over player choices.


func _on_ContinueButtonElement_pressed() -> void:
	self._open_game_type_sub_menu()
