tool
class_name MiniDudeling
extends Sprite
# A small dudeling. The dudeling is controlled by a crowd controller.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

export(int, 0, 2) var team: int = 0 setget set_team, get_team

const MIN_SIT_DOWN_TIME := 0.05
const MAX_SIT_DOWN_TIME := 0.35

func set_team(new_value: int) -> void:
	team = new_value
	self.frame_coords.x = team


func get_team() -> int:
	return team


func _ready() -> void:
	if !Engine.editor_hint:
		self.add_to_group(Globals.CROWD_GROUP)

		if team == 1:
			self.add_to_group(Globals.HOME_CROWD_GROUP)
		elif team == 2:
			self.add_to_group(Globals.AWAY_CROWD_GROUP)

		self._randomize_appearance()

	


func sit() -> void:
	yield(get_tree().create_timer(_get_clamped_random_float()), "timeout")
	self.frame_coords.y = 0
	$Head.set_position(Vector2(0.0, -18.0))


func is_sitting() -> bool:
	return self.frame_coords.y == 0


func stand() -> void:
	self.frame_coords.y = 1
	$Head.set_position(Vector2(0.0, -34))


func is_standing() -> bool:
	return self.frame_coords.y == 1


func jump() -> void:
	yield(get_tree().create_timer(_get_clamped_random_float()), "timeout")
	if(is_sitting()): return
	self.frame_coords.y = 2
	$Head.set_position(Vector2(0.0, -40))


func is_jumping() -> bool:
	return self.frame_coords.y == 2


func lean_left() -> void:
	yield(get_tree().create_timer(_get_clamped_random_float()), "timeout")
	if(is_sitting()): return
	self.frame_coords.y = 3
	$Head.set_position(Vector2(-2.0, -34))


func is_leaning_left() -> bool:
	return self.frame_coords.y == 3


func lean_right() -> void:
	yield(get_tree().create_timer(_get_clamped_random_float()), "timeout")
	if(is_sitting()): return
	self.frame_coords.y = 4
	$Head.set_position(Vector2(2.0, -34))


func is_leaning_right() -> bool:
	return self.frame_coords.y == 4


func cheer() -> void:
	if self.is_cheering():
		return
	
	
	yield(get_tree().create_timer(_get_clamped_random_float()), "timeout")
	self.stand()
	$Head.frame_coords.y += 1


func stop_cheering() -> void:
	if !self.is_cheering():
		return
	
	$Head.frame_coords.y -= 1
	self.sit()


func is_cheering() -> bool:
	return int($Head.frame_coords.y) % 2 == 1


func change_cheer_anim() -> void:
	match Globals.rng.randi_range(0, 2):
		0:
			self.jump()
		1:
			self.lean_left()
		2:
			self.lean_right()


func _randomize_appearance() -> void:
	$Head.frame_coords.x = Globals.rng.randi_range(0, $Head.get_hframes() - 1)
	$Head.frame_coords.y = Globals.rng.randi_range(0, 3) * 2
	
	var num_frames: int = ($Head/Hair.get_hframes() * $Head/Hair.get_vframes()) - 1
	$Head/Hair.set_frame(Globals.rng.randi_range(0, num_frames))

func _get_clamped_random_float():
	var delay = clamp(randf(), MIN_SIT_DOWN_TIME, MAX_SIT_DOWN_TIME)
	return delay;
