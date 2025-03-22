class_name ShootingStar
extends AnimatedSprite
# A star that moves across the sky in the background.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _ready() -> void:
	self.modulate.a = 0.0
	self.play("default")
	self._fade_in()
	self._start_moving()
	self._sparkle()


func _start_moving() -> void:
	var start_end_x_pos: Array = [
		Globals.rng.randf_range(0.0, 500.0),
		Globals.rng.randf_range(780.0, 1280.0),
	]
	if Globals.rng.randf() <= 0.5:
		start_end_x_pos.invert()

	self.set_global_position(Vector2(start_end_x_pos[0], Globals.rng.randf_range(0.0, 100.0)))

	var end_pos: Vector2 = Vector2(start_end_x_pos[1], Globals.rng.randf_range(300.0, 400.0))

	self.look_at(end_pos)

	var move_tween: SceneTreeTween = self.create_tween()
	var _a = move_tween.tween_property(self, "global_position", end_pos, 1.0)
	var _b = move_tween.tween_callback(self, "queue_free")


func _sparkle() -> void:
	var sparkle_tween: SceneTreeTween = self.create_tween().set_parallel(true)
	var _a = sparkle_tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5), 0.5)
	var _b = sparkle_tween.chain().tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.5)
	var _c = sparkle_tween.set_loops()


func _fade_in() -> void:
	var fade_tween: SceneTreeTween = self.create_tween()
	var _a = fade_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	var _b = fade_tween.tween_callback(self, "_fade_out")


func _fade_out() -> void:
	var fade_tween: SceneTreeTween = self.create_tween()
	var _a = fade_tween.tween_property(self, "modulate:a", 0.0, 1.0)
	var _b = fade_tween.tween_callback(self, "queue_free")
