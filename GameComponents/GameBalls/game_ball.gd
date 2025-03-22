class_name GameBall
extends RigidBody2D
# This is a physics based ball the the players try to get into the goal to score points.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal control_changed(controlling_player)

enum GameBallType {  # Indexing must match 'GameBallScene'.
	BASIC_BALL,
	BEACH_BALL,
	BOWLING_BALL,
	BALLOON_BALL,
	RANDOM_BALL,
}
enum GameBallSize {
	SMALL,
	REGULAR,
	LARGE,
	RANDOM,
}

const MAX_SPEED: float = 1000.0  # Make sure this number is bigger than the max force a dudeling can apply on it.
const MAX_ROTATION: float = 2000.0
const SIZE_SCALE: Array = [  # Order should match 'GameBallSize'.
	0.75,
	1.0,
	1.5,
]
const MASS_SCALE: Array = [  # Order should match 'GameBallSize'.
	0.8,
	1.0,
	1.15,
]
const PITCH_SCALE: Array = [  # Order should match 'GameBallSize'.
	0.8,
	1.0,
	1.2,
]
const GAME_BALL_ICONS: Array = [  # Order should match 'GameBallType'.
	preload("res://Assets/GameComponents/GameBalls/BasicBall/art/basic_ball_icon.png"),
	preload("res://Assets/GameComponents/GameBalls/BeachBall/art/beach_ball_icon.png"),
	preload("res://Assets/GameComponents/GameBalls/BowlingBall/art/bowling_ball_icon.png"),
	preload("res://Assets/GameComponents/GameBalls/BalloonBall/art/balloon_ball_icon.png"),
	preload("res://Assets/GameComponents/GameBalls/art/random_ball_icon.png"),
]

export(GameBallType) var game_ball_type: int = GameBallType.BASIC_BALL setget , get_game_ball_type
export var air_friction: float = 0.0

var game_ball_size: int = GameBallSize.SMALL setget set_game_ball_size, get_game_ball_size
var controlling_player: int = 0 setget , get_controlling_player

onready var _base_radius: float = $CollisionShape2D.shape.radius
onready var _base_mass: float = self.get_mass()


func get_game_ball_type() -> int:
	return game_ball_type


func set_game_ball_size(new_value: int) -> void:
	if new_value < GameBallSize.SMALL || new_value > GameBallSize.LARGE:
		return

	game_ball_size = new_value
	self.call_deferred("_resize_ball", game_ball_size)


func get_game_ball_size() -> int:
	return game_ball_size


func get_controlling_player() -> int:
	return controlling_player


func _init() -> void:
	self.add_to_group(Globals.GAME_BALL_GROUP)
	self.add_to_group(Globals.ACTIVE_GAME_BALL_GROUP)


func _ready() -> void:
	var _a = $Hitbox.connect("body_entered", self, "_on_Hitbox_body_entered")

	self.modulate.a = 0.0

	var fade_tween: SceneTreeTween = self.create_tween()
	var _b = fade_tween.tween_property(self, "modulate:a", 1.0, 0.5)
	$AnimationPlayer.play("Idle")


# func _physics_process(_delta)-> void:
# 	if(air_friction == 0.0): return
# 	var state = Physics2DDirectBodyState.instance()
# 	state.linear_velocity = # I want to add friction in the air
# 	_integrate_forces(state)

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	var vel: Vector2 = Vector2(
		clamp(self.get_linear_velocity().x, -MAX_SPEED, MAX_SPEED),
		clamp(self.get_linear_velocity().y, -MAX_SPEED, MAX_SPEED)
	)
	self.set_linear_velocity(vel)
	self.set_angular_velocity(clamp(self.get_angular_velocity(), -MAX_ROTATION, MAX_ROTATION))


func game_ball_radius() -> float:
	return $CollisionShape2D.shape.radius


func is_on_ground() -> bool:
	return self.global_position.y >= 630.0 - self.game_ball_radius()  # 630.0 is the top of the dudelings head when they are not in the air.


func is_on_cieling() -> bool:
	return self.global_position.y >= self.game_ball_radius()


func give_player_control(target_player: int) -> void:
	if target_player < 1 || target_player > 2:
		return
	
	controlling_player = target_player
	$Sprite.set_frame(controlling_player)
	$Despawn.frame_coords.x = controlling_player
	self._check_score_goal_overlap()
	self.emit_signal("control_changed", controlling_player)


func remove_player_control() -> void:
	controlling_player = 0
	$Sprite.set_frame(controlling_player)
	$Despawn.frame_coords.x = controlling_player
	self.emit_signal("control_changed", controlling_player)


func _check_score_goal_overlap() -> void:
	for area in $Hitbox.get_overlapping_areas():
		if area.is_in_group(Globals.ARENA_GOAL_GROUP):
			area.score_goal(self)
			return


func _resize_ball(new_radius: int) -> void:
	self.set_mass(_base_mass * MASS_SCALE[new_radius])
	$Sprite.set_scale(Vector2(1.0, 1.0) * SIZE_SCALE[new_radius] * 2)
	$Despawn.set_scale(Vector2(1.0, 1.0) * SIZE_SCALE[new_radius] * 2)
	$ExplosionSprite.set_scale(Vector2(1.0, 1.0) * SIZE_SCALE[new_radius] * 2)
	$CollisionShape2D.shape.radius = _base_radius * SIZE_SCALE[new_radius]
	$Hitbox/CollisionShape2D.shape.radius = (_base_radius + 1) * SIZE_SCALE[new_radius]
	$AudioStreamPlayer2D.set_pitch_scale(PITCH_SCALE[new_radius])


func _play_hit_sound() -> void:
	var normalized_scale: float = clamp(self.get_linear_velocity().length() / 300.0, 0.1, 1.0) - 1.0
	var volume_scale: float = -AudioController.MIN_VOLUME_DB * normalized_scale
	var new_volume: float = AudioController.MAX_VOLUME_DB + volume_scale
	$AudioStreamPlayer2D.set_volume_db(new_volume)
	$AudioStreamPlayer2D.set_pitch_scale(Globals.rng.randf_range(PITCH_SCALE[game_ball_size] - 0.1, PITCH_SCALE[game_ball_size] + 0.1))
	$AudioStreamPlayer2D.play()

func _despawn() -> void:
	var _a = $AnimationPlayer.connect("animation_finished", self, "queue_free")
	$AnimationPlayer.play("Explode")

func _on_Hitbox_body_entered(_body: Node) -> void:
	self._play_hit_sound()
