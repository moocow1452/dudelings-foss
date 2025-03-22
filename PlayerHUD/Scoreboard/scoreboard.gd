class_name Scoreboard
extends TextureRect
# The scoreboard for the game arena.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element
var overtime_spin_count = 0

func _ready() -> void:
	var _a = ArenaController.connect("game_run_time_changed", self, "_update_game_timer")
	var _b = ArenaController.connect("score_changed", self, "_update_scoreboard")
	var _c = ArenaController.connect("overtime_start", self, "_on_over_time")
	var _d = $AnimationPlayer.connect("animation_finished", self, "_update_animation")
	# Pass an empty string to _update_animation to set up the animation player
	_update_animation("")
	self._update_game_timer(ArenaController.get_game_run_time())
	self._update_scoreboard()



func _update_game_timer(new_time: int) -> void:
	var min_str: int = int(floor(new_time / 60.0)) % 100
	var sec_str: String = str(new_time % 60).pad_zeros(2)
	$GameTimerLabel.set_text(str(min_str) + ":" + sec_str)

func _on_over_time() -> void:
	$AnimationPlayer.play("OverTime")

func _update_animation(anim_name) -> void:
	match(anim_name):
		"Spin":
			overtime_spin_count += 1
			if(overtime_spin_count >= 5):
				$AnimationPlayer.play("OverTime")
			else:
				$AnimationPlayer.play("Spin")
		"OverTime":
			overtime_spin_count = 0
			$AnimationPlayer.play("Spin")
		_:
			$AnimationPlayer.stop()
			$GameTimerLabel.visible = true
			$OverLabel.visible = false
			$ScoreboardRotate.visible = false

func _update_scoreboard() -> void:
	$PlayerOneScoreLabel.set_text(str(ArenaController.get_player_one_score()))
	$PlayerTwoScoreLabel.set_text(str(ArenaController.get_player_two_score()))
