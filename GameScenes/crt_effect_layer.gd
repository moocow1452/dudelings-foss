class_name CrtEffectLayer
extends CanvasLayer
# A script that controlls the CRT effect in the game
#
# @author gbryant
# @copyright 2024 Heavy Element

var scanline_filter_node

# scanline_intensity = 0.85
# green_abberation = 1
# blue_abberation = -1

func _init():
	self.set_layer(Globals.GameCanvasLayer.SHADER)
	print("CrtEffectLayer is ready")
	_make_rect()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _make_rect():
	var colorRect := ColorRect.new()
	self.add_child(colorRect)
	colorRect.set_frame_color(Color(0.0, 0.0, 0.0, 1.0))
	colorRect.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	colorRect.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)  # Pass mouse events through to lower layers
	colorRect.material = load("res://GameScenes/CrtEffect.tres")
	return colorRect

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
