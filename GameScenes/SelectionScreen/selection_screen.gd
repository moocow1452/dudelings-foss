class_name SelectionScreen
extends Node
# A menu for selecting gameplay options.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const PLAYER_SELECTION_SUB_MENU_SCENE: PackedScene = preload("PlayerSelectionSubMenu.tscn")
const GAME_OPTIONS_SUB_MENU_SCENE: PackedScene = preload("GameOptionsSubMenu.tscn")

var _game_options_sub_menu: GameOptionsSubMenu = null


func _ready() -> void:
	self.add_to_group(Globals.MENU_GROUP)  # Note: This scene counts as a menu.
	
	self._open_player_selection_sub_menu()
	AudioController.play_song(AudioController.RESULTS_SCREEN_MUSIC, true)

	SceneController.call_deferred("fade_out")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Input.is_action_just_pressed("ui_sub_menu"):
		Globals.get_tree().set_input_as_handled()

		if !is_instance_valid(_game_options_sub_menu):
			if Globals.focused_menu() is PlayerSelectonSubMenu:
				return
			if Globals.focused_menu() is GameTypeSubMenu:
				return

			self._open_game_options_sub_menu()


func _open_player_selection_sub_menu() -> void:
	var sub_menu: PlayerSelectonSubMenu = PLAYER_SELECTION_SUB_MENU_SCENE.instance()
	self.add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "_go_to_main_menu")


func _open_game_options_sub_menu() -> void:
	_game_options_sub_menu = GAME_OPTIONS_SUB_MENU_SCENE.instance()
	self.add_child(_game_options_sub_menu)


func _go_to_main_menu() -> void:
	SceneController.go_to_scene(SceneController.GameSceneId.MAIN_MENU)
