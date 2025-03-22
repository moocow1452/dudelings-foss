class_name GameOptionsSubMenu
extends SubMenu
# A sub menu for selecting gameplay options.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

onready var _gametype_option_button: OptionButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/WinCondition/OptionButtonElement
onready var _time_limit_selector: NumberSelectorElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/TimeLimit/NumberSelectorElement;
onready var _points_to_win_selector: NumberSelectorElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/MatchPoints/NumberSelectorElement
onready var _min_game_balls_selector: NumberSelectorElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/MinGameBalls/NumberSelectorElement
onready var _default_ball_option_button: OptionButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/DefaultBall/OptionButtonElement
onready var _game_ball_sizes_option_button: OptionButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/GameBallSizes/OptionButtonElement
onready var _pickup_spawn_rates_option_button: OptionButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/PickupSpawnRates/OptionButtonElement
onready var _active_pickups_menu_button: MenuButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/ActivePickups/MenuButtonElement


var _is_there_a_popup_open := false

func _ready() -> void:
	DisplayController.hide_virtual_gamepad()
	_close_action_string = "ui_cancel"

	## Call these before connecting signals to avoid triggering them.
	_points_to_win_selector.set_min_value(1)
	_points_to_win_selector.set_max_value(99)
	_min_game_balls_selector.set_min_value(1)
	_min_game_balls_selector.set_max_value(GameplayController.MAX_GAME_BALL_COUNT)
	for i in range(GameBall.GameBallType.size()):
		_default_ball_option_button.add_item(Globals.uppercase(GameBall.GameBallType.keys()[i]).replace(" BALL", ""), i)
	for i in range(GameBall.GameBallSize.size()):
		_game_ball_sizes_option_button.add_item(Globals.uppercase(GameBall.GameBallSize.keys()[i]), i)
	for i in range(AreaPickupSpawningArea.PickupSpawnRate.size()):
		_pickup_spawn_rates_option_button.add_item(Globals.uppercase(AreaPickupSpawningArea.PickupSpawnRate.keys()[i]), i)
	for i in range(ArenaPickup.PickupType.size()):
		_active_pickups_menu_button.get_popup().add_check_item(Globals.uppercase(ArenaPickup.PickupType.keys()[i]), i)
	
	_gametype_option_button.add_item("Match Point", GameplayController.Gametypes.MATCH_POINT)
	_gametype_option_button.add_item("Timed Match", GameplayController.Gametypes.TIMED_MATCH)

	self._update_menu()

	## Connect signals.
	var _z = $BackgroundPanel.connect("clicked_outside", self, "queue_free")
	
	var _a = _points_to_win_selector.connect("value_changed", self, "_on_PointsToWin_value_changed")
	var _b = _min_game_balls_selector.connect("value_changed", self, "_on_MinGameBalls_value_changed")
	var _c = _default_ball_option_button.connect("item_selected", self, "_on_GameBalls_item_selected")
	var _d = _game_ball_sizes_option_button.connect("item_selected", self, "_on_GameBallSizes_item_selected")
	var _e = _pickup_spawn_rates_option_button.connect("item_selected", self, "_on_PickupSpawnRates_item_selected")
	var _f = _active_pickups_menu_button.connect("index_pressed", self, "_on_ActivePickups_index_pressed")
	var _g = _gametype_option_button.connect("item_selected", self, "_on_Gametype_item_selected")
	var _gg = _time_limit_selector.connect("value_changed", self, "_on_TimeLimit_value_changed")
	
	var _h = _default_ball_option_button.get_popup().connect("about_to_show", self, "_on_popup_menu_open")
	var _i = _game_ball_sizes_option_button.get_popup().connect("about_to_show", self, "_on_popup_menu_open")
	var _j = _pickup_spawn_rates_option_button.get_popup().connect("about_to_show", self, "_on_popup_menu_open")
	var _k = _active_pickups_menu_button.get_popup().connect("about_to_show", self, "_on_popup_menu_open")
	var _l = _gametype_option_button.get_popup().connect("about_to_show", self, "_on_popup_menu_open")

	var _m = _default_ball_option_button.connect("focus_entered", self, "_on_parent_button_enter")
	var _n = _game_ball_sizes_option_button.connect("focus_entered", self, "_on_parent_button_enter")
	var _o = _pickup_spawn_rates_option_button.connect("focus_entered", self, "_on_parent_button_enter")
	var _p = _active_pickups_menu_button.connect("focus_entered", self, "_on_parent_button_enter")
	var _q = _gametype_option_button.connect("focus_entered", self, "_on_parent_button_enter")

	_gametype_option_button.call_deferred("grab_focus")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	if Input.is_action_just_pressed("ui_randomize"):
		Globals.get_tree().set_input_as_handled()
		self._randomize_settings()
	
	if Input.is_action_just_pressed("ui_reset"):
		Globals.get_tree().set_input_as_handled()
		self._reset_settings()


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_randomize()
	InputController.button_context_bar().show_reset()
	InputController.button_context_bar().show_sub_menu("BACK")


func _update_menu() -> void:
	_gametype_option_button.select(GameplayController.gametype)
	_on_Gametype_item_selected(GameplayController.gametype)
	_set_time_limit_display_value(GameplayController.time_limit)
	_points_to_win_selector.set_value(GameplayController.get_points_to_win())
	_min_game_balls_selector.set_value(GameplayController.get_min_game_balls())
	_default_ball_option_button.select(GameplayController.get_base_game_ball_type())
	_game_ball_sizes_option_button.select(GameplayController.get_base_game_ball_size())
	_pickup_spawn_rates_option_button.select(GameplayController.get_arena_pickup_spawn_rate())
	for i in range(ArenaPickup.PickupType.size()):
		_active_pickups_menu_button.get_popup().set_item_checked(i, GameplayController.allowed_pickups_contains(ArenaPickup.PickupType.values()[i]))
	# _jerseys_option_button.select(GameplayController.get_dudeling_jersey_index())

func _randomize_settings() -> void:
	GameplayController.randomize_gameplay_options()
	self._update_menu()


func _reset_settings() -> void:
	GameplayController.reset_gameplay_options()
	self._update_menu()


## Button Actions.

func _on_Gametype_item_selected(value) -> void:
	if Globals.IS_DEMO && value != GameplayController.Gametypes.MATCH_POINT:
		value = GameplayController.Gametypes.MATCH_POINT
		Globals._demo_check()
		_gametype_option_button.selected = GameplayController.Gametypes.MATCH_POINT
		return
	GameplayController.gametype = value
	match(value):
		GameplayController.Gametypes.TIMED_MATCH:
			_time_limit_selector.get_parent().show()
			_points_to_win_selector.get_parent().hide()
		_:
			_time_limit_selector.get_parent().hide()
			_points_to_win_selector.get_parent().show()

func _on_TimeLimit_value_changed(value) -> void:
	if Globals.IS_DEMO && value != GameplayController.DEFAULT_TIME_LIMIT:
		value = GameplayController.DEFAULT_TIME_LIMIT
		Globals._demo_check()
		_time_limit_selector.value = value
		return
	GameplayController.time_limit = value * 60

func _on_PointsToWin_value_changed(value: int) -> void:
	if Globals.IS_DEMO && value != GameplayController.DEFAULT_POINTS_TO_WIN:
		value = GameplayController.DEFAULT_POINTS_TO_WIN;
		_points_to_win_selector.value = GameplayController.DEFAULT_POINTS_TO_WIN
		Globals._demo_check()
		return
	GameplayController.set_points_to_win(value)


func _on_MinGameBalls_value_changed(value: int) -> void:
	if Globals.IS_DEMO && value != GameplayController.DEFAULT_MIN_GAME_BALLS:
		value = GameplayController.DEFAULT_MIN_GAME_BALLS
		Globals._demo_check()
		_min_game_balls_selector.value = value
		return
	GameplayController.set_min_game_balls(value)


func _on_GameBalls_item_selected(index: int) -> void:
	if Globals.IS_DEMO && index != GameplayController.DEFAULT_GAME_BALL_TYPE:
		index = GameplayController.DEFAULT_GAME_BALL_TYPE
		Globals._demo_check()
		_default_ball_option_button.selected = index
		return
	GameplayController.set_base_game_ball_type(index)


func _on_GameBallSizes_item_selected(index: int) -> void:
	if Globals.IS_DEMO && index != GameplayController.DEFAULT_GAME_BALL_SIZE:
		index = GameplayController.DEFAULT_GAME_BALL_SIZE
		Globals._demo_check()
		_game_ball_sizes_option_button.selected = index
		return
	GameplayController.set_base_game_ball_size(index)


func _on_PickupSpawnRates_item_selected(index: int) -> void:
	if Globals.IS_DEMO && index != GameplayController.DEFAULT_ARENA_PICKUP_SPAWN_RATE:
		index = GameplayController.DEFAULT_ARENA_PICKUP_SPAWN_RATE
		Globals._demo_check()
		_pickup_spawn_rates_option_button.selected = index
		return
	GameplayController.set_arena_pickup_spawn_rate(index)


func _on_ActivePickups_index_pressed(index: int) -> void:
	if Globals._demo_check():
		return
	_active_pickups_menu_button.get_popup().set_item_checked(index, !_active_pickups_menu_button.get_popup().is_item_checked(index))
	GameplayController.change_allowed_pickup(index, _active_pickups_menu_button.get_popup().is_item_checked(index))


func _on_Jerseys_item_selected(index: int) -> void:
	if Globals.IS_DEMO && index != 0:
		index = 0;
		Globals._demo_check()

		return
	GameplayController.set_dudeling_jersey_index(index)

func _on_popup_menu_open() -> void:
	_is_there_a_popup_open = true; # If it's true, that means there is a popup open
	_close_action_string = "ui_sub_menu"

func _on_parent_button_enter() -> void:
	if(_is_there_a_popup_open == true):
		Globals.get_tree().set_input_as_handled()
		# _close_action_string = "ui_sub_menu"
		_is_there_a_popup_open = false
	
	_close_action_string = "ui_cancel"


func _set_time_limit_display_value(value) -> void:
	if(value == 0): value = GameplayController.DEFAULT_TIME_LIMIT
	_time_limit_selector.set_value(value / 60)

# func _menu_close_action() -> void:
# 	# If a select menu has taken focus, let's revert to the
# 	# the ui_cancel action
	
# 	# And then we're going to clear this screen
# 	self.queue_free()
	
