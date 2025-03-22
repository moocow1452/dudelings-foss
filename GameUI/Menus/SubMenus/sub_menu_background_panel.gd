class_name SubMenuBackgroundPanel
extends Panel
# A panel style background for image selection.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal clicked_outside

export(bool) var _allow_click_outside: bool = true setget set_allow_click_outside


func set_allow_click_outside(new_value: bool) -> void:
	_allow_click_outside = new_value


func _process(_delta: float) -> void:
	if Globals.focused_menu() != self.get_parent():
		return
	
	if Input.is_action_just_pressed("ui_left_click") && _allow_click_outside:
		if self.get_global_rect().has_point(self.get_global_mouse_position()):
			return
		
		Globals.get_tree().set_input_as_handled()
		self.emit_signal("clicked_outside")
