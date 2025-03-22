class_name SubMenu
extends BaseMenu
# Abstract class for Sub Menu panels.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal sub_menu_closed()

var _close_action_string: String = "ui_cancel"


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	# if Input.is_action_just_pressed(_close_action_string):
	# 	Globals.get_tree().set_input_as_handled()
	# 	self._menu_close_action()

func _unhandled_input(_event):
	if(Input.is_action_just_pressed(_close_action_string)):
		Globals.get_tree().set_input_as_handled()
		self._menu_close_action()

func queue_free() -> void:
	self.emit_signal("sub_menu_closed")
	.queue_free()


func _menu_close_action() -> void:
	self.queue_free()
