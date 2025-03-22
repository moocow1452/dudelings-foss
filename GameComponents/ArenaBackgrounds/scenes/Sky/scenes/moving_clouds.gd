class_name MovingClouds
extends Node2D
# Takes an image and moves it as if it was clouds in the sky. Meant for arena background.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const FRONT_CLOUDS_TEXTURE: Texture = preload("res://Assets/ArenaBackgrounds/scenes/Sky/art/clouds_front.png")
const BACK_CLOUDS_TEXTURE: Texture = preload("res://Assets/ArenaBackgrounds/scenes/Sky/art/clouds_back.png")
const CLOUD_TEXTURE_WIDTH: float = 1280.0

var _front_cloud_speed: float = 3.0
var _back_cloud_speed: float = 1.5


func _init() -> void:
	if Globals.rng.randf() <= 0.5:
		_front_cloud_speed *= -1.0
		_back_cloud_speed *= -1.0


func _process(delta: float) -> void:
	self._move_clouds($FrontCloudSprites, _front_cloud_speed * delta)
	self._move_clouds($BackCloudSprites, _back_cloud_speed * delta)


func _move_clouds(cloud_group: Node2D, cloud_speed: float) -> void:
	for clouds in cloud_group.get_children():
		clouds.position.x += cloud_speed

	if cloud_speed > 0.0:
		var first_sprite: Sprite = cloud_group.get_child(2)
		if first_sprite.position.x > 1280.0 + (CLOUD_TEXTURE_WIDTH / 2.0):
			var new_position_x: float = cloud_group.get_child(0).position.x - CLOUD_TEXTURE_WIDTH
			first_sprite.position.x = new_position_x
			cloud_group.move_child(first_sprite, 0)
	else:
		var first_sprite: Sprite = cloud_group.get_child(0)
		if first_sprite.position.x < -CLOUD_TEXTURE_WIDTH / 2.0:
			var new_position_x: float = cloud_group.get_child(2).position.x + CLOUD_TEXTURE_WIDTH
			first_sprite.position.x = new_position_x
			cloud_group.move_child(first_sprite, 2)
