class_name ContextOption
extends HBoxContainer
# Used inside the Buton Context Bar to show each UI context option.

export(Texture) var pc_button_texture: Texture = null setget set_pc_button_texture
export(Texture) var xbox_button_texture: Texture = null setget set_xbox_button_texture
export(Texture) var playstation_button_texture: Texture = null setget set_playstation_button_texture

var _context_label: String = "TEXT" setget set_context_label


func set_pc_button_texture(new_value: Texture) -> void:
	pc_button_texture = new_value


func set_xbox_button_texture(new_value: Texture) -> void:
	xbox_button_texture = new_value


func set_playstation_button_texture(new_value: Texture) -> void:
	playstation_button_texture = new_value


func set_context_label(new_value: String) -> void:
	_context_label = new_value
	$ContextLabel.set_text(_context_label)


func update_controller_type(controller_type: int) -> void:
	var new_texture: Texture = (
		pc_button_texture if controller_type == InputController.ControllerType.KEYBOARD else
		playstation_button_texture if controller_type == InputController.ControllerType.PLAYSTATION else
		xbox_button_texture
	)
	$ButtonTexture.set_texture(new_texture)
