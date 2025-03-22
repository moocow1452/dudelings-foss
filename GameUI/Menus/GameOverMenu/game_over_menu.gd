class_name GameOverMenu
extends BaseMenu
# This menu is shown at the end of each game as a way to show who won.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const INPUT_BLOCKED_TIME: float = 1.0

var _input_blocking_timer: Timer = self._make_input_blocking_timer()

func _ready():
	AudioController.stop_music()
	var _a = PlayerStats.connect("destination_unlocked", self, "_destination_unlocked")
	var timer = get_tree().create_timer(1)
	timer.connect("timeout", PlayerStats, "check_destination_unlocked")
	pass

func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	if !_input_blocking_timer.is_stopped():
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		Globals.get_tree().set_input_as_handled()
		self._go_to_next_scene()


func show_game_over(winning_player: int) -> void:
	$AnimationPlayer.play("home_wins" if winning_player == 1 else "away_wins")

	var target_music: String = AudioController.YOU_WON_MUSIC
	var player_one_is_ai: bool = InputController.get_player_one_control_option() >= InputController.PlayerOptions.AI_EASY
	var player_two_is_ai: bool = InputController.get_player_two_control_option() >= InputController.PlayerOptions.AI_EASY
	if player_one_is_ai && !player_two_is_ai && winning_player == 1:
		target_music = AudioController.YOU_LOST_MUSIC
	elif player_two_is_ai && !player_one_is_ai && winning_player == 2:
		target_music = AudioController.YOU_LOST_MUSIC
	
	AudioController.play_song(target_music, false)
	# Now let's load the song and make it play
	
	var song_over_timer: SceneTreeTimer = Globals.get_tree().create_timer(AudioController.currently_playing_song.get_length(), false)
	var _a = song_over_timer.connect("timeout", self, "_go_to_next_scene")

	_input_blocking_timer.start(INPUT_BLOCKED_TIME)


func _go_to_next_scene() -> void:
	AudioController.stop_music()  # Stop the music so it wont start looping during screen fade out.
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_OPTIONS)


func _make_input_blocking_timer() -> Timer:
	var blocking_timer := Timer.new()
	self.add_child(blocking_timer)
	blocking_timer.set_pause_mode(PAUSE_MODE_STOP)
	blocking_timer.set_one_shot(true)
	return blocking_timer

func _destination_unlocked() -> void:
	$DestinationUnlocked.play("Unlocked")
