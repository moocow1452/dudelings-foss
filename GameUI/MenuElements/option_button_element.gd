class_name OptionButtonElement
extends OptionButton
# A custom otpion button with extra features.

const FOCUSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_focused.ogg")
const PRESSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_pressed.ogg")
const DISABLED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_disabled.ogg")

var _focused_sound: AudioStreamOGGVorbis = FOCUSED_SOUND


func _init() -> void:
	var _a = self.connect("focus_entered", self, "_on_focus_entered")
	var _b = self.connect("toggled", self, "_on_toggled")
	var _c = self.connect("mouse_entered", self, "_on_mouse_entered")
	var _d = self.get_popup().connect("about_to_show", self, "_on_popup_about_to_show")

	self.get_popup().set_script(PopupMenuElement)


func grab_focus() -> void:
	_focused_sound = null
	.grab_focus()
	_focused_sound = FOCUSED_SOUND

# func _input(event):
# 	if(event.is_action_pressed("ui_cancel")):
# 		self.get_popup().clear()
# 		Globals.get_tree().set_input_as_handled()
# 	pass

func _update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return

	InputController.button_context_bar().hide_all()
	
	InputController.button_context_bar().show_select("OPEN")

	if is_instance_valid(Globals.focused_menu()):
		Globals.focused_menu().update_button_context_bar()


func _on_focus_entered() -> void:
	AudioController.play_ui_sound(_focused_sound)
	self._update_button_context_bar()


func _on_toggled(_button_pressed: bool) -> void:
	AudioController.play_ui_sound(DISABLED_SOUND if self.is_disabled() else PRESSED_SOUND)


func _on_mouse_entered() -> void:
	AudioController.play_ui_sound(_focused_sound)
	self.call_deferred("grab_focus")


func _on_popup_about_to_show() -> void:
	# Open popup menu above button.
	if self.get_global_position().y > 360.0:
		self.get_popup().rect_global_position += Vector2(7.0, -self.get_rect().size.y - self.get_popup().get_rect().size.y - 2.0)
	# Open popup menu below button.
	else:
		self.get_popup().rect_global_position += Vector2(-7.0, 2.0)

	InputController.button_context_bar().call_deferred("show_close")
