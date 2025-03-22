class_name NightSky
extends Node2D
# A sky for the game arena background.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const SHOOTING_STAR_SCENE: PackedScene = preload("scenes/ShootingStar.tscn")


func _ready() -> void:
	self._start_shooting_star_cycle()


func _start_shooting_star_cycle() -> void:
	var timer: SceneTreeTimer = Globals.get_tree().create_timer(Globals.rng.randf_range(30.0, 60.0), false)
	var _a = timer.connect("timeout", self, "_spawn_shooting_star")
	var _b = timer.connect("timeout", self, "_start_shooting_star_cycle")


func _spawn_shooting_star() -> void:
	self.add_child(SHOOTING_STAR_SCENE.instance() as ShootingStar)
