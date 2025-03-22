class_name Seagull
extends AnimatedSprite
# A seagull that will sometimes fly around the screen.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _ready() -> void:
	var _a = self.connect("animation_finished", self, "_on_animation_finished")
	var _b = $Hitbox.connect("area_entered", self, "_on_hitbox_area_entered")


func stand() -> void:
	self.play("stand")


func float_on_water() -> void:
	self.play("float_on_water")


func look() -> void:
	self.play("look")


func peck() -> void:
	self.play("peck")


func take_off() -> void:
	self.play("take_off")


func land() -> void:
	self.play("land")


func land_on_water() -> void:
	self.play("land_on_water")


func fly() -> void:
	self.play("fly")


func stun() -> void:
	self.play("stun")
	$SquakSound.play()


func allow_background_object_hit(can_get_hit: bool) -> void:
	if can_get_hit:
		$Hitbox.set_collision_mask($Hitbox.get_collision_mask() | Globals.GamePhysicsLayerValue.BACKGROUND)
	else:
		$Hitbox.set_collision_mask($Hitbox.get_collision_mask() & ~Globals.GamePhysicsLayerValue.BACKGROUND)


func allow_game_ball_hit(can_get_hit: bool) -> void:
	if can_get_hit:
		$Hitbox.set_collision_mask($Hitbox.get_collision_mask() | Globals.GamePhysicsLayerValue.GAME_BALL)
	else:
		$Hitbox.set_collision_mask($Hitbox.get_collision_mask() & ~Globals.GamePhysicsLayerValue.GAME_BALL)


func _on_animation_finished() -> void:
	match self.get_animation():
		"look", "peck", "land":
			self.stand()
		"land_on_water":
			self.float_on_water()
		"take_off":
			self.fly()


func _on_hitbox_area_entered(_area: Area2D) -> void:
	self.stun()

	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	# Stop any animations that are being played from the current scene.
	for child in self.get_children():
		if child is AnimationPlayer:
			child.queue_free()

	var timer: SceneTreeTimer = Globals.get_tree().create_timer(2.0, false)
	var _a = timer.connect("timeout", self, "queue_free")
