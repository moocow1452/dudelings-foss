class_name ArenaPickup
extends Area2D
# Abstract class for pickups that spawn throughout the game arena and provide
# different types of gameplay changes.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal pickup_activated(pickup_type, activating_player)
signal pickup_canceled(pickup_type, canceling_player)

enum PickupType {  # Match indexing to 'AreaPickupSpawningArea.PICKUP_SCENES'.
	EXTRA_BALL,
	RANDOM_BALL,
	SMALLER_BALL,
	BIGGER_BALL,
	SWITCH_CONTROL,
	# HIDE_HIGHLIGHT,
	# STUN_OPPONENT,
	BLACK_HOLE,
	MYSTERY,
}

const SPAWNED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/ArenaPickups/audio/pickup_spawned.ogg")
const ACTIVATED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/ArenaPickups/audio/pickup_activated.ogg")
const CANCELED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/ArenaPickups/audio/pickup_canceled.ogg")

var pickup_type: int = -1 setget , get_pickup_type

var _activating_ball: GameBall = null
var _activating_player: int = -1
var _effect_time: float = -1.0


func get_pickup_type() -> int:
	return pickup_type


func _pickup_effect() -> void:
	pass  # Virtual method.


func _init() -> void:
	self.add_to_group(Globals.ARENA_PICKUP_GROUP)


func _ready() -> void:
	var _a = $AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")
	var _b = self.connect("body_entered", self, "_on_body_entered")
	var _c = self.connect("area_entered", self, "_on_area_entered")
	
	AudioController.play_universal_sound(SPAWNED_SOUND, AudioController.PITCH_SHIFT_TONAL)
	$AnimatedSprite.play("spawn")


func effect_time() -> float:
	return _effect_time


func activate_effect(activating_ball: GameBall = null) -> void:
	$CollisionShape2D.call_deferred("set_disabled", true)

	AudioController.play_universal_sound(ACTIVATED_SOUND, AudioController.PITCH_SHIFT_TONAL)
	$AnimatedSprite.play("activate")

	if ArenaController.current_game_state_contains(ArenaController.GameState.GAME_OVER):
		return

	_activating_ball = activating_ball

	if is_instance_valid(_activating_ball):
		_activating_player = activating_ball.get_controlling_player()

	self._pickup_effect()

	self.emit_signal("pickup_activated", pickup_type, _activating_player)


func cancel_pickup(canceling_dudeling: Dudeling = null) -> void:
	$CollisionShape2D.call_deferred("set_disabled", true)

	AudioController.play_universal_sound(CANCELED_SOUND, AudioController.PITCH_SHIFT_TONAL)
	$AnimatedSprite.play("cancel")
	

	var target_player: int = canceling_dudeling.get_controlling_player() if is_instance_valid(canceling_dudeling) else -1
	self.emit_signal("pickup_canceled", pickup_type, target_player)


func _loop_wobble_animation() -> void:
	var tween: SceneTreeTween = self.create_tween().set_parallel(true)
	var _a = tween.tween_property(self, "rotation_degrees", -30.0, 1.5)
	var _b = tween.chain().tween_property(self, "rotation_degrees", 30.0, 3.0)
	var _c = tween.chain().tween_property(self, "rotation_degrees", 0.0, 1.5)
	var _d = tween.set_loops()


func _on_animation_finished() -> void:
	match $AnimatedSprite.get_animation():
		"spawn":
			$AnimatedSprite.play("default")
			self._loop_wobble_animation()
		"activate":
			self._activate_animation_finished()
		"cancel":
			self.queue_free()


# Overridden by TimedPickup to change behaviour.
func _activate_animation_finished() -> void:
	self.queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GAME_BALL_GROUP):
		self.activate_effect(body)
	elif body.is_in_group(Globals.DUDELING_GROUP):
		self.cancel_pickup(body)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(Globals.ARENA_PICKUP_GROUP):
		self.cancel_pickup()
