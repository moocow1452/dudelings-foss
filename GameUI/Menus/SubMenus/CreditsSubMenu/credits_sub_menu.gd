class_name CreditsSubMenu
extends SubMenu
# A Sub Menu to show game credits.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

onready var _scroll_container: ScrollContainer = $BackgroundPanel/MenuContainer/ScrollContainer
onready var _scrollbar: VScrollBar = $BackgroundPanel/MenuContainer/ScrollContainer.get_v_scrollbar()

func _ready() -> void:
	var _a = $BackgroundPanel.connect("clicked_outside", self, "queue_free")
	
	self.update_button_context_bar()  ## Call here. Control focus never changes.
	
	self.call_deferred("grab_focus")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if self.get_focus_owner() != self:
		return
	
	if Input.is_action_pressed("ui_up"):
		self.accept_event()
		self._scroll(-5)
	
	if Input.is_action_pressed("ui_down"):
		self.accept_event()
		self._scroll(5)


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return

	InputController.button_context_bar().hide_all()
	
	InputController.button_context_bar().show_up()
	InputController.button_context_bar().show_down()
	InputController.button_context_bar().show_close("BACK")


func _scroll(speed: int) -> void:
	_scroll_container.set_v_scroll(_scroll_container.get_v_scroll() + speed)
