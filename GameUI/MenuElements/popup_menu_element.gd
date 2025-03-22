class_name PopupMenuElement
extends PopupMenu
# A custom popup with extra features.

const FOCUSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_focused.ogg")
const PRESSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_pressed.ogg")
const DISABLED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_disabled.ogg")

var _focused_sound: AudioStreamOGGVorbis = FOCUSED_SOUND


func _init() -> void:
	var _a = self.connect("about_to_show", self, "_on_about_to_show")
	var _b = self.connect("id_focused", self, "_on_id_focused")
	var _c = self.connect("id_pressed", self, "_on_popup_id_pressed")


func _update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().hide_all()

	InputController.button_context_bar().show_select()
	InputController.button_context_bar().show_close()

	if is_instance_valid(Globals.focused_menu()):
		Globals.focused_menu().update_button_context_bar()


func _on_about_to_show() -> void:
	self._update_button_context_bar()


func _on_id_focused(_id: int) -> void:
	AudioController.play_ui_sound(_focused_sound)


func _on_popup_id_pressed(id: int) -> void:
	AudioController.play_ui_sound(DISABLED_SOUND if self.is_item_disabled(id) else PRESSED_SOUND)
