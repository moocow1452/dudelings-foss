class_name WhatsNewSubMenu
extends SubMenu
# A script for managing the what's new screen
#
# @author gbryant
# @copyright 2024 Heavy Element


var new_indicator := preload("res://GameUI/UnseenNotification/UnseenNotification.tscn")
var button_index: int = 0;
var ui_buttons: Dictionary = {}
#onready var ui_focused_sound:AudioStreamOGGVorbis = load("res://GameUI/MenuElements/audio/ui_focused.ogg")
onready var ui_pressed_sound:AudioStreamOGGVorbis = load("res://Assets/GameUI/MenuElements/audio/ui_pressed.ogg")

onready var _scroll_container: ScrollContainer = $BackgroundPanel/MenuContainer/ScrollContainer
onready var _scrollbar: VScrollBar = $BackgroundPanel/MenuContainer/ScrollContainer.get_v_scrollbar()

onready var button_container = $BackgroundPanel/ButtonOptions/HBoxContainer
onready var header_label = $BackgroundPanel/MenuContainer/HeaderLabel
onready var vbox_container = $BackgroundPanel/MenuContainer/ScrollContainer/VBoxContainer
onready var announcement_label = $BackgroundPanel/MenuContainer/ScrollContainer/VBoxContainer/AnnouncementLabel
onready var whats_new_button:Button = $BackgroundPanel/ButtonOptions/HBoxContainer/WhatsNew

func _ready() -> void:
	# var _a = $BackgroundPanel.connect("clicked_outside", self, "queue_free")
	var _a = whats_new_button.connect("pressed", self, "_whats_new_button")
	var _b = connect("sub_menu_closed", self, "update_settings")
	var _c = button_container.connect("show_announcement", self, "_announcement_button_clicked")
	var _d = button_container.connect("_whats_new_button", self, "_whats_new_button")

	$BackgroundPanel/MenuContainer/HeaderLabel.text = "WHAT'S NEW IN %s" % Globals.DUDELINGS_VERSION_NUMBER
	self.update_button_context_bar()  ## Call here. Control focus never changes.
	# $BackgroundPanel/MenuContainer.call_deferred("grab_focus")
	populate_button_container()
	self.call_deferred("grab_focus")

func populate_button_container() -> void:
	if(!Globals.hE_announcements): return
	if(Globals.hE_announcements.empty() == true): return
	var selected_first_candidate = !DisplayController.seen_whats_new_dialog
	var event_ending_soon:Dictionary
	var ending_button:Button
	var index_count: int = 0
	ui_buttons[index_count] = {'button': whats_new_button, 'announcement': {}}

	for announcement in Globals.hE_announcements:
		index_count += 1
		if announcement is String && (announcement == "error" || announcement == "code"):
			break
		var button = Button.new()
		button.text = announcement.title
		if announcement.has("button_title"): button.text = announcement.button_title
		button.toggle_mode = true
		# Check if this event ends sooner than the 
		if !event_ending_soon:
			event_ending_soon = announcement
		if event_ending_soon['ends']['$date']['$numberLong'] < announcement['ends']['$date']['$numberLong']:
			event_ending_soon = announcement
			ending_button = button

		button_container.add_child(button)
		ui_buttons[index_count] = {'button': button, 'announcement': announcement}
		button.connect("pressed", self, "_handle_button_click", [index_count])
		var has_seen = GameSettingsData.has_seen_notification(announcement.id)
		if !has_seen:
			# Add our 'unread' indicator
			var instance_indicator = new_indicator.instance()
			instance_indicator.scale = Vector2(0.25, 0.25)
			instance_indicator.translate(Vector2(button.rect_size.x + 10, 0))
			button.add_child(instance_indicator)
			if !selected_first_candidate:
				button.emit_signal("pressed")
				button.pressed = true
				selected_first_candidate = true

	if !selected_first_candidate && event_ending_soon && ending_button:
		ending_button.emit_signal("pressed")
	

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

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		var next = button_index + 1
		if next >= ui_buttons.size(): next = 0
		_handle_button_click(next)

	if event.is_action_pressed("ui_focus_prev"):
		var prev = button_index - 1
		if prev < 0: prev = ui_buttons.size() - 1
		if prev < 0: prev = 0
		_handle_button_click(prev)
		

func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return

	InputController.button_context_bar().hide_all()
	
	InputController.button_context_bar().show_up()
	InputController.button_context_bar().show_down()
	InputController.button_context_bar().show_close("BACK")


func _scroll(speed: int) -> void:
	_scroll_container.set_v_scroll(_scroll_container.get_v_scroll() + speed)

func update_setting() -> void:
	# GameSettingsData.save_game_setting(GameSettingsData.DISPLAY_SECTION, Globals.SEEN_WHATS_NEW_KEY, true)
	pass

func _all_nodes(visible: bool = false) -> void:
	for node in vbox_container.get_children():
		node.visible = visible

func _press_button(button: Button)-> void:
	for btn in button_container.get_children():
		btn.pressed = false
	button.pressed = true

func _whats_new_button() -> void:
	_scroll_container.scroll_vertical = 0
	self.call_deferred("grab_focus")
	AudioController.play_ui_sound(ui_pressed_sound)
	_all_nodes(true);
	_press_button(whats_new_button)
	header_label.text = "WHAT'S NEW IN %s" % Globals.DUDELINGS_VERSION_NUMBER
	announcement_label.visible = false
	announcement_label.bbcode_text = ""

func _announcement_button_clicked(announce, _button) -> void:
	_scroll_container.scroll_vertical = 0
	# If the button is clicked, return the focus back to the panel
	self.call_deferred("grab_focus")
	# Reset all nodes to make them invisible
	_all_nodes(false)
	AudioController.play_ui_sound(ui_pressed_sound)

	# Press the this button
	_press_button(_button)
	announcement_label.visible = true
	header_label.text = announce.title.to_upper()
	announcement_label.bbcode_enabled = true
	announcement_label.bbcode_text = announce.bbcode.lstrip("\n").rstrip("\n").replace("\n", "\n\n")
	if !GameSettingsData.has_seen_notification(announce.id): GameSettingsData.mark_notification_as_read(announce.id)
	var unseen = _button.get_children()
	if unseen: unseen[0].queue_free()
	
func _handle_button_click(index) -> void:
	button_index = index
	if index == 0:
		_whats_new_button()
	else:
		_announcement_button_clicked(ui_buttons[index].announcement, ui_buttons[index].button)
