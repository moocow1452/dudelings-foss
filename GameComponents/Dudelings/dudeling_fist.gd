class_name DudelingFist
extends Sprite
# A fist that swings to the left or right of the dudeling. This is an animation.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const PUNCH_HOLD_TIME: float = 0.3
const WIND_DOWN_SPEED: float = 0.3
const PUNCH_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/Dudelings/audio/dudeling_punch.ogg")
const PUNCH_MISSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/Dudelings/audio/dudeling_punch.ogg")
const PUNCH_TEXT_SCENE: PackedScene = preload("PunchText.tscn")


static func punch_time() -> float:
	return PUNCH_HOLD_TIME + WIND_DOWN_SPEED


func punch(controlling_dudeling: KinematicBody2D, direction: int) -> Object:
	var controlling_player: int = controlling_dudeling.get_controlling_player()

	self.scale.x *= direction
	self.frame_coords.x = controlling_dudeling.get_node("Body/BodySprite").frame_coords.x
	self.frame_coords.y = self._num_frames() * (controlling_player - 1)
	
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(PUNCH_HOLD_TIME, false)
	var _a = timer.connect("timeout", self, "_change_frame", [controlling_player - 1, 1])
	
	var punch_ray := RayCast2D.new()
	self.add_child(punch_ray)
	punch_ray.set_collision_mask(Globals.GamePhysicsLayerValue.DUDELING)
	punch_ray.add_exception(controlling_dudeling)
	punch_ray.set_cast_to(Vector2(50.0, 0.0))  # 50 is the lenght of the punch ainimation.
	punch_ray.force_raycast_update()  # Calculate on same frame.
	punch_ray.queue_free()

	var punched_dudeling: Object = punch_ray.get_collider()

	AudioController.play_game_sound(PUNCH_SOUND if is_instance_valid(punched_dudeling) else PUNCH_MISSED_SOUND, controlling_player, AudioController.PITCH_SHIFT_MEDIUM)

	if is_instance_valid(punched_dudeling):
		InputController.vibrate_controller(controlling_player, 0.0, 0.5, 0.3)
		
		var punched_player: int = punched_dudeling.get_controlling_player()
		if punched_player > 0:
			var punch_text: PunchText = PUNCH_TEXT_SCENE.instance()
			punch_text.update_image(punched_player)
			ArenaController.game_field().add_child(punch_text)
			punch_text.set_global_position(punched_dudeling.get_global_position() + Vector2(-20.0 * direction, -80.0))
			InputController.vibrate_controller(punched_player, 0.0, 1.0, 0.3)

	return punched_dudeling


func _change_frame(anim_set: int, target_frame: int) -> void:
	if target_frame > self._num_frames() - 1:
		self.queue_free()
		return

	self.frame_coords.y = target_frame + (anim_set * self._num_frames())
	
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(WIND_DOWN_SPEED / self._num_frames(), false)
	var _a = timer.connect("timeout", self, "_change_frame", [anim_set, target_frame + 1])


func _num_frames() -> int:
	return int(self.get_vframes() / 2.0)
