class_name MenuELementPanel
extends Panel
# A Panel that is used at the "Background" of a menu element if the element its self it lacking one.
# Used as a way to keep a menu element in the scene tree so its focus can be set.

const NORMAL_STYLE: StyleBox = preload("resources/MenuElementPanelStylebox.tres")
const FOCUESED_STYLE: StyleBox = preload("resources/MenuElementPanelFocusedStylebox.tres")

export(NodePath) var _menu_element: NodePath = ""
export(NodePath) var _other_menu_element: NodePath = ""  # Used for Selector arrows.


func _ready() -> void:
	var _a = self.connect("mouse_entered", self, "_on_mouse_entered")
	var _b = self.connect("focus_entered", self, "_on_focus_entered")
	var _c = self.get_node(_menu_element).connect("focus_entered", self, "_on_MenuElement_focus_entered")
	var _d = self.get_node(_menu_element).connect("focus_exited", self, "_on_MenuElement_focus_exited")
	
	if self.get_node(_menu_element) is OptionButton || self.get_node(_menu_element) is MenuButton:
		var _e = self.get_node(_menu_element).get_popup().connect("about_to_show", self, "call_deferred", ["_update_style", FOCUESED_STYLE])
	
	if self.has_node(_other_menu_element):
		var _f = self.get_node(_other_menu_element).connect("focus_entered", self, "_on_MenuElement_focus_entered")
		var _g = self.get_node(_other_menu_element).connect("focus_exited", self, "_on_MenuElement_focus_exited")
	
	self._update_style(NORMAL_STYLE)


func _update_style(stylebox: StyleBox) -> void:
	self.add_stylebox_override("panel", stylebox)


func _on_mouse_entered() -> void:
	if self.get_focus_owner() == self.get_node(_menu_element) || (self.has_node(_other_menu_element) && self.get_focus_owner() == self.get_node(_other_menu_element)):
		return
	
	self._on_focus_entered()


func _on_focus_entered() -> void:
	self.get_node(_menu_element).call_deferred("grab_focus")


func _on_MenuElement_focus_entered() -> void:
	self._update_style(FOCUESED_STYLE)


func _on_MenuElement_focus_exited() -> void:
	self._update_style(NORMAL_STYLE)
