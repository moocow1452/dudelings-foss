tool
class_name BackgroundCrowd
extends Sprite
# A low resolution crowd of dudelings. The crowd is controlled by a crowed controller.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

export(int, 1, 2) var team: int = 1 setget set_team, get_team


func set_team(new_value: int) -> void:
	team = new_value
	self.frame_coords.x = team - 1


func get_team() -> int:
	return team


func _ready() -> void:
	if !Engine.editor_hint:
		self.add_to_group(Globals.CROWD_GROUP)

		if team == 1:
			self.add_to_group(Globals.HOME_CROWD_GROUP)
		elif team == 2:
			self.add_to_group(Globals.AWAY_CROWD_GROUP)


func sit() -> void:
	self.frame_coords.y = 0


func is_sitting() -> bool:
	return self.frame_coords.y == 0


func stand() -> void:
	self.frame_coords.y = Globals.rng.randi_range(1, 2)


func is_standing() -> bool:
	return self.frame_coords.y == 1 || self.frame_coords.y == 2


func cheer() -> void:
	self.change_cheer_anim()


func stop_cheering() -> void:
	self.sit()


func is_cheering() -> bool:
	return self.is_standing()


func change_cheer_anim() -> void:
	self.frame_coords.y = Globals.rng.randi_range(1, 2)
