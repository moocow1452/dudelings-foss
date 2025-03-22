tool
class_name StadiumStand
extends Node2D
# A stand full of mini dudelings.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

export(int, 0, 100) var crowd_density: int = 20 setget set_crowd_density, get_crowd_density # Larger number = lower crowd density
export(bool) var flip_stand: bool = false setget set_flip_stand, get_flip_stand
export(int, 0, 2) var team: int = 0 setget set_team, get_team
export(bool) var show_stands: bool = true setget set_seats_visible, get_seats_visible
export(int, 0, 100) var team_assignment_threshold: int = 20

func set_flip_stand(new_value: bool) -> void:
	flip_stand = new_value

	$Railing.set_flip_h(new_value)
	$Seats.set_flip_h(new_value)


func get_flip_stand() -> bool:
	return flip_stand


func set_team(new_value: int) -> void:
	team = new_value
	
	for each in $MiniDudelings.get_children():
		each.set_team(team)


func get_team() -> int:
	return team


func _ready() -> void:
	if !Engine.editor_hint:
		for each in $MiniDudelings.get_children():
			# Delete all mini dudelings that are not on the screen
			if each.get_global_position().x < 0.0 || each.get_global_position().x > 1280.0:
				each.queue_free()

			if Globals.rng.randf() <= crowd_density * .01:
				each.queue_free()
			elif Globals.rng.randf() <= team_assignment_threshold * .01:
				each.set_team(0)


func cheer(cheer_time: float) -> void:
	for each in $MiniDudelings.get_children():
		each.cheer(cheer_time)


func stop_cheering() -> void:
	for each in $MiniDudelings.get_children():
		each.stop_cheering()


func is_cheering() -> bool:
	for each in $MiniDudelings.get_children():
		if each.is_cheering():
			return true

	return false


func sit() -> void:
	for each in $MiniDudelings.get_children():
		each.sit()


func is_sitting() -> bool:
	for each in $MiniDudelings.get_children():
		if each.is_sitting():
			return true
	
	return false


func stand() -> void:
	for each in $MiniDudelings.get_children():
		each.stand()


func is_standing() -> bool:
	for each in $MiniDudelings.get_children():
		if each.is_standing():
			return true
	
	return false

func set_seats_visible(value: bool) -> void:
	show_stands = value
	$Railing.visible = value
	$Seats.visible = value

func get_seats_visible() -> bool:
	return show_stands;

func set_crowd_density(value) -> void:
	crowd_density = value

func get_crowd_density() -> int:
	return crowd_density