class_name DudelingKeyboardInputs
extends DudelingPlayerInputs
# This script is used to allow a keyboard to control the dudeling row. THERE CAN ONLY BE ONE.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _init(target_player: int) -> void:
	_controlling_player = target_player

	_move_left = "keyboard_move_left"
	_move_right = "keyboard_move_right"
	_snap_left = "keyboard_snap_left"
	_snap_right = "keyboard_snap_right"
	_jump = "keyboard_jump"
	_dash = "keyboard_dash"
	_punch_left = "keyboard_punch_left"
	_punch_right = "keyboard_punch_right"
