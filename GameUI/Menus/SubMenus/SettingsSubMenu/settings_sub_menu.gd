class_name SettingsSubMenu
extends SubMenu
# A sub menu for showing and changing game settings.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const VOLUME_LEVELS_SUB_MENU_SCENE: PackedScene = preload("../VolumeLevelsSubMenu/VolumeLevelsSubMenu.tscn")
const CREDITS_SUB_MENU_SCENE: PackedScene = preload("res://GameUI/Menus/SubMenus/CreditsSubMenu/CreditsSubMenu.tscn")

onready var _crt_filter_check_button: CheckButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/CRTFilterCheckButtonElement
onready var _fullscreen_check_button: CheckButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/FullscreenCheckButtonElement
onready var _borderless_check_button: CheckButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/BorderlessCheckButtonElement
onready var _screen_shake_check_button: CheckButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/ScreenShakeCheckButtonElement
onready var _controller_vibration_check_button: CheckButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/ControllerVibrationCheckButtonElement
onready var _volume_levels_button: ButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/VolumeLevelsButtonElement
onready var _announcer_option_button: OptionButton = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/Announcer/OptionButtonElement
onready var _jersey_option_button: OptionButton = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/Jersey/OptionButtonElement
onready var _credits_button: ButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/CreditsButtonElement
onready var _virtual_gamepad: CheckButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/VirtualControllerButtonElement
onready var _telemetry_button: ButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/TelemetryCollectCheck
onready var _delete_usage_data: ButtonElement = $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/TelemetryDeleteButton

var confirm_message

func _ready() -> void:
	# Call before connecting signals to avoid triggering them.
	_announcer_option_button.add_item("Gardiner", 0)
	_announcer_option_button.add_item("Emily", 1)
	_announcer_option_button.add_item("Bill", 2)
	_announcer_option_button.add_item("Rich", 3)

	_jersey_option_button.add_item("Soccer", 0)
	_jersey_option_button.add_item("Volleyball", 1)
	_jersey_option_button.add_item("Football", 2)
	_jersey_option_button.add_item("Rugby", 3)
	_jersey_option_button.add_item("Water Polo", 4)
	_jersey_option_button.add_item("Tennis", 5)
	_jersey_option_button.add_item("Hockey", 6)
	_jersey_option_button.add_item("Bowling", 7)

	self._update_menu()

	# Connect signals.
	var _z = $BackgroundPanel.connect("clicked_outside", self, "queue_free")

	var _a = _fullscreen_check_button.connect("toggled", self, "_on_FullscreenCheckButtonElement_toggled")
	var _b = _borderless_check_button.connect("toggled", self, "_on_BorderlessCheckButtonElement_toggled")
	var _c = _screen_shake_check_button.connect("toggled", self, "_on_ScreenShakeCheckButtonElement_toggled")
	var _d = _controller_vibration_check_button.connect("toggled", self, "_on_ControllerVibrationCheckButtonElement_toggled")
	var _e = _volume_levels_button.connect("pressed", self, "_on_VolumeLevelsButtonElement_pressed")
	var _f = _announcer_option_button.connect("item_selected", self, "_on_AnnouncerOptionButtonElement_item_selected")
	var _g = _credits_button.connect("pressed", self, "_on_CreditsButtonElement_pressed")
	var _h = _crt_filter_check_button.connect("toggled", self, "_on_CrtButton_pressed")
	var _i = _jersey_option_button.connect("item_selected", self, "_on_JerseyButtonElement_item_selected")
	var _j = _volume_levels_button.connect("focus_entered", self, "_on_first_item_focused")
	var _k = _telemetry_button.connect("toggled", self, "_on_telemetry_toggled")
	var _l = _virtual_gamepad.connect("toggled", self, "_on_virtual_gamepad_toggled")
	var _m = _delete_usage_data.connect("pressed", self, "_on_delete_usage_data")
	
	_volume_levels_button.call_deferred("grab_focus")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	if Input.is_action_just_pressed("ui_reset"):
		Globals.get_tree().set_input_as_handled()
		self._reset_settings()


func _update_menu() -> void:
	_crt_filter_check_button.set_pressed(DisplayController.scanline_filter_enabled)
	_fullscreen_check_button.set_pressed(DisplayController.is_fullscreen())
	_borderless_check_button.set_pressed(DisplayController.is_borderless())
	_screen_shake_check_button.set_pressed(DisplayController.get_screen_shake_enabled())
	_controller_vibration_check_button.set_pressed(InputController.get_controller_vibration_enabled())
	_announcer_option_button.select(AudioController.get_announcer_voice())
	_jersey_option_button.select(GameplayController.dudeling_jersey_index)
	_telemetry_button.set_pressed(Globals.telemetry)


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_reset()
	InputController.button_context_bar().show_close()


func _reset_settings() -> void:
	DisplayController.reset_display_settings()
	InputController.reset_input_settings()
	AudioController.set_announcer_voice(AudioController.DEFAULT_ANNOUNCER_VOICE)
	self._update_menu()


func _play_announcer_test_audio() -> void:
	AudioController.get_announcer_system().make_announcement(AnnouncerSystem.AnnouncementType.INTERRUPT, false, true)

## Button Actions.

func _on_FullscreenCheckButtonElement_toggled(button_pressed: bool) -> void:
	DisplayController.window_is_fullscreen(button_pressed)
	InputController.show_mouse_pointer(false)  # This updated the pointer to the new screen rules.


func _on_BorderlessCheckButtonElement_toggled(button_pressed: bool) -> void:
	DisplayController.window_is_borderless(button_pressed)
	InputController.show_mouse_pointer(false)  # This updated the pointer to the new screen rules.

func _on_telemetry_toggled(button_pressed: bool) -> void:
	GameSettingsData.save_game_setting(GameSettingsData.NOTIFICATION, "telemetry", button_pressed)
	Globals.telemetry = button_pressed

func _on_ScreenShakeCheckButtonElement_toggled(button_pressed: bool) -> void:
	DisplayController.set_screen_shake_enabled(button_pressed)


func _on_ControllerVibrationCheckButtonElement_toggled(button_pressed: bool) -> void:
	InputController.set_controller_vibration_enabled(button_pressed)

func _on_CrtButton_pressed(button_pressed: bool) -> void:
	DisplayController.scanline_filter_enabled = button_pressed
	DisplayController.scanline_node()

func _on_VolumeLevelsButtonElement_pressed() -> void:
	var sub_menu: VolumeLevelsSubMenu = VOLUME_LEVELS_SUB_MENU_SCENE.instance()
	self.get_parent().add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "show")
	self.hide()


func _on_AnnouncerOptionButtonElement_item_selected(index: int) -> void:
	if Globals.IS_DEMO && index != 0:
		index = 0;
		Globals._demo_check()
		self._announcer_option_button.selected = 0
		return;
	AudioController.set_announcer_voice(index)
	self._play_announcer_test_audio()


func _on_CreditsButtonElement_pressed() -> void:
	var sub_menu: CreditsSubMenu = CREDITS_SUB_MENU_SCENE.instance()
	self.get_parent().add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "show")
	self.hide()

func _on_JerseyButtonElement_item_selected(index) -> void:
	if Globals.IS_DEMO && index != 0:
		index = 0;
		Globals._demo_check()
		self._jersey_option_button.selected = 0
		return
	GameplayController.set_dudeling_jersey_index(index)
	GameSettingsData.save_game_setting(GameSettingsData.DISPLAY_SECTION, "dudeling_jersey_index", index)

func _on_first_item_focused() -> void:
	$BackgroundPanel/MenuContainer/ScrollContainer.scroll_vertical = 0


func _on_virtual_gamepad_toggled(value: bool) -> void:
	DisplayController.set_virtual_gamepad(value, true)

func _on_delete_usage_data() -> void:
	var request = HTTPRequest.new()
	self.add_child(request)
	var cfm = load("res://GameUI/Menus/SubMenus/ConfirmMessage/ConfirmMessageLanding.tscn")
	confirm_message = cfm.instance()
	self.add_child(confirm_message)
	confirm_message.call_deferred("grab_focus")
	confirm_message.show_message("WORKING...", "Once second while we remove any relevant records")
	confirm_message._message_text.bbcode_enabled = true
	confirm_message.confirm_button_label("Wait...")
	confirm_message._confirm_button.disabled = true
	confirm_message._cancel_button.queue_free()
	var uri = "%s/privacy/delete/%s" % [Globals.HE_WEBSITE, Globals.ident]
	request.connect("request_completed", self, "_on_request_completed")
	request.request(uri, [], true, HTTPClient.METHOD_POST, "")
	print("Delete request sent: %s" % uri)

func _on_request_completed(_result, _response_code, _headers, _body) -> void:
	var response_as_string = _body.get_string_from_utf8()
	var response_parsed = JSON.parse(response_as_string)
	var response_body = response_parsed.result
	confirm_message._confirm_button.disabled = false
	if(_response_code != 200):
		confirm_message.confirm_button_label("Okay")
		confirm_message._header_text.text = "ERROR"
		confirm_message._message_text.bbcode_text = response_body.error if response_body.error else "An unknown error occurred";

		return
	var timer = get_tree().create_timer(1.5)

	yield(timer, "timeout")

	confirm_message._header_text.text = "SUCCESS"
	confirm_message.confirm_button_label("Okay")
	var was = "were"
	var plural = "s"
	if(response_body == 1): 
		was = "was"
		plural = ""
	confirm_message._message_text.bbcode_text = "%s record%s %s deleted.\n\nWe've shut off \"Submit Usage Statistics\" for you so no further information will be submitted." % [response_body, plural, was];
	if _telemetry_button.pressed:
		_telemetry_button.pressed = false
		_on_telemetry_toggled(false)
		
	
