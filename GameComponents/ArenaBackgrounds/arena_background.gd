class_name ArenaBackground
extends Node2D
# Abstract class for arena backgrounds.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

export var fadeout_length:float = 5.00;
export var transition_type:int = 1 # SINE
onready var tween = $Tween
onready var music_player = $MusicPlayer

func get_default_song() -> String:
	return AudioController.MAIN_THEME_MUSIC


# Virtual method.
func _game_started() -> void:
	pass


# Virtual method.
func _goal_scored(_scoring_player: int) -> void:
	pass


# Virtual method.
func _game_over(_winning_player: int) -> void:
	pass


func _init() -> void:
	self.add_to_group(Globals.GAME_ARENA_BACKGROUND_GROUP)
	var _a = ArenaController.connect("game_started", self, "_game_started")
	var _b = ArenaController.connect("player_scored", self, "_goal_scored")
	var _d = ArenaController.connect("game_won", self, "_game_over")
	var _c = ArenaController.connect("game_ended", self, "_fade_out")


func _fade_out() -> void:
	if !is_instance_valid(music_player): return
	tween.connect("finished", self, "_stop_music")
	tween.interpolate_property(music_player, "volume_db", 0, -80, fadeout_length, transition_type, Tween.EASE_IN, 0)
	tween.start()

func _stop_music() -> void:
	music_player.stop()
	music_player.volume_db = 0
