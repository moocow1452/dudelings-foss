class_name GymBackground
extends ArenaBackground
# An arena background that looks like a high school gymnasium
#
# @author gbryant
# @copyright 2024 Heavy Element

func get_default_song() -> String:
	return AudioController.GYM_ARENA_MUSIC


func _ready() -> void:

	$CrowdControl.stand()
	
	# DEBUG ONLY.
	# self._game_started()
	# $Seagull/AnimationPlayer.get_animation("fly_into_scene").set_loop(true)
	# $Seagull/AnimationPlayer.play("fly_into_scene")

	# if Globals.rng.randf() <= Globals.SEAGULL_SPAWN_CHANCE:
	# 	var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(Globals.SEAGULL_SPAWN_MIM_DELAY, Globals.SEAGULL_SPAWN_MAX_DELAY), false)
	# 	var _a = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])
	# else:
	# 	$Seagull.queue_free()


func _game_started() -> void:
	$CrowdControl.sit()

	# if Globals.rng.randf() <= 0.01:
	# 	var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(0.0, 60.0), false)
	# 	var _a = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])
	# else:
	# $Seagull.queue_free()


func _goal_scored(scoring_player: int) -> void:
	$CrowdControl.cheer(scoring_player)



func _game_over(winning_player: int) -> void:
	$CrowdControl.stop_cheering(Globals.other_player(winning_player))
	$CrowdControl.cheer(winning_player)


	if winning_player == 1:
		# $Advertising.play_home_scores(true)
		pass
	elif winning_player == 2:
		# $Advertising.play_away_scores(true)
		pass


# func stun_seagull() -> void:
# 	if !_is_night:
# 		return

# 	$Seagull.stun()
# 	self._flash_light_for_seagull(true)

