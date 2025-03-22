class_name InfieldBackground
extends ArenaBackground
# An arena background that looks like the infield of a baseball diamond
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func get_default_song() -> String:
	return AudioController.INFIELD_MUSIC


func _ready() -> void:
	# Turn on stadium lights.
	for light in $StadiumLights.get_children():
		light.frame_coords.y = 1

	$CrowdControl.stand()
	$Advertising.play_random_ads()
	
	# DEBUG ONLY.
	# self._game_started()
	# $Seagull/AnimationPlayer.get_animation("fly_into_scene").set_loop(true)
	# $Seagull/AnimationPlayer.play("fly_into_scene")


func _game_started() -> void:
	$CrowdControl.sit()

	# var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(0, 1), false)
	# var _a = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])

	if Globals.rng.randf() <= Globals.SEAGULL_SPAWN_CHANCE:
		var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(Globals.SEAGULL_SPAWN_MIM_DELAY, Globals.SEAGULL_SPAWN_MAX_DELAY), false)
		var _a = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])
	else:
		$Seagull.queue_free()


func _goal_scored(scoring_player: int) -> void:
	$CrowdControl.cheer(scoring_player)

	if scoring_player == 1:
		$Advertising.play_home_scores()
	elif scoring_player == 2:
		$Advertising.play_away_scores()


func _game_over(winning_player: int) -> void:
	self._flash_lights()
	$CrowdControl.stop_cheering(Globals.other_player(winning_player))
	$CrowdControl.cheer(winning_player)

	if winning_player == 1:
		$Advertising.play_home_scores(true)
	elif winning_player == 2:
		$Advertising.play_away_scores(true)


func _flash_lights() -> void:
	var cycle_timer := CycleTimer.new()
	self.add_child(cycle_timer)
	var _a = cycle_timer.connect("interval_timeout", self, "_on_flash_lights_timer_interval_timeout")
	cycle_timer.start_cycle(-1.0, 0.25)


func _on_flash_lights_timer_interval_timeout() -> void:
	for light in $StadiumLights.get_children():
		light.frame_coords.y = Globals.rng.randi_range(0, 1)
