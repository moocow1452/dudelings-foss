class_name DestinationBackground
extends ArenaBackground
# An arena background that looks like a crystalline platform suspended in space
#
# @author gbryant
# @copyright 2024 Heavy Element

const MIN_BLACK_HOLE_SPEED = 0.2;

onready var black_hole = $BlackHole/HoleSpritePlayer

func _ready() -> void:
	var night_sky = $NightSky.get_children()[0]
	night_sky.texture = load("res://GameComponents/ArenaBackgrounds/Destination/art/background.png")
	night_sky.scale.x = 2
	night_sky.scale.y = 2
	black_hole.playback_speed = MIN_BLACK_HOLE_SPEED
	black_hole.play("Glow")
	$BlackHole/HoleFloater.play("Float")
	$Destination/StageFloater.play("StageFloat")
	pass

func get_default_song() -> String:
	return AudioController.DESTINATION_MUSIC


func _game_started() -> void:
	
	if Globals.rng.randf() <= Globals.SEAGULL_SPAWN_CHANCE:
		var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(Globals.SEAGULL_SPAWN_MIM_DELAY, Globals.SEAGULL_SPAWN_MAX_DELAY), false)
		var _a = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])
	else:
		$Seagull.queue_free()


func _goal_scored(scoring_player: int) -> void:
	if scoring_player == 1:
		$DestinationScore.play("blue_player_score")
	else:
		$DestinationScore.play("red_player_score")
	
	var max_score: float = max(ArenaController.player_one_score, ArenaController.player_two_score)
	var playback_speed := (GameplayController.points_to_win / max_score) * .2
	$BlackHole/HoleSpritePlayer.playback_speed = MIN_BLACK_HOLE_SPEED + playback_speed


func _game_over(winning_player: int) -> void:
	$GameWonFireworks.start_launching()
