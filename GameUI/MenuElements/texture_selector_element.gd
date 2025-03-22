tool
class_name TextureSelectorElement
extends TextureRect
# A menu element for selecting images.

signal index_changed(index)

export(NodePath) var _left_arrow: NodePath = ""
export(NodePath) var _right_arrow: NodePath = ""
export(Array) var textures: Array = [] setget set_textures
export(int) var index: int = 0 setget set_index, get_index


func set_textures(new_value: Array) -> void:
	textures = new_value

	if index > textures.size() - 1:
		self.set_index(textures.size() - 1)


func set_index(new_value: int) -> void:
	index = int(clamp(new_value, 0, textures.size() - 1))
	self.set_texture(textures[index])
	
	if !Engine.editor_hint:
		if self.has_node(_left_arrow):
			self.get_node(_left_arrow).set_deferred("disabled", index == 0)
		
		if self.has_node(_right_arrow):
			self.get_node(_right_arrow).set_deferred("disabled", index == textures.size() - 1)
	
		self.emit_signal("index_changed", index)


func get_index() -> int:
	return index


func _ready() -> void:
	if !Engine.editor_hint:
		if self.has_node(_left_arrow):
			var _a = self.get_node(_left_arrow).connect("pressed", self, "_on_left_arrow_pressed")
		
		if self.has_node(_right_arrow):
			var _a = self.get_node(_right_arrow).connect("pressed", self, "_on_right_arrow_pressed")

		self.set_index(index)


func _on_left_arrow_pressed() -> void:
	self.set_index(index - 1)


func _on_right_arrow_pressed() -> void:
	self.set_index(index + 1)
