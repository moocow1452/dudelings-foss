class_name PlayerHUD
extends CanvasLayer
# In game HUD for player information.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element

func _init() -> void:
	self.set_layer(Globals.GameCanvasLayer.HUD)
	self.add_to_group(Globals.PLAYER_HUD_GROUP)


func start_countdown(starting_num: int) -> void:
	$CountdownLabel.count_down(starting_num)
