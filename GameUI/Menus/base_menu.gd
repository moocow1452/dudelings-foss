class_name BaseMenu
extends Control
# Abstract class for all menus.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

onready var _previous_focus_owner: Node = self.get_focus_owner()


func _init() -> void:
	self.add_to_group(Globals.MENU_GROUP)


func queue_free() -> void:
	if self.is_in_group(Globals.MENU_GROUP):
		self.remove_from_group(Globals.MENU_GROUP)  # Remove from group BEFORE queue_free so it's not referenced on close.

	if is_instance_valid(_previous_focus_owner):
		_previous_focus_owner.call_deferred("grab_focus")
	
	.queue_free()
