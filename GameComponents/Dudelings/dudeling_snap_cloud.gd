class_name DudelingSnapCloud
extends AnimatedSprite
# A cloud that shows the snap direction of the dudeling.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const LIFETIME: float = 1.0
const MOVE_DISTANCE: float = 30.0
const SNAP_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/Dudelings/audio/snap_cloud_sound.ogg")


func start(controlling_player: int, cloud_direction: int) -> void:
	self.scale.x = 0.0
	self.play("player_one" if controlling_player == 1 else "player_two")
	self._move(cloud_direction)
	self._change_size(cloud_direction)
	AudioController.play_game_sound(SNAP_SOUND, controlling_player, AudioController.PITCH_SHIFT_INFREQUENT)

	var timer: SceneTreeTimer = Globals.get_tree().create_timer(LIFETIME, false)
	var _a = timer.connect("timeout", self, "queue_free")


func _move(cloud_direction: int) -> void:
	var move_tween: SceneTreeTween = self.create_tween()
	var _a = move_tween.tween_property(self, "position:x", self.get_position().x + (MOVE_DISTANCE * cloud_direction), LIFETIME)


func _change_size(cloud_direction: int) -> void:
	var tween: SceneTreeTween = self.create_tween().set_parallel(true)
	var _a = tween.tween_property(self, "scale:x", 1.0 * cloud_direction, LIFETIME * 0.2)  # Match with scale out time.
	var _b = tween.chain().tween_property(self, "scale:x", 0.5 * cloud_direction, LIFETIME * 0.8)  # Match with scale in time.
