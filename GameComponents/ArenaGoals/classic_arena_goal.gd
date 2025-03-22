tool
class_name ClassicArenaGoal
extends ArenaGoal
# A goal that looks like a pipe. There is a differend one for each player.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _ready() -> void:
	var _a = $ForceField.connect("animation_finished", self, "_on_force_field_animation_finished")
	self.set_defending_player(defending_player)


func set_defending_player(new_value: int) -> void:
	var player: int = int(clamp(new_value, 1, 2))

	.set_defending_player(player)
	
	if self.has_node("FrontSprite"):
		$FrontSprite.frame_coords.y = player
	
	if self.has_node("BackSprite"):
		$BackSprite.frame_coords.y = player


func _on_force_field_animation_finished() -> void:
	match $ForceField.get_animation():
		"on":
			$ForceField.play("off")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GAME_BALL_GROUP):
		if body.get_controlling_player() == defending_player || body.get_controlling_player() == 0:
			var directon_normal: Vector2 = (self.get_global_position() - body.get_global_position()).normalized()
			body.apply_impulse(body.game_ball_radius() * -directon_normal, Vector2(400.0, 0.0) * directon_normal)
			$ForceField.play("on")

	._on_body_entered(body)
