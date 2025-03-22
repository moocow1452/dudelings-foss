class_name VirtualGamepad
extends CanvasLayer

var packedscene;
var scene;
var gp_root 
var button_dash
var button_punch_left
var button_goalie_left
var button_move_left
var button_jump
var button_move_right
var button_punch_right
var button_goalie_right
var button_pause

var ready = false
var current_state = false

func _init():
	packedscene = load("res://GameUI/VirtualGamepad/VirtualGamepad.tscn")
	self.set_layer(Globals.GameCanvasLayer.VIRTUAL_GAMEPAD)

# Called when the node enters the scene tree for the first time.
func _ready():
	scene = packedscene.instance()
	self.add_child(scene)

	gp_root = get_node("VirtualGamepad")
	button_dash = gp_root.get_node("ButtonDash")
	button_punch_left = gp_root.get_node("ButtonPunchLeft")
	button_goalie_left = gp_root.get_node("ButtonGoalieLeft")
	button_move_left = gp_root.get_node("ButtonMoveLeft")
	button_jump = gp_root.get_node("ButtonJump")
	button_move_right = gp_root.get_node("ButtonMoveRight")
	button_punch_right = gp_root.get_node("ButtonPunchRight")
	button_goalie_right = gp_root.get_node("ButtonGoalieRight")
	button_pause = gp_root.get_node("ButtonPause")
	ready = true
	var _a = DisplayController.connect("show_virtual_gp", self, "_on_show_virtual_gp")
	var _b = DisplayController.connect("hide_virtual_gp", self, "hide")
	var _c = ArenaController.connect("game_started", self, "change_mode", [DisplayController.VGP_CONTROLLER_MODE])
	var _d = ArenaController.connect("game_ended", self, "change_mode", [DisplayController.VGP_NAVIGATION_MODE])
	self.call_deferred("hide")

func _on_show_virtual_gp(mode) -> void:
	change_mode(mode)
	show()

func change_mode(mode: bool) -> void:
	current_state = mode
	match(current_state):
		DisplayController.VGP_CONTROLLER_MODE:
			button_dash.text = "DASH"
			button_dash.visible = true
			button_dash.input_type = "controller_one_dash"
			button_jump.text = "JUMP"
			button_jump.input_type = "controller_one_jump"
			button_punch_left.input_type = "controller_one_punch_left"
			button_punch_right.input_type = "controller_one_punch_right"
			button_punch_left.visible = true
			button_goalie_left.visible = true
			button_move_left.visible = true
			button_move_right.visible = true
			button_punch_right.visible = true
			button_goalie_right.visible = true
			button_pause.visible = true
			pass
		DisplayController.VGP_NAVIGATION_MODE:
			button_dash.text = "CANCEL"
			button_dash.visible = false
			button_dash.input_type = "ui_cancel"
			button_jump.text = "ACCEPT"
			button_jump.input_type = "ui_accept"
			button_punch_left.input_type = "ui_focus_prev"
			button_punch_right.input_type = "ui_focus_next"
			button_punch_left.visible = false
			button_goalie_left.visible = false
			button_punch_right.visible = false
			button_goalie_right.visible = false
			button_pause.visible = false
			pass

func show():
	if(!ready): return
	gp_root.visible = true
	pass

func hide():
	if(!ready): return
	gp_root.visible = false
	pass
