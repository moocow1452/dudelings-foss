class_name ConfirmMessage
extends SubMenu
# A custom Confirmation Dialog.
#
# @author gbryant
# @copyright 2024 Heavy Element

signal confirmed
signal cancled

onready var _header_text: Label = $BackgroundPanel/HeaderLabel
onready var _message_text: RichTextLabel = $BackgroundPanel/RichTextLabel
onready var _confirm_button: ButtonElement = $BackgroundPanel/ElementContainer/ConfirmButtonElement
onready var _cancel_button: ButtonElement = $BackgroundPanel/ElementContainer/CancelButtonElement


func _ready() -> void:
	# var timer: SceneTreeTimer = Globals.get_tree().create_timer(0.1)
	# var _z = timer.connect("timeout", $BackgroundPanel, "connect", ["clicked_outside", self, "queue_free"])

	var _a = _confirm_button.connect("pressed", self, "_on_ConfirmButtonElement_pressed")
	var _b = _cancel_button.connect("pressed", self, "_on_CancelButtonElement_pressed")

	_confirm_button.call_deferred("grab_focus")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		Globals.get_tree().set_input_as_handled()
		self._on_CancelButtonElement_pressed()

func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_close()


func show_message(header_text: String, body_text: String) -> void:
	_header_text.set_text(header_text)
	_message_text.bbcode_text = body_text

func confirm_button_label(label:String)->void:
	_confirm_button.text = label

func cancel_button_label(label:String)->void:
	_cancel_button.text = label

func _on_ConfirmButtonElement_pressed() -> void:
	emit_signal("confirmed")
	self.queue_free()


func _on_CancelButtonElement_pressed() -> void:
	emit_signal("cancled")
	self.queue_free()
