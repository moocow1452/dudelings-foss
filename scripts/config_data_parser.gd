class_name ConfigDataParser
# Base class for storing and retrieving config file data.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element

# 'data_value' can be different types.
static func store_config_data(file_section: String, data_key: String, data_value, file_path: String) -> void:
	var config := ConfigFile.new()
	var _a = config.load(file_path)
	config.set_value(file_section, data_key, data_value)
	var _b = config.save(file_path)


# Can return different types.
static func retrieve_config_data(file_section: String, data_key: String, default_value, file_path: String):
	var target_data  # Data can be different types.
	var config := ConfigFile.new()
	var error: int = config.load(file_path)
	if error == OK:
		target_data = config.get_value(file_section, data_key, default_value)
		return target_data

	return default_value


static func retrieve_config_key(file_section: String, file_path: String) -> Array:
	var target_data: Array = []
	var config := ConfigFile.new()
	var error: int = config.load(file_path)
	if error == OK:
		if config.has_section(file_section):
			target_data = config.get_section_keys(file_section)
	
	return target_data


static func delete_config_data(file_section: String, data_key: String, file_path: String) -> void:
	var config := ConfigFile.new()
	var error: int = config.load(file_path)
	if error == OK:
		if data_key == "" && config.has_section(file_section):
			config.erase_section(file_section)
		elif config.has_section_key(file_section, data_key):
			config.erase_section_key(file_section, data_key)
		
		var _a = config.save(file_path)
