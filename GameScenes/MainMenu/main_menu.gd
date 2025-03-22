class_name MainMenu
extends Node
# The main menu scene for Dudelings.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element
const HOW_TO_PLAY_SUB_MENU_SCENE: PackedScene = preload("res://GameUI/Menus/SubMenus/HowToPlaySubMenu/HowToPlaySubMenu.tscn")
const SETTINGS_SUB_MENU_SCENE: PackedScene = preload("res://GameUI/Menus/SubMenus/SettingsSubMenu/SettingsSubMenu.tscn")
const STATS_SUB_MENU_SCENE: PackedScene = preload("res://GameUI/Menus/SubMenus/StatsSubMenu/StatsSubMenu.tscn")
const WHATS_NEW_SUB_MENU_SCENE: PackedScene = preload("res://GameUI/Menus/SubMenus/WhatsNewSubMenu/WhatsNewSubMenu.tscn")

const CONFIRM_MESSAGE_SCENE: PackedScene = preload("res://GameUI/Menus/SubMenus/ConfirmMessage/ConfirmMessageLanding.tscn")
onready var version_number_display := $DudelingsLogo/BuildVersionLabel

func _ready() -> void:
	self.add_to_group(Globals.MENU_GROUP)  # This scene counts as a menu.
	var version_number = Globals.DUDELINGS_VERSION_NUMBER
	if Globals.IS_DEMO:
		version_number = version_number + " DEMO"
	version_number_display.text = version_number
	var _a = $ButtonElements/PlayButtonElement.connect("pressed", self, "_on_PlayButtonElement_pressed")
	var _b = $ButtonElements/HowToPlayButtonElement.connect("pressed", self, "_on_HowToPlayButtonElement_pressed")
	var _c = $ButtonElements/SettingsButtonElement.connect("pressed", self, "_on_SettingsButtonElement_pressed")
	var _d = $ButtonElements/ExitButtonElement.connect("pressed", self, "_on_ExitButtonElement_pressed")
	var _e = $ButtonElements/StatsButtonElement.connect("pressed", self, "_on_StatsButtonElement_pressed")
	var _f = $ButtonElements/WhatsNewButtonElement.connect("pressed", self, "_on_WhatsNewButtonElement_pressed")
	var _g = $GameNotification.connect("notification_updated", self, "handle_whats_new_indicator")

	var animation_player = $CanvasLayer/AnimatedBackground.get_node("AnimationPlayer")
	animation_player.play("SlideshowNoDestination")

	# Only play music if it is not already playing from splash screen intro.
	if SceneController.get_last_scene_id() != SceneController.GameSceneId.SPLASH_SCREEN:
		AudioController.play_song(AudioController.MAIN_THEME_MUSIC, true)
	
	$ButtonElements/PlayButtonElement.call_deferred("grab_focus")

	SceneController.call_deferred("fade_out")

func handle_whats_new_indicator() -> void:
	if !DisplayController.seen_whats_new_dialog:
		# yield(get_tree().create_timer(5), "timeout")
		_on_WhatsNewButtonElement_pressed()
	if "code" in Globals.hE_announcements:
		var confirm_message: ConfirmMessage = CONFIRM_MESSAGE_SCENE.instance()
		get_tree().root.add_child(confirm_message)
		var _a = confirm_message.connect("confirmed", confirm_message, "queue_free")
		confirm_message.cancel_button_label("CANCEL")
		confirm_message.confirm_button_label("OKAY")

		confirm_message.show_message("FAILURE", "A %s error occurred when requesting news from the remote server. If this issue persists, please let us know at https://heavyelement.com/support" % Globals.hE_announcements.code)
		
		return;
	if !Globals.hE_announcements: return;
	for announce in Globals.hE_announcements:
		#if "id" in announce == false:
			#continue
		if GameSettingsData.has_seen_notification(announce.id) == false: 
			$ButtonElements/WhatsNewButtonElement/UnseenNotification.visible = true
			return
	$ButtonElements/WhatsNewButtonElement/UnseenNotification.visible = false


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	pass  # Do nothing. Still needed.


func _disable_button_elements(disable_buttons: bool) -> void:
	for button in $ButtonElements.get_children():
		button.call_deferred("set_disabled", disable_buttons)


## Button Actions.

func _on_PlayButtonElement_pressed() -> void:
	SceneController.go_to_scene(SceneController.GameSceneId.GAME_OPTIONS)


func _on_HowToPlayButtonElement_pressed() -> void:
	self._disable_button_elements(true)

	var sub_menu: HowToPlaySubMenu = HOW_TO_PLAY_SUB_MENU_SCENE.instance()
	self.add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "_disable_button_elements", [false])


func _on_SettingsButtonElement_pressed() -> void:
	self._disable_button_elements(true)

	var sub_menu: SettingsSubMenu = SETTINGS_SUB_MENU_SCENE.instance()
	self.add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "_disable_button_elements", [false])


func _on_ExitButtonElement_pressed() -> void:
	var confirm_message: ConfirmMessage = CONFIRM_MESSAGE_SCENE.instance()
	self.add_child(confirm_message)
	var _a = confirm_message.connect("confirmed", self, "_exit_application")
	confirm_message.cancel_button_label("CANCEL")
	confirm_message.confirm_button_label("QUIT")

	confirm_message.show_message("QUIT DUDELINGS", "[center]Are you sure you want to quit?[center]")
	pass

func _exit_application() -> void:
	for button in $ButtonElements.get_children():
		button.set_deferred("disabled", true)

	var _a = AudioController._ui_sound_player.connect("finished", Globals, "quit_application")

func _on_StatsButtonElement_pressed() -> void:
	self._disable_button_elements(true)

	var sub_menu: StatsSubMenu = STATS_SUB_MENU_SCENE.instance()
	self.add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "_disable_button_elements", [false])

func _on_WhatsNewButtonElement_pressed() -> void:
	self._disable_button_elements(true)

	var sub_menu: WhatsNewSubMenu = WHATS_NEW_SUB_MENU_SCENE.instance()
	self.add_child(sub_menu)
	# var _zz = sub_menu.connect("sub_menu_closed", self, " _disable_button_elements")
	yield(sub_menu, "sub_menu_closed")
	GameSettingsData.save_game_setting(GameSettingsData.DISPLAY_SECTION, Globals.SEEN_WHATS_NEW_KEY, true)
	_disable_button_elements(false)
