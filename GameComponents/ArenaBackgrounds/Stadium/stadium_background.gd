class_name StadiumBackground
extends ArenaBackground
# An arena background that looks like a stadium.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

var _is_night: bool = false


func get_default_song() -> String:
	return AudioController.STADIUM_ARENA_MUSIC


func _ready() -> void:
	# Night sky.
	if Globals.rng.randf() <= 0.5:
		_is_night = true

		$DaySky.queue_free()
		$StadiumShadow.queue_free()

		for light in $StadiumLights.get_children():
			light.frame_coords.y = 1
	# Day sky.
	else:
		$NightSky.queue_free()

	$CrowdControl.stand()
	$Advertising.play_random_ads()
	
	# DEBUG ONLY.
	# self._game_started()
	# $Seagull/AnimationPlayer.get_animation("fly_into_scene").set_loop(true)
	# $Seagull/AnimationPlayer.play("fly_into_scene")

	if Globals.rng.randf() <= Globals.SEAGULL_SPAWN_CHANCE:
		var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(Globals.SEAGULL_SPAWN_MIM_DELAY, Globals.SEAGULL_SPAWN_MAX_DELAY), false)
		var _a = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])
	else:
		$Seagull.queue_free()


func _game_started() -> void:
	$CrowdControl.sit()

	# if Globals.rng.randf() <= 0.01:
	# 	var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(0.0, 60.0), false)
	# 	var _a = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])
	# else:
	# $Seagull.queue_free()


func _goal_scored(scoring_player: int) -> void:
	$CrowdControl.cheer(scoring_player)

	if scoring_player == 1:
		$Advertising.play_home_scores()
	elif scoring_player == 2:
		$Advertising.play_away_scores()


func _game_over(winning_player: int) -> void:
	$Fireworks.start_launching()
	$CrowdControl.stop_cheering(Globals.other_player(winning_player))
	$CrowdControl.cheer(winning_player)

	if _is_night:
		self._flash_lights()

	if winning_player == 1:
		$Advertising.play_home_scores(true)
	elif winning_player == 2:
		$Advertising.play_away_scores(true)


func stun_seagull() -> void:
	if !_is_night:
		return

	$Seagull.stun()
	self._flash_light_for_seagull(true)


func _flash_light_for_seagull(turn_light_off: bool) -> void:
	$StadiumLights/StadiumLight1.frame_coords.y = 0 if turn_light_off else 1
	
	if turn_light_off:
		var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(3.0, false)
		var _a = seagull_timer.connect("timeout", self, "_flash_light_for_seagull", [false])


func _flash_lights() -> void:
	var cycle_timer := CycleTimer.new()
	self.add_child(cycle_timer)
	var _a = cycle_timer.connect("interval_timeout", self, "_on_flash_lights_timer_interval_timeout")
	cycle_timer.start_cycle(-1.0, 0.25)


func _on_flash_lights_timer_interval_timeout() -> void:
	for light in $StadiumLights.get_children():
		light.frame_coords.y = Globals.rng.randi_range(0, 1)
