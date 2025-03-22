class_name FlyingBirds
extends AnimatedSprite
# A flock of birds that fly accross the screen.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal movement_finished()


func fly() -> void:
	self.play("fly")
	
	var fly_left: int = Globals.rng.randf() <= 0.5
	self.set_flip_h(fly_left == 1)

	var x_pos: Array = [-100.0, 1380.0]
	var y_pos: float = Globals.rng.randf_range(30.0, 300.0)
	var start_pos: Vector2 = Vector2(x_pos[fly_left], y_pos)
	var end_pos: Vector2 = Vector2(x_pos[-1 - fly_left], y_pos)

	self.set_global_position(start_pos)

	var move_tween: SceneTreeTween = self.create_tween()
	var _a = move_tween.tween_property(self, "global_position", end_pos, 50.0)
	var _b = move_tween.tween_callback(self, "_on_movement_finished")


func _on_movement_finished() -> void:
	self.emit_signal("movement_finished")
	self.queue_free()
