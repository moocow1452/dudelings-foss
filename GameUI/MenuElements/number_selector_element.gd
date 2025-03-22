tool
class_name NumberSelectorElement
extends Label
# A number selector that is paired with selector arrows.

signal value_changed(value)

export(NodePath) var _left_arrow: NodePath = ""
export(NodePath) var _right_arrow: NodePath = ""
export(int) var min_value: int = 0 setget set_min_value, get_min_value
export(int) var max_value: int = 100 setget set_max_value, get_max_value
export(int) var value: int = 0 setget set_value, get_value


func set_min_value(new_value: int) -> void:
	if new_value > max_value:
		return

	min_value = new_value

	if value < min_value:
		self.set_value(min_value)


func get_min_value() -> int:
	return min_value


func set_max_value(new_value: int) -> void:
	if new_value < min_value:
		return

	max_value = new_value

	if value > max_value:
		self.set_value(max_value)


func get_max_value() -> int:
	return max_value


func set_value(new_value: int) -> void:
	value = int(clamp(new_value, min_value, max_value))
	self.set_text(str(value))
	
	if !Engine.editor_hint:
		if self.has_node(_left_arrow):
			self.get_node(_left_arrow).set_deferred("disabled", value == min_value)
		
		if self.has_node(_right_arrow):
			self.get_node(_right_arrow).set_deferred("disabled", value == max_value)

		self.emit_signal("value_changed", value)


func get_value() -> int:
	return value


func _ready() -> void:
	if !Engine.editor_hint:
		if self.has_node(_left_arrow):
			var _a = self.get_node(_left_arrow).connect("pressed", self, "_on_left_arrow_pressed")
		
		if self.has_node(_right_arrow):
			var _a = self.get_node(_right_arrow).connect("pressed", self, "_on_right_arrow_pressed")

		self.set_value(value)


func _on_left_arrow_pressed() -> void:
	self.set_value(value - 1)


func _on_right_arrow_pressed() -> void:
	self.set_value(value + 1)
