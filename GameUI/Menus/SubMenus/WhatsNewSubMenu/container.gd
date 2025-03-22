tool
signal show_announcement(announcement)
extends Container
# A script for displaying the What's New screen
#
# @author gbryant
# @copyright 2024 Heavy Element


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _show_announcement(announcement, button) -> void:
	for btn in self.get_children():
		btn.pressed = false
	
	button.pressed = true
	self.emit_signal("show_announcement", announcement)
