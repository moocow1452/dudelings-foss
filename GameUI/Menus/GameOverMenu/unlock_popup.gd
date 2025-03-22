extends Node2D
# A script to control the 'Destination Unlocked' toast
#
# @author gbryant
# @copyright 2024 Heavy Element


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var _a = PlayerStats.connect("destination_unlocked", self, "_destination_unlocked")
	var timer = get_tree().create_timer(1)
	timer.connect("timeout", PlayerStats, "check_destination_unlocked")



func _destination_unlocked() -> void:
	$DestinationUnlocked.play("Unlocked")
