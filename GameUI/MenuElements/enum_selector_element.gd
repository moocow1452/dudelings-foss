tool
class_name EnumSelectorElement
extends Label
# A selector element for selecting an enum index.

signal value_changed(value)

export(NodePath) var _left_arrow: NodePath = ""
export(NodePath) var _right_arrow: NodePath = ""

var options: Array = ["TEXT"] setget set_options, get_options
var value: int = 0 setget set_value, get_value


func set_options(new_value: Array) -> void:
	options = ["TEXT"] if new_value.empty() else new_value
	self.set_text(options[value])


func get_options() -> Array:
	return options


func set_value(new_value: int) -> void:
	value = int(clamp(new_value, 0, options.size() - 1))
	self.set_text(options[value])
	self.emit_signal("value_changed", value)


func get_value() -> int:
	return value


func _ready() -> void:
	if !Engine.editor_hint:
		if self.has_node(_left_arrow):
			var _a = self.get_node(_left_arrow).connect("pressed", self, "_on_left_arrow_pressed")
		
		if self.has_node(_right_arrow):
			var _a = self.get_node(_right_arrow).connect("pressed", self, "_on_right_arrow_pressed")


func _on_left_arrow_pressed() -> void:
	self.set_value(value - 1)


func _on_right_arrow_pressed() -> void:
	self.set_value(value + 1)

