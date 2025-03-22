tool
class_name PinArenaGoal
extends ArenaGoal
# Goals for the Pin game
#
# @author gbryant
# @copyright 2024 Heavy Element

signal fractional_point(controlling_player, ball)

onready var sprite = $PinSprite
onready var animation_player = $AnimationPlayer

var fractional_point_eligible: bool = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	_is_pin = true
	var _a = ArenaController.connect("game_won", self, "_on_game_won")
	animation_player.connect("animation_finished", self, "_animation_state_revert")
	animation_player.play("Reset")
	self.set_defending_player(defending_player)

# Set up sprites
func set_defending_player(new_value: int) -> void:
	.set_defending_player(new_value)
	if(new_value == 2):
		var sprite_sprite = $PinSprite
		sprite_sprite.texture = load("res://Assets/GameComponents/ArenaGoals/art/pinball-goal-away.png")
		var hole_sprite = $HoleSprite
		hole_sprite.texture = load("res://Assets/GameComponents/ArenaGoals/art/pinball-hole-away.png")

func _on_body_entered(body) -> void:
	var controlling_player = body.get_controlling_player()
	
	if !fractional_point_eligible: return
	
	if body.is_in_group(Globals.GAME_BALL_GROUP):
		if controlling_player == defending_player || controlling_player == 0:
			return
		fractional_point_eligible = false
		animation_player.play("Retract")
		_play_retract_sound()
		award_fractional_point(controlling_player, body)

func score_goal(_game_ball: GameBall) -> void:
	return

func reset_pin() -> void:
	fractional_point_eligible = true
	animation_player.play("Reset")
	pass

func award_fractional_point(player, ball) -> void:
	emit_signal("fractional_point", player, ball)

func _animation_state_revert(_unused) -> void:
	pass

func _on_game_won(_unused):
	fractional_point_eligible = false

func _play_retract_sound() -> void:

	pass
			
	
