class_name FullGameScene
extends SubMenu
# A sub menu for showing player stats
#
# @author gbryant
# @copyright 2024 Heavy Element

onready var buy_now_button: ButtonElement = $ElementContainer/BuyNowButtonElement;
onready var cancel_button: ButtonElement = $ElementContainer/CancelButtonElement;

func _ready() -> void:
	# Call before connecting signals to avoid triggering them.

	self._update_menu()

	# Connect signals.
	var _z = $BackgroundPanel.connect("clicked_outside", self, "queue_free")
	
	buy_now_button.call_deferred("grab_focus")
	var _a = buy_now_button.connect("pressed", self, "buy_now_callback")
	var _b = cancel_button.connect("pressed", self, "queue_free")

	InputController.button_context_bar().hide_all()
	InputController.button_context_bar().show_close("BACK")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return

func buy_now_callback() -> void:
	Steam.activateGameOverlayToStore(1905160)

func _update_menu() -> void:
	pass

func _default_update(stat_name, value_node):
	value_node.text = "%s" % PlayerStats.achievement_progression[stat_name]

func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_reset()
	InputController.button_context_bar().show_close()
