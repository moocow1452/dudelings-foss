class_name ButtonElement
extends BaseButton
# A custom button with extra features.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element
const FOCUSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_focused.ogg")
const PRESSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_pressed.ogg")
const DISABLED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_disabled.ogg")

var _focused_sound: AudioStreamOGGVorbis = FOCUSED_SOUND


func _init() -> void:
	var _a = self.connect("focus_entered", self, "_on_focus_entered")
	var _b = self.connect("mouse_entered", self, "_on_mouse_entered")
	var _c = self.connect("pressed", self, "_on_pressed")


func grab_focus() -> void:
	_focused_sound = null
	.grab_focus()
	_focused_sound = FOCUSED_SOUND


func _update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().hide_all()

	InputController.button_context_bar().show_select()

	if is_instance_valid(Globals.focused_menu()):
		Globals.focused_menu().update_button_context_bar()


func _on_focus_entered() -> void:
	AudioController.play_ui_sound(_focused_sound)
	self._update_button_context_bar()


func _on_mouse_entered() -> void:
	AudioController.play_ui_sound(_focused_sound)
	self.call_deferred("grab_focus")


func _on_pressed() -> void:
	AudioController.play_ui_sound(DISABLED_SOUND if self.is_disabled() else PRESSED_SOUND)
