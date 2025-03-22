class_name PunchText
extends Sprite
# Text bubble that shows up when a player gets punched.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const LIFETIME: float = 1.0  # This shouold be less than the players stun time.


func update_image(punched_player: int) -> void:
	self.frame_coords.x = punched_player
	self.frame_coords.y = Globals.rng.randi_range(0, self.get_vframes() - 1)

	var timer: SceneTreeTimer = Globals.get_tree().create_timer(LIFETIME, false)
	var _a = timer.connect("timeout", self, "queue_free")
