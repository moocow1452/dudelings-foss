class_name MysteryPickup
extends ArenaPickup
# Spawns a random pickup.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element


func _init() -> void:
	pickup_type = PickupType.MYSTERY


func _pickup_effect() -> void:
	self.call_deferred("_spawn_new_pickup")  # 'call_deferred' to allow "queries to flush".


func _start_activated_effect() -> void:
	pass  # Overrides effect to do nothing.


func _spawn_new_pickup() -> void:
	var pickup_options: Array = GameplayController.get_allowed_pickups().duplicate(true)
	pickup_options.erase(ArenaPickup.PickupType.MYSTERY)
	var new_pickup: int = ArenaController.arena_pickup_spawner().choose_random_pickup(pickup_options)
	ArenaController.arena_pickup_spawner().spawn_pickup(new_pickup, self.get_global_position())
