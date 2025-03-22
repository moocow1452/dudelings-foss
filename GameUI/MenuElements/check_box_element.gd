class_name CheckBoxElement
extends ButtonElement
# A custom check box with extra features.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element

func _update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().hide_all()

	InputController.button_context_bar().show_select("TOGGLE")
	
	if is_instance_valid(Globals.focused_menu()):
		Globals.focused_menu().update_button_context_bar()
