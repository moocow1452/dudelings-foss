class_name CrowdControl
extends Node
# A script to control a crowd. THERE CAN ONLY BE ONE IN THE SCENE AT A TIME.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const MIN_CHEER_INTERVAL_TIME: float = 0.2
const MAX_CHEER_INTERVAL_TIME: float = 0.7
const EXCITED_GOAL_NUM: int = 3
const CHEER_SOUNDS: Array = [
	preload("res://Assets/ArenaBackgrounds/scenes/BackgroundCrowd/audio/cheer_0.ogg"),
	preload("res://Assets/ArenaBackgrounds/scenes/BackgroundCrowd/audio/cheer_1.ogg"),
	preload("res://Assets/ArenaBackgrounds/scenes/BackgroundCrowd/audio/cheer_2.ogg"),
]
const EXCITED_CHEER_SOUNDS: Array = [
	preload("res://Assets/ArenaBackgrounds/scenes/BackgroundCrowd/audio/excited_cheer_0.ogg"),
	preload("res://Assets/ArenaBackgrounds/scenes/BackgroundCrowd/audio/excited_cheer_1.ogg"),
	preload("res://Assets/ArenaBackgrounds/scenes/BackgroundCrowd/audio/excited_cheer_2.ogg"),
]

var _cheer_audio_player: AudioStreamPlayer = self._make_cheer_audio_player()
var _cheer_cycle_timer_home: CycleTimer = self._make_cheer_cycle_timer(1)  # Ad more timers for crowd movement variation.
var _cheer_cycle_timer_away: CycleTimer = self._make_cheer_cycle_timer(2)  # Ad more timers for crowd movement variation.


func get_crowd_members(team: int = -1) -> Array:
	return (
		self.get_tree().get_nodes_in_group(Globals.CROWD_GROUP) if team == -1 else
		self.get_tree().get_nodes_in_group(Globals.HOME_CROWD_GROUP) if team == 1 else
		self.get_tree().get_nodes_in_group(Globals.AWAY_CROWD_GROUP) if team == 2 else
		[]
	)


func sit(team: int = -1) -> void:
	for each in self.get_crowd_members(team):
		each.sit()


func is_sitting(team: int = -1) -> bool:
	return (  ## Note: Should be the same for all members of team.
		self.is_sitting(1) && self.is_sitting(2) if team == -1 else
		self.get_crowd_members(team)[0].is_sitting() if team == 1 || team == 2 else
		false
	)


func stand(team: int = -1) -> void:
	for each in self.get_crowd_members(team):
		each.stand()


func is_standing(team: int = -1) -> bool:
	return (  ## Note: Should be the same for all members of team.
		self.is_standing(1) && self.is_standing(2) if team == -1 else
		self.get_crowd_members(team)[0].is_standing() if team == 1 || team == 2 else
		false
	)


func cheer(team: int) -> void:
	if !self.is_cheering(team):
		for each in self.get_crowd_members(team):
			each.cheer()

	var is_excited: bool = ArenaController.player_score(team) >= GameplayController.get_points_to_win() - EXCITED_GOAL_NUM
	var durration: float = (
		-1.0 if ArenaController.player_score(team) >= GameplayController.get_points_to_win() - 1 else
		6.0 if is_excited else
		2.0
	)

	self._play_cheer_sound(is_excited, durration == -1.0)

	if team == 1:
		_cheer_cycle_timer_home.start_cycle(durration, self._random_cheer_time())
	elif team == 2:
		_cheer_cycle_timer_away.start_cycle(durration, self._random_cheer_time())
	else:
		_cheer_cycle_timer_home.start_cycle(durration, self._random_cheer_time())
		_cheer_cycle_timer_away.start_cycle(durration, self._random_cheer_time())


func stop_cheering(team: int = -1) -> void:
	if self.is_cheering(team):
		for each in self.get_crowd_members(team):
			each.stop_cheering()

	if team == -1 || team == 1:
		_cheer_cycle_timer_home.stop_cycle()
	
	if team == -1 || team == 2:
		_cheer_cycle_timer_away.stop_cycle()


func is_cheering(team: int = -1) -> bool:
	return (  ## Note: Should be the same for all timers for team.
		!self.is_cheering(1) && !self.is_cheering(2) if team == -1 else
		!_cheer_cycle_timer_home.get_interval_timer().is_stopped() if team == 1 else
		!_cheer_cycle_timer_away.get_interval_timer().is_stopped() if team == 2 else
		false
	)


func _random_cheer_time() -> float:
	return Globals.rng.randf_range(MIN_CHEER_INTERVAL_TIME, MAX_CHEER_INTERVAL_TIME)


func _change_cheer_anim(team: int) -> void:
	for each in self.get_crowd_members(team):
		each.change_cheer_anim()

	if team == 1:
		_cheer_cycle_timer_home.set_interval_time(self._random_cheer_time())
	elif team == 2:
		_cheer_cycle_timer_away.set_interval_time(self._random_cheer_time())
	else:
		_cheer_cycle_timer_home.set_interval_time(self._random_cheer_time())
		_cheer_cycle_timer_away.set_interval_time(self._random_cheer_time())


func _play_cheer_sound(is_excited: bool, is_looping: bool) -> void:
	var soud: AudioStreamOGGVorbis = (
		EXCITED_CHEER_SOUNDS[Globals.rng.randi_range(0, EXCITED_CHEER_SOUNDS.size() - 1)] if is_excited else
		CHEER_SOUNDS[Globals.rng.randi_range(0, CHEER_SOUNDS.size() - 1)]
	)

	_cheer_audio_player.set_stream(soud)
	_cheer_audio_player.get_stream().set_loop(is_looping)
	_cheer_audio_player.play()


func _make_cheer_audio_player() -> AudioStreamPlayer:
	var audio_player := AudioStreamPlayer.new()
	self.add_child(audio_player)
	audio_player.set_bus(AudioController.SOUND_BUS)
	return audio_player


func _make_cheer_cycle_timer(team: int) -> CycleTimer:
	var cycle_timer := CycleTimer.new()
	self.add_child(cycle_timer)
	var _a = cycle_timer.connect("timeout", self, "stop_cheering", [team])
	var _b = cycle_timer.connect("interval_timeout", self, "_change_cheer_anim", [team])
	return cycle_timer
