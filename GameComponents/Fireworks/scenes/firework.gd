class_name Firework
extends Node2D
# This is an abstract scene of a single firework. It is meant to be used through 'fireworks.gd'.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const FIREWORK_WIZZ_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/Fireworks/audio/firework_wizz.ogg")
const EXPLOSION_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/Fireworks/audio/explosion.ogg")
const POSSIBLE_COLORS: Array = [
	Color(1.0, 0.0, 0.0, 0.9),  # Red.
	Color(0.0, 1.0, 0.0, 0.9),  # Green.
	Color(0.0, 0.0, 1.0, 0.9),  # Blue.
	Color(1.0, 1.0, 0.0, 0.9),  # Yellow.
	Color(1.0, 0.65, 0.0, 0.9),  # Orange.
	Color(0.63, 0.13, 0.94, 0.9),  # Purple.
]


func _ready() -> void:
	var particle_gravity: float = Globals.rng.randf_range(50.0, 200.0)

	$FireworkLayer0.process_material.gravity.y = particle_gravity
	$FireworkLayer1.process_material.gravity.y = particle_gravity
	$FireworkLayer2.process_material.gravity.y = particle_gravity
	
	self._launch()


func _launch() -> void:
	var _a = $AudioStreamPlayer.connect("finished", self, "_explode")
	$AudioStreamPlayer.set_pitch_scale(1 * Globals.rng.randf_range(0.8, 1.2))
	$AudioStreamPlayer.set_stream(FIREWORK_WIZZ_SOUND)
	$AudioStreamPlayer.play()


func _explode() -> void:
	var colors: Array = POSSIBLE_COLORS.duplicate(true)

	$FireworkLayer0.get_process_material().set_color(colors.pop_at(Globals.rng.randi() % colors.size()))
	$FireworkLayer0.set_emitting(true)

	$FireworkLayer1.get_process_material().set_color(colors.pop_at(Globals.rng.randi() % colors.size()))
	$FireworkLayer1.set_emitting(true)

	$FireworkLayer2.get_process_material().set_color(colors.pop_at(Globals.rng.randi() % colors.size()))
	$FireworkLayer2.set_emitting(true)
	
	$AudioStreamPlayer.disconnect("finished", self, "_explode")
	var _a = $AudioStreamPlayer.connect("finished", self, "queue_free")
	$AudioStreamPlayer.set_pitch_scale(1 * Globals.rng.randf_range(0.8, 1.2))
	$AudioStreamPlayer.set_stream(EXPLOSION_SOUND)
	$AudioStreamPlayer.play()
