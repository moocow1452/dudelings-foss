class_name UILayer
extends CanvasLayer
# This is the in game canvase layer that all the player ui is on.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const GAME_OVER_WAIT_TIME: float = 1.0
const GAME_PAUSED_MENU_SCENE: PackedScene = preload("Menus/GamePausedMenu/GamePausedMenu.tscn")
const GAME_OVER_MENU_SCENE: PackedScene = preload("Menus/GameOverMenu/GameOverMenu.tscn")

var _game_paused_menu: GamePausedMenu = null


func _init() -> void:
	self.set_layer(Globals.GameCanvasLayer.UI)
	self.set_pause_mode(PAUSE_MODE_PROCESS)
	
	var _a = ArenaController.connect("game_won", self, "_on_game_won")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Input.is_action_just_pressed("ui_pause_menu") && !ArenaController.current_game_state_contains(ArenaController.GameState.GAME_OVER):
		Globals.get_tree().set_input_as_handled()
		self.open_game_paused_menu()


func open_game_paused_menu() -> void:
	if is_instance_valid(_game_paused_menu):
		return

	_game_paused_menu = GAME_PAUSED_MENU_SCENE.instance()
	self.add_child(_game_paused_menu)


func _open_game_over_menu(winning_player: int) -> void:
	var game_over_menu: GameOverMenu = GAME_OVER_MENU_SCENE.instance()
	self.add_child(game_over_menu)
	game_over_menu.show_game_over(winning_player)


func _on_game_won(winning_player: int) -> void:
	var wait_timer: SceneTreeTimer = Globals.get_tree().create_timer(GAME_OVER_WAIT_TIME, false)
	var _a = wait_timer.connect("timeout", self, "_open_game_over_menu", [winning_player])
