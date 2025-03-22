class_name GamePausedMenu
extends BaseMenu
# A basic pause menu for in game. The game is automaticaly paused/unpaused when the menu is opened or closed.
#
# @author gbryant
# @copyright 2024 Heavy Element

const CONFIRM_MESSAGE_SCENE: PackedScene = preload("../SubMenus/ConfirmMessage/ConfirmMessage.tscn")

onready var gameplay_choices := $GameplayChoices
onready var pickup_container := $PickupContainer

func _init() -> void:
	ArenaController.set_game_paused(true)


func _ready() -> void:
	DisplayController.hide_virtual_gamepad()
	var _a = $ButtonElements/ContinueButtonElement.connect("pressed", self, "_on_ContinueButtonElement_pressed")
	var _b = $ButtonElements/HowToPlayButtonElement.connect("pressed", self, "_on_HowToPlayButtonElement_pressed")
	var _c = $ButtonElements/SettingsButtonElement.connect("pressed", self, "_on_SettingsButtonElement_pressed")
	var _d = $ButtonElements/LeaveMatchButtonElement.connect("pressed", self, "_on_LeaveMatchButtonElement_pressed")

	self._update_gampelay_choices()
	self._updated_pickup_choices()

	if(DisplayController.pause_menu_choices):
		gameplay_choices.visible = DisplayController.pause_menu_choices
		pickup_container.visible = DisplayController.pause_menu_choices

	$ButtonElements/ContinueButtonElement.call_deferred("grab_focus")


func queue_free() -> void:
	# Timer to prevent Dudelings from registering a jump.
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(0.1)
	var _a = timer.connect("timeout", self, "_queue_free")


func _queue_free() -> void:
	ArenaController.set_game_paused(false)
	DisplayController.show_virtual_gamepad(DisplayController.VGP_CONTROLLER_MODE)
	.queue_free()


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	if Input.is_action_just_pressed("ui_cancel") || Input.is_action_just_pressed("ui_pause_menu"):
		self.queue_free()
	
	InputController.button_context_bar().show_sub_menu("MATCH INFO")

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_sub_menu"):
		toggle_gameplay_choices(true)


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_close("RETURN TO GAME")


func _update_gampelay_choices() -> void:
	if GameplayController.gametype == GameplayController.Gametypes.TIMED_MATCH: 
		$GameplayChoices/MenuContainer/PointsHeader.text = "TIME LIMIT"
		var min_str: int = int(floor(GameplayController.time_limit / 60.0)) % 100
		var sec_str: String = str(GameplayController.time_limit % 60).pad_zeros(2)
		$GameplayChoices/MenuContainer/Points.set_text(str(min_str) + ":" + sec_str)
	else:
		$GameplayChoices/MenuContainer/PointsHeader.text = "MATCH POINTS"
		$GameplayChoices/MenuContainer/Points.set_text(str(GameplayController.get_points_to_win()))
	
	$GameplayChoices/MenuContainer/BallType.set_text(Globals.uppercase(GameBall.GameBallType.keys()[GameplayController.get_base_game_ball_type()]).replace(" BALL", ""))
	$GameplayChoices/MenuContainer/MinBalls.set_text(str(GameplayController.get_min_game_balls()))
	$GameplayChoices/MenuContainer/BallSize.set_text(Globals.uppercase(GameBall.GameBallSize.keys()[GameplayController.get_base_game_ball_size()]))
	$GameplayChoices/MenuContainer/PickupRate.set_text(Globals.uppercase(AreaPickupSpawningArea.PickupSpawnRate.keys()[GameplayController.get_arena_pickup_spawn_rate()]))
	
	match InputController.get_player_one_control_option():
		InputController.PlayerOptions.KEYBOARD:
			$GameplayChoices/MenuContainer/HomeTeam.set_text("KEYBOARD")
		InputController.PlayerOptions.CONTROLLER_ONE:
			$GameplayChoices/MenuContainer/HomeTeam.set_text(Globals.uppercase(InputController.ControllerType.keys()[InputController.guess_controller_type(0)]))
		InputController.PlayerOptions.CONTROLLER_TWO:
			$GameplayChoices/MenuContainer/HomeTeam.set_text(Globals.uppercase(InputController.ControllerType.keys()[InputController.guess_controller_type(1)]))
		_:
			$GameplayChoices/MenuContainer/HomeTeam.set_text(Globals.uppercase(InputController.PlayerOptions.keys()[InputController.get_player_one_control_option()]).replace("AI", "A.I."))
	
	match InputController.get_player_two_control_option():
		InputController.PlayerOptions.KEYBOARD:
			$GameplayChoices/MenuContainer/AwayTeam.set_text("KEYBOARD")
		InputController.PlayerOptions.CONTROLLER_ONE:
			$GameplayChoices/MenuContainer/AwayTeam.set_text(Globals.uppercase(InputController.ControllerType.keys()[InputController.guess_controller_type(0)]))
		InputController.PlayerOptions.CONTROLLER_TWO:
			$GameplayChoices/MenuContainer/AwayTeam.set_text(Globals.uppercase(InputController.ControllerType.keys()[InputController.guess_controller_type(1)]))
		_:
			$GameplayChoices/MenuContainer/AwayTeam.set_text(Globals.uppercase(InputController.PlayerOptions.keys()[InputController.get_player_two_control_option()]).replace("AI", "A.I."))


func _updated_pickup_choices() -> void:
	for each in $PickupContainer.get_children():
		each.queue_free()

	if GameplayController.get_arena_pickup_spawn_rate() == AreaPickupSpawningArea.PickupSpawnRate.NONE:
		return

	for pickup in GameplayController.get_allowed_pickups():
		var texture_rect := TextureRect.new()
		texture_rect.set_custom_minimum_size(Vector2(60.0, 60.0))
		texture_rect.set_size(Vector2(60.0, 60.0))
		texture_rect.set_expand(true)
		texture_rect.set_texture(AreaPickupSpawningArea.PICKUP_ICONS[pickup])
		$PickupContainer.add_child(texture_rect)


func _disable_button_elements(disable_buttons: bool) -> void:
	for button in $ButtonElements.get_children():
		button.call_deferred("set_disabled", disable_buttons)


func _make_leave_match_message() -> void:
	var confirm_message:= CONFIRM_MESSAGE_SCENE.instance()
	self.add_child(confirm_message)
	var _a = confirm_message.connect("confirmed", self, "_on_leave_match_message_confirmed")
	var _b = confirm_message.connect("cancled", self, "_disable_button_elements", [false])
	confirm_message.show_message("LEAVE MATCH?", "Are you sure you want to leave the match?")


func _on_leave_match_message_confirmed() -> void:
	ArenaController.leave_game()
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_OPTIONS)


## Button Actions.

func _on_ContinueButtonElement_pressed() -> void:
	self.queue_free()


func _on_HowToPlayButtonElement_pressed() -> void:
	self._disable_button_elements(true)

	var sub_menu: HowToPlaySubMenu = MainMenu.HOW_TO_PLAY_SUB_MENU_SCENE.instance()
	self.add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "_disable_button_elements", [false])


func _on_SettingsButtonElement_pressed() -> void:
	self._disable_button_elements(true)

	var sub_menu: SettingsSubMenu = MainMenu.SETTINGS_SUB_MENU_SCENE.instance()
	self.add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "_disable_button_elements", [false])


func _on_LeaveMatchButtonElement_pressed() -> void:
	self._disable_button_elements(true)
	self._make_leave_match_message()

func toggle_gameplay_choices(save = true):
	DisplayController.pause_menu_choices = !DisplayController.pause_menu_choices
	gameplay_choices.visible = DisplayController.pause_menu_choices
	pickup_container.visible = DisplayController.pause_menu_choices
	if(save): GameSettingsData.save_game_setting(GameSettingsData.DISPLAY_SECTION, "pause_menu_choices", DisplayController.pause_menu_choices)
