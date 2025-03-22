class_name DaySky
extends Node2D
# A sky for the game arena background.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const FLYING_BIRDS_SCENE: PackedScene = preload("scenes/FlyingBirds.tscn")


func _ready() -> void:
	self._start_flying_bird_cycle()


func _start_flying_bird_cycle() -> void:
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(30.0, 60.0), false)
	var _a = timer.connect("timeout", self, "_spawn_flying_birds")


func _spawn_flying_birds() -> void:
	var birds: FlyingBirds = FLYING_BIRDS_SCENE.instance()
	self.add_child(birds)
	var _a = birds.connect("movement_finished", self, "_start_flying_bird_cycle")
	birds.fly()
