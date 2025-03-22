class_name BeachBackground
extends ArenaBackground
# An arena background that looks like a sandy beach.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

var _is_dusk: bool = false


func get_default_song() -> String:
	return AudioController.BEACH_ARENA_MUSIC


func _ready() -> void:
	# Dusk sky.
	if Globals.rng.randf() <= 0.2:
		_is_dusk = true

		$DaySky.queue_free()
		$SpeedboatSprite.queue_free()

		$WaveShimmer.play("shimmer")
		$SandSprite.frame_coords.y = 1
	# Day sky.
	else:
		var _a = $SpeedboatSprite/AnimationPlayer.connect("animation_finished", self, "_speedboat_movement_over")
		
		$DuskSky.queue_free()
		$WaveShimmer.queue_free()

	self._start_speedboat()
	
	self._start_waves()
	$SmallUmbrellaSprite.play("default")
	$LargeUmbrellaSprite.play("default")

	if Globals.rng.randf() <= Globals.SEAGULL_SPAWN_CHANCE:
		var seagull_timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(Globals.SEAGULL_SPAWN_MIM_DELAY, Globals.SEAGULL_SPAWN_MAX_DELAY), false)
		var _b = seagull_timer.connect("timeout", $Seagull/AnimationPlayer, "play", ["fly_into_scene"])
	else:
		$Seagull.queue_free()


func _game_started() -> void:
	self._start_flip_small_umbrella_cycle()
	self._start_cruse_ship()

func _goal_scored(scoring_player: int) -> void:
	if scoring_player == 1:
		$LeftFireworks.start_launching(3.0)
	else:
		$RightFireworks.start_launching(3.0)


func _game_over(winning_player: int) -> void:
	$MiddleFireworks.start_launching()

	if winning_player == 1:
		$LeftFireworks.start_launching()
	else:
		$RightFireworks.start_launching()


func _start_waves() -> void:
	var anim_name: String = (
		"waves_dusk" if _is_dusk else
		"waves_day"
	)
	$WavesSprite.play(anim_name)

	var waves_out_wait_time: float = Globals.rng.randf_range(2.0, 2.2)
	var waves_out_timer: SceneTreeTimer = Globals.get_tree().create_timer(waves_out_wait_time, false)
	var _a = waves_out_timer.connect("timeout", $WavesSprite, "play", [anim_name, true])

	var waves_cycle_timer: SceneTreeTimer = Globals.get_tree().create_timer(waves_out_wait_time + Globals.rng.randf_range(2.0, 2.2), false)
	var _b = waves_cycle_timer.connect("timeout", self, "_start_waves")


func _start_flip_small_umbrella_cycle() -> void:
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(30.0, 60.0), false)
	var _a = timer.connect("timeout", self, "_flip_small_umbrella", [4.0])
	var _b = timer.connect("timeout", self, "_start_flip_small_umbrella_cycle")


func _flip_small_umbrella(filp_time: float) -> void:
	$SmallUmbrellaSprite.play("flip")
	
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(filp_time, false)
	var _a = timer.connect("timeout", $SmallUmbrellaSprite, "play", ["default"])


func _start_speedboat() -> void:
	$SpeedboatSprite.play("running")
	self._speedboat_movement_over("")


func _speedboat_movement_over(anim_name: String) -> void:
	if anim_name == "RESET":
		return

	var move_sets: Array = ["move_0", "move_1"]
	$SpeedboatSprite/AnimationPlayer.play(move_sets[Globals.rng.randi_range(0, move_sets.size() - 1)])


func _start_cruse_ship() -> void:
	var move_time: float = 600.0
	var start_end_pos: Array = [-100.0, 1380.0]

	$CruiseShipSprite.set_flip_h(false)

	if Globals.rng.randf() <= 0.5:
		start_end_pos.invert()
		$CruiseShipSprite.set_flip_h(true)

	$CruiseShipSprite.play("default")

	$CruiseShipSprite.global_position.x = start_end_pos[0]
	
	var move_tween: SceneTreeTween = self.create_tween()
	var _a = move_tween.tween_property($CruiseShipSprite, "global_position:x", start_end_pos[1], move_time)
	var _b = move_tween.tween_callback(self, "_start_cruse_ship").set_delay(Globals.rng.randf_range(10.0, 30.0))
