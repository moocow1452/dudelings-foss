class_name GameLocationSubMenu
extends SubMenu
# A sub menu to choose the game loaction.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

onready var _infield_button: ButtonElement = $Locations/InfieldButton
onready var _stadium_button: ButtonElement = $Locations/StadiumButton
onready var _city_button: ButtonElement = $Locations/CityButton
onready var _beach_button: ButtonElement = $Locations/BeachButton
onready var _gym_button: ButtonElement = $Locations/GymButton
onready var _destination_button: ButtonElement = $Locations/DestinationButton
onready var _match_setup: Button = $HeaderLabel/MatchSetup

func _ready() -> void:
	DisplayController.hide_virtual_gamepad()
	_destination_button.visible = GameplayController.destination_unlocked
	if Globals.IS_DEMO:
		_destination_button.visible = true
	var _a = _infield_button.connect("pressed", self, "_on_InfieldButton_pressed")
	var _b = _stadium_button.connect("pressed", self, "_on_StadiumButton_pressed")
	var _c = _city_button.connect("pressed", self, "_on_CityButton_pressed")
	var _d = _beach_button.connect("pressed", self, "_on_BeachButton_pressed")
	var _h = _destination_button.connect("pressed", self, "_on_DestinationButton_pressed")
	var _e = _gym_button.connect("pressed", self, "_on_GymButton_pressed")
	var _f = _match_setup.connect("pressed", self, "_on_MatchSetup_pressed")
	var _g = _match_setup.connect("focus_entered", self, "_on_MatchSetup_focused")

	match ArenaController.get_current_background_index():
		ArenaController.Background.INFIELD:
			_infield_button.call_deferred("grab_focus")
		ArenaController.Background.STADIUM:
			_stadium_button.call_deferred("grab_focus")
		ArenaController.Background.CITY:
			_city_button.call_deferred("grab_focus")
		ArenaController.Background.BEACH:
			_beach_button.call_deferred("grab_focus")
		ArenaController.Background.DESTINATION:
			_destination_button.call_deferred("grab_focus")
		ArenaController.Background.GYM:
			_gym_button.call_deferred("grab_focus")
		_:
			_beach_button.call_deferred("grab_focus")


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_sub_menu("MATCH SETUP")
	InputController.button_context_bar().show_close("BACK")


## Button Actions.

func _on_InfieldButton_pressed() -> void:
	if Globals._demo_check():
		return;
	ArenaController.set_current_background_index(ArenaController.Background.INFIELD)
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_ARENA)


func _on_StadiumButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_background_index(ArenaController.Background.STADIUM)
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_ARENA)


func _on_CityButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_background_index(ArenaController.Background.CITY)
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_ARENA)


func _on_BeachButton_pressed() -> void:
	ArenaController.set_current_background_index(ArenaController.Background.BEACH)
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_ARENA)

func _on_DestinationButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_background_index(ArenaController.Background.DESTINATION)
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_ARENA)

func _on_GymButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_background_index(ArenaController.Background.GYM)
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_ARENA)

func _on_MatchSetup_focused() -> void:
	pass

func _on_MatchSetup_pressed() -> void:
	Input.action_press("ui_sub_menu")
