class_name ButtonContextBar
extends HBoxContainer
# A display that shows the current button options for the focused menu object.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element
var _last_input_type: int = -1


func _init() -> void:
	self.add_to_group(Globals.BUTTON_CONTEXT_BAR_GROUP)


func _ready() -> void:
	var _a = self.get_parent().connect("child_entered_tree", self, "_on_child_entered_tree")
	var _b = self.connect("tree_exited", self, "_on_tree_exited")

	self.hide_all()
	self._update_controller_type()
	
	# Delay updating images to prevent flickering between types.
	var update_delay_timer := Timer.new()
	self.add_child(update_delay_timer)
	update_delay_timer.set_pause_mode(PAUSE_MODE_PROCESS)
	update_delay_timer.set_one_shot(false)
	var _c = update_delay_timer.connect("timeout", self, "_update_controller_type")
	update_delay_timer.start(0.1)


# Do not accept input. Allow it to pass through.
func _input(event: InputEvent) -> void:
	InputController.show_mouse_pointer(event is InputEventMouse)

	if event is InputEventKey || event is InputEventMouse:
		_last_input_type = InputController.ControllerType.KEYBOARD
	elif event is InputEventJoypadButton || InputEventJoypadMotion:
		_last_input_type = InputController.guess_controller_type(event.get_device())


func hide_all() -> void:
	$SelectContextOption.hide()
	$CloseContextOption.hide()
	$LeftContextOption.hide()
	$RightContextOption.hide()
	$UpContextOption.hide()
	$DownContextOption.hide()
	$ResetContextOption.hide()
	$RandomizeContextOption.hide()
	$SubMenuContextOption.hide()


func show_select(text: String = "SELECT") -> void:
	$SelectContextOption.set_context_label(text)
	$SelectContextOption.show()


func show_close(text: String = "CLOSE") -> void:
	$CloseContextOption.set_context_label(text)
	$CloseContextOption.show()


func show_left(text: String = "DOWN") -> void:
	$LeftContextOption.set_context_label(text)
	$LeftContextOption.show()


func show_right(text: String = "UP") -> void:
	$RightContextOption.set_context_label(text)
	$RightContextOption.show()


func show_up(text: String = "UP") -> void:
	$UpContextOption.set_context_label(text)
	$UpContextOption.show()


func show_down(text: String = "DOWN") -> void:
	$DownContextOption.set_context_label(text)
	$DownContextOption.show()


func show_reset(text: String = "RESET") -> void:
	$ResetContextOption.set_context_label(text)
	$ResetContextOption.show()


func show_randomize(text: String = "RANDOM") -> void:
	$RandomizeContextOption.set_context_label(text)
	$RandomizeContextOption.show()


func show_sub_menu(text: String = "SUB MENU") -> void:
	$SubMenuContextOption.set_context_label(text)
	$SubMenuContextOption.show()


func _update_controller_type() -> void:
	self.set_visible(_last_input_type > -1)

	for context_option in self.get_children():
		if context_option is ContextOption:
			context_option.update_controller_type(_last_input_type)


func _on_child_entered_tree(_node: Node) -> void:
	self.get_parent().move_child(self, self.get_parent().get_child_count() - 1)  # Always keep self on top to allow for input checking.


func _on_tree_exited() -> void:
	self.set_process_input(false)
	InputController.show_mouse_pointer(false)
