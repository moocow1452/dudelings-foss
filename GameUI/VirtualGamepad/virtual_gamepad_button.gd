extends Node

export var input_type: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	var _a = connect("button_down", self, "_dispatch_input_event_start")
	var _b = connect("button_up", self, "_dispatch_input_event_end")

func _dispatch_input_event_start():
	Input.action_press(input_type)
	Input.vibrate_handheld(20)

func _dispatch_input_event_end():
	Input.action_release(input_type)
