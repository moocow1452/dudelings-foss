class_name GameArena
extends Node
# This is the scene that the game takes place in.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const GAME_START_WAIT_TIME: float = 3.0
const PLAYER_HUD_SCENE: PackedScene = preload("res://PlayerHUD/PlayerHUD.tscn")
const GAME_FIELDS: Array = [  # Match indexing to ArenaController.GameField order.
	"res://GameComponents/GameFields/ClassicGameField.tscn",
	"res://GameComponents/GameFields/HoopGameField.tscn",
	"res://GameComponents/GameFields/VolleyGameField.tscn",
	"res://GameComponents/GameFields/PinGameField.tscn",
]
const ARENA_BACKGROUNDS: Array = [  # Match indexing to 'ArenaController.Background'.
	"res://GameComponents/ArenaBackgrounds/City/CityBackground.tscn",
	"res://GameComponents/ArenaBackgrounds/Beach/BeachBackground.tscn",
	"res://GameComponents/ArenaBackgrounds/Stadium/StadiumBackground.tscn",
	"res://GameComponents/ArenaBackgrounds/Infield/InfieldBackground.tscn",
	"res://GameComponents/ArenaBackgrounds/Destination/DestinationBackground.tscn",
	"res://GameComponents/ArenaBackgrounds/Gym/GymBackground.tscn",
]

func _init() -> void:
	self.add_to_group(Globals.GAME_ARENA_GROUP)


func _ready() -> void:
	DisplayController.show_virtual_gamepad(DisplayController.VGP_CONTROLLER_MODE)
	var _a = self.connect("child_entered_tree", self, "_on_child_entered_tree")
	var _b = SceneController.connect("fade_out_complete", self, "_on_fade_out_complete")
	var _c = Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

	var background: ArenaBackground = load(ARENA_BACKGROUNDS[ArenaController.get_current_background_index()]).instance()
	$BackgroundLayer.add_child(background)

	var game_field:GameField = load(GAME_FIELDS[ArenaController.get_current_game_field_index()]).instance()
	self.add_child(game_field)

	self._make_player_hud()

	ArenaController.reset_game_arena()
	AudioController.stop_music()
	# AudioController.play_song(background.get_default_song(), true)

	SceneController.call_deferred("fade_out")


func _on_fade_out_complete() -> void:
	# This is a Timer not a SceneTreeTimer so it wont trigger if the scene changes.
	var start_timer := Timer.new()
	self.add_child(start_timer)
	start_timer.set_pause_mode(PAUSE_MODE_STOP)
	start_timer.set_one_shot(true)
	var _a = start_timer.connect("timeout", ArenaController, "start_game")
	start_timer.start(GAME_START_WAIT_TIME)

	ArenaController.player_hud().start_countdown(int(GAME_START_WAIT_TIME))


func _make_player_hud() -> void:
	self.add_child(PLAYER_HUD_SCENE.instance())


func _on_child_entered_tree(_node: Node) -> void:
	self.move_child($UILayer, self.get_child_count() - 1)  # Make sure GUI layer is always on top.


func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	if !connected:
		var pause_action = InputEventAction.new()
		pause_action.action = "ui_pause_menu"
		pause_action.pressed = true
		Input.parse_input_event(pause_action)
