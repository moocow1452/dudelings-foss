class_name VolumeLevelsSubMenu
extends SubMenu
# A sub menu for showing and changing volume settings.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

onready var _master_volume_slider: SliderElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/MasterVolumeSliderElement
onready var _music_volume_slider: SliderElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/MusicVolumeSliderElement
onready var _announcer_volume_slider: SliderElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/AnnouncerVolumeSliderElement
onready var _sound_volume_slider: SliderElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/SoundVolumeSliderElement
onready var _ui_volume_silder: SliderElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/UIVolumeSliderElement


func _ready() -> void:
	# Call this before connecting signals to avoid triggering them.
	self._update_menu()

	# Connect signals.
	var _z = $BackgroundPanel.connect("clicked_outside", self, "queue_free")

	var _a = _master_volume_slider.connect("value_changed", self, "_on_MasterVolumeSliderElement_value_changed")
	var _b = _music_volume_slider.connect("value_changed", self, "_on_MusicVolumeSliderElement_value_changed")
	var _c = _announcer_volume_slider.connect("value_changed", self, "_on_AnnouncerVolumeSliderElement_value_changed")
	var _d = _sound_volume_slider.connect("value_changed", self, "_on_SoundVolumeSliderElement_value_changed")
	var _e = _ui_volume_silder.connect("value_changed", self, "_on_UIVolumeSliderElement_value_changed")

	_master_volume_slider.call_deferred("grab_focus")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	if Input.is_action_just_pressed("ui_reset"):
		Globals.get_tree().set_input_as_handled()
		self._reset_settings()


func _update_menu() -> void:
	_master_volume_slider.set_value(AudioController.db_to_percent(AudioController.get_master_volume_db()) * 100.0)
	_music_volume_slider.set_value(AudioController.db_to_percent(AudioController.get_music_volume_db()) * 100.0)
	_announcer_volume_slider.set_value(AudioController.db_to_percent(AudioController.get_announcer_volume_db()) * 100.0)
	_sound_volume_slider.set_value(AudioController.db_to_percent(AudioController.get_sound_volume_db()) * 100.0)
	_ui_volume_silder.set_value(AudioController.db_to_percent(AudioController.get_ui_volume_db()) * 100.0)


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_reset()
	InputController.button_context_bar().show_close("BACK")


func _reset_settings() -> void:
	AudioController.reset_audio_settings()
	self._update_menu()


## Button Actions.

func _on_MasterVolumeSliderElement_value_changed(value: float) -> void:
	if value == AudioController.db_to_percent(AudioController.get_master_volume_db()):
		return

	AudioController.set_master_volume_db(AudioController.percent_to_db(value / 100.0))


func _on_MusicVolumeSliderElement_value_changed(value: float) -> void:
	if value == AudioController.db_to_percent(AudioController.get_music_volume_db()):
		return

	AudioController.set_music_volume_db(AudioController.percent_to_db(value / 100.0))


func _on_AnnouncerVolumeSliderElement_value_changed(value: float) -> void:
	if value == AudioController.db_to_percent(AudioController.get_announcer_volume_db()):
		return

	AudioController.set_announcer_volume_db(AudioController.percent_to_db(value / 100.0))
	AudioController.get_announcer_system().make_announcement(AnnouncerSystem.AnnouncementType.INTERRUPT, false, true)


func _on_SoundVolumeSliderElement_value_changed(value: float) -> void:
	if value == AudioController.db_to_percent(AudioController.get_sound_volume_db()):
		return

	AudioController.set_sound_volume_db(AudioController.percent_to_db(value / 100.0))
	AudioController.play_universal_sound(ArenaPickup.SPAWNED_SOUND, AudioController.PITCH_SHIFT_MEDIUM)


func _on_UIVolumeSliderElement_value_changed(value: float) -> void:
	if value == AudioController.db_to_percent(AudioController.get_ui_volume_db()):
		return

	AudioController.set_ui_volume_db(AudioController.percent_to_db(value / 100.0))
