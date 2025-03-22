class_name SelectorArrowElement
extends ButtonElement
# A button element that connects to a selector element for scrolling.

const WAIT_TIME: float = 0.5
const SCROLL_SPEED: float = 0.2
const FOCUS_SCALE: Vector2 = Vector2(1.5, 1.5)

var _press_timer: Timer = self._make_press_timer()


func _init() -> void:
	var _a = self.connect("focus_exited", self, "_on_focus_exited")
	var _b = self.connect("button_down", self, "_on_button_down")
	var _c = self.connect("button_up", self, "_on_button_up")


func _update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().hide_all()

	InputController.button_context_bar().show_select("CHANGE")

	if is_instance_valid(Globals.focused_menu()):
		Globals.focused_menu().update_button_context_bar()


func _make_press_timer() -> Timer:
	var press_timer := Timer.new()
	self.add_child(press_timer)
	press_timer.set_pause_mode(PAUSE_MODE_PROCESS)
	press_timer.set_one_shot(true)
	var _a = press_timer.connect("timeout", self, "_on_press_timer_timeout")
	return press_timer


func _on_press_timer_timeout() -> void:
	if !self.is_pressed():
		return

	self.emit_signal("pressed")
	_press_timer.start(SCROLL_SPEED)


func _on_focus_entered() -> void:
	self.set_scale(FOCUS_SCALE)
	._on_focus_entered()


func _on_focus_exited() -> void:
	self.set_scale(Vector2(1.0, 1.0))


func _on_button_down() -> void:
	_press_timer.start(WAIT_TIME)


func _on_button_up() -> void:
	_press_timer.stop()
