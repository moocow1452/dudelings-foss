class_name GameSettingsData
extends ConfigDataParser
# This class saves, loads, and resets game settings data.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element

const GAME_SETTINGS_FILE_PATH: String = "user://game_settings.dat"
const AUDIO_SECTION: String = "audio"
const DISPLAY_SECTION: String = "display"
const INPUT_SECTION: String = "input"
const STATS_SECTION: String = "stats"
const PRIMARY_BENEFACTOR: String = "benefactor"
const NOTIFICATION: String = "notifications"

static func save_game_setting(file_section: String, data_key: String, target_value) -> void:
	store_config_data(file_section, data_key, target_value, GAME_SETTINGS_FILE_PATH)


static func load_game_settings(file_section: String) -> void:
	match file_section:
		AUDIO_SECTION:
			
			AudioController.set_master_volume_db(retrieve_config_data(AUDIO_SECTION, "master_volume_db", AudioController.DEFAULT_MASTER_VOLUME_DB, GAME_SETTINGS_FILE_PATH), false)
			AudioController.set_music_volume_db(retrieve_config_data(AUDIO_SECTION, "music_volume_db", AudioController.DEFAULT_MUSIC_VOLUME_DB, GAME_SETTINGS_FILE_PATH), false)
			AudioController.set_sound_volume_db(retrieve_config_data(AUDIO_SECTION, "sound_volume_db", AudioController.DEFAULT_SOUND_VOLUME_DB, GAME_SETTINGS_FILE_PATH), false)
			AudioController.set_ui_volume_db(retrieve_config_data(AUDIO_SECTION, "ui_volume_db", AudioController.DEFAULT_UI_VOLUME_DB, GAME_SETTINGS_FILE_PATH), false)
			AudioController.set_announcer_volume_db(retrieve_config_data(AUDIO_SECTION, "announcer_volume_db", AudioController.DEFAULT_ANNOUNCER_VOLUME_DB, GAME_SETTINGS_FILE_PATH), false)
			# Let's not enable loading customization data in the demo
			if !Globals.IS_DEMO:
				AudioController.set_announcer_voice(retrieve_config_data(AUDIO_SECTION, "announcer_voice", AudioController.DEFAULT_ANNOUNCER_VOICE, GAME_SETTINGS_FILE_PATH), false)
		DISPLAY_SECTION:
			DisplayController.window_is_fullscreen(retrieve_config_data(DISPLAY_SECTION, "is_fullscreen", DisplayController.DEFAULT_IS_FULLSCREEN, GAME_SETTINGS_FILE_PATH), false)
			DisplayController.window_is_borderless(retrieve_config_data(DISPLAY_SECTION, "is_borderless", DisplayController.DEFAULT_IS_BORDERLESS, GAME_SETTINGS_FILE_PATH), false)
			DisplayController.set_screen_shake_enabled(retrieve_config_data(DISPLAY_SECTION, "screen_shake_enabled", DisplayController.DEFAULT_SCREEN_SHAKE_ENABLED, GAME_SETTINGS_FILE_PATH), false)
			DisplayController.set_pause_menu_choices(retrieve_config_data(DISPLAY_SECTION, "pause_menu_choices", DisplayController.GAMEPLAY_CHOICES_DEFAULT, GAME_SETTINGS_FILE_PATH))
			DisplayController.seen_whats_new_dialog_setter(retrieve_config_data(DISPLAY_SECTION, Globals.SEEN_WHATS_NEW_KEY, DisplayController.SEEN_WHATS_NEW_DEFAULT, GAME_SETTINGS_FILE_PATH))
			DisplayController.set_crt_filter(retrieve_config_data(DISPLAY_SECTION, "scanline_filter_enabled", DisplayController.SCANLINE_FILTER_ENABLED_DEFAULT, GAME_SETTINGS_FILE_PATH), false)
			DisplayController.virtual_gamepad_enabled = retrieve_config_data(DISPLAY_SECTION, "virtual_gamepad_enabled", DisplayController.VIRTUAL_GAMEPAD_ENABLED_DEFAULT, GAME_SETTINGS_FILE_PATH)
			# Let's not enable loading customization data in the demo
			if !Globals.IS_DEMO:
				GameplayController.dudeling_jersey_index = retrieve_config_data(DISPLAY_SECTION, "dudeling_jersey_index", GameplayController.DEFAULT_DUDELING_JERSEY_INDEX, GAME_SETTINGS_FILE_PATH)
				ArenaController.bg_opacity = retrieve_config_data(DISPLAY_SECTION, "arena_bg_opacity", ArenaController.DEFAULT_BG_OPACITY, GAME_SETTINGS_FILE_PATH)
		INPUT_SECTION:
			if !Globals.IS_DEMO: 
				InputController.set_controller_vibration_enabled(retrieve_config_data(INPUT_SECTION, "controller_vibration_enabled", InputController.DEFAULT_CONTROLLER_VIBRATION_ENABLED, GAME_SETTINGS_FILE_PATH), false)
		STATS_SECTION:
			GameplayController.destination_unlocked = retrieve_config_data(STATS_SECTION, 'destination_unlocked', false, GAME_SETTINGS_FILE_PATH)
			for stat_name in PlayerStats.achievement_progression:
				PlayerStats.achievement_progression[stat_name] = retrieve_config_data(STATS_SECTION, stat_name, 0, GAME_SETTINGS_FILE_PATH)
		NOTIFICATION:
			Globals.telemetry = retrieve_config_data(NOTIFICATION, 'telemetry', null, GAME_SETTINGS_FILE_PATH)
			Globals.ident = retrieve_config_data(NOTIFICATION, 'ident', "", GAME_SETTINGS_FILE_PATH)

static func has_seen_notification(id) -> bool:
	var value = retrieve_config_data(NOTIFICATION, id, false, GAME_SETTINGS_FILE_PATH)
	return value

static func mark_notification_as_read(id) -> void:
	store_config_data(NOTIFICATION, id, true, GAME_SETTINGS_FILE_PATH)

static func reset_game_settings(file_section: String) -> void:
	delete_config_data(file_section, "", GAME_SETTINGS_FILE_PATH)
