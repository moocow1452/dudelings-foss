tool
class_name SliderElement
extends Slider
# A custom slider with extra features.

const FOCUSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_focused.ogg")
const PRESSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_pressed.ogg")
const DISABLED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_disabled.ogg")

export(String) var text = "TEXT" setget set_text
export(bool) var play_pressed_sound: bool = true setget set_play_pressed_sound, get_play_pressed_sound

var _focused_sound: AudioStreamOGGVorbis = FOCUSED_SOUND


func set_text(new_value: String) -> void:
	text = new_value
	$HeaderLabel.set_text(text)


func set_play_pressed_sound(new_value: bool) -> void:
	play_pressed_sound = new_value


func get_play_pressed_sound() -> bool:
	return play_pressed_sound


func _init() -> void:
	if !Engine.editor_hint:
		var _a = self.connect("focus_entered", self, "_on_focus_entered")
		var _b = self.connect("focus_exited", self, "_on_focus_exited")
		var _c = self.connect("value_changed", self, "_on_value_changed")
		var _d = self.connect("mouse_entered", self, "_on_mouse_entered")


func _ready() -> void:
	if !Engine.editor_hint:
		$BackgroundPanel.set_visible(false)


func grab_focus() -> void:
	_focused_sound = null
	.grab_focus()
	_focused_sound = FOCUSED_SOUND


func _update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().hide_all()
	
	InputController.button_context_bar().show_left()
	InputController.button_context_bar().show_right()

	if is_instance_valid(Globals.focused_menu()):
		Globals.focused_menu().update_button_context_bar()


func _on_focus_entered() -> void:
	$BackgroundPanel.set_visible(true)
	AudioController.play_ui_sound(_focused_sound)
	self._update_button_context_bar()


func _on_focus_exited() -> void:
	$BackgroundPanel.set_visible(false)


func _on_value_changed(value: float) -> void:
	$SubLabel.set_text(str(value) + "%")

	if play_pressed_sound:
		AudioController.play_ui_sound(DISABLED_SOUND if !self.is_editable() else PRESSED_SOUND)


func _on_mouse_entered() -> void:
	AudioController.play_ui_sound(_focused_sound)
	self.call_deferred("grab_focus")
