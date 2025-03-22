class_name GameTypeSubMenu
extends SubMenu
# A sub menu to select game type.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const LOCATION_SUB_MENU_SCENE: PackedScene = preload("GameLocationSubMenu.tscn")

onready var _classic_button: ButtonElement = $GameTypes/ClassicButton
onready var _hoop_button: ButtonElement = $GameTypes/HoopButton
onready var _volley_button: ButtonElement = $GameTypes/VolleyButton
onready var _random_button: ButtonElement = $GameTypes/RandomButton
onready var _pin_button: ButtonElement = $GameTypes/PinButton
onready var _description_text: Label = $DescriptionText

func _ready() -> void:
	DisplayController.hide_virtual_gamepad()
	var _a = _classic_button.connect("pressed", self, "_on_ClassicButton_pressed")
	var _aa = _classic_button.connect("focus_entered", self, "_on_ClassicButton_focused")
	var _b = _hoop_button.connect("pressed", self, "_on_HoopButton_pressed")
	var _bb = _hoop_button.connect("focus_entered", self, "_on_HoopButton_focused")
	var _c = _volley_button.connect("pressed", self, "_on_VolleyButton_pressed")
	var _cc = _volley_button.connect("focus_entered", self, "_on_VolleyButton_focused")
	var _d = _random_button.connect("pressed", self, "_on_RandomButton_pressed")
	var _dd = _random_button.connect("focus_entered", self, "_on_RandomButton_focused")
	var _e = _pin_button.connect("pressed", self, "_on_PinButton_pressed")
	var _ee = _pin_button.connect("focus_entered", self, "_on_PinButton_focused")

	match ArenaController.get_current_game_field_index():
		ArenaController.GameField.CLASSIC_GAME_FIELD:
			_classic_button.call_deferred("grab_focus")
		ArenaController.GameField.HOOP_GAME_FIELD:
			_hoop_button.call_deferred("grab_focus")
		ArenaController.GameField.VOLLEY_GAME_FIELD:
			_volley_button.call_deferred("grab_focus")
		ArenaController.GameField.PIN_GAME_FIELD:
			_pin_button.call_deferred("grab_focus")
		_:
			_classic_button.call_deferred("grab_focus")


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	# InputController.button_context_bar().show_sub_menu("MATCH SETUP")
	InputController.button_context_bar().show_close("BACK")


func _open_location_sub_menu() -> void:
	var sub_menu: GameLocationSubMenu = LOCATION_SUB_MENU_SCENE.instance()
	self.get_parent().add_child(sub_menu)
	var _a = sub_menu.connect("sub_menu_closed", self, "show")
	
	self.hide()

func _update_game_rules() -> void:
	pass

## Button Actions.

func _on_ClassicButton_focused() -> void:
	_description_text.set_text("""Score points by getting the ball in your opponent's goal by any means necessary.""")


func _on_ClassicButton_pressed() -> void:
	ArenaController.set_current_game_field_index(ArenaController.GameField.CLASSIC_GAME_FIELD)
	self._open_location_sub_menu()


func _on_HoopButton_focused() -> void:
	_description_text.set_text("""Control the ball and get it through the goal at the top of the arena.""")


func _on_HoopButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_game_field_index(ArenaController.GameField.HOOP_GAME_FIELD)
	self._open_location_sub_menu()


func _on_VolleyButton_focused() -> void:
	_description_text.set_text("""Score points by getting your ball off the opponent's side of the arena. No punching allowed.""")


func _on_VolleyButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_game_field_index(ArenaController.GameField.VOLLEY_GAME_FIELD)
	self._open_location_sub_menu()

func _on_PinButton_focused() -> void:
	_description_text.set_text("""Score points by knocking down all your opponent's pins.""")


func _on_PinButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_game_field_index(ArenaController.GameField.PIN_GAME_FIELD)
	self._open_location_sub_menu()

func _on_RandomButton_focused() -> void:
	_description_text.set_text("""Pick a random game type...""")


func _on_RandomButton_pressed() -> void:
	if Globals._demo_check():
		return
	ArenaController.set_current_game_field_index(Globals.rng.randi_range(0, ArenaController.GameField.size() - 1))
	self._open_location_sub_menu()
