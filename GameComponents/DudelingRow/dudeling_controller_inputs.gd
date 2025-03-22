class_name DudelingControllerInputs
extends DudelingPlayerInputs
# This script is used to allow a controller to control the dudeling row.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const CONTROLLER_NAME: Array = ["controller_one", "controller_two"]

var _controller_number: int = 0


func _init(target_player: int) -> void:
	_controlling_player = target_player
	_controller_number = InputController.controller_index(_controlling_player)

	_move_left = CONTROLLER_NAME[_controller_number] + "_move_left"
	_move_right = CONTROLLER_NAME[_controller_number] + "_move_right"
	_snap_left = CONTROLLER_NAME[_controller_number] + "_snap_left"
	_snap_right = CONTROLLER_NAME[_controller_number] + "_snap_right"
	_jump = CONTROLLER_NAME[_controller_number] + "_jump"
	_dash = CONTROLLER_NAME[_controller_number] + "_dash"
	_punch_left = CONTROLLER_NAME[_controller_number] + "_punch_left"
	_punch_right = CONTROLLER_NAME[_controller_number] + "_punch_right"
