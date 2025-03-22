class_name CheckButtonElement
extends ButtonElement
# A custom check button with extra features.


func _update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().hide_all()

	InputController.button_context_bar().show_select("TOGGLE")

	if is_instance_valid(Globals.focused_menu()):
		Globals.focused_menu().update_button_context_bar()
