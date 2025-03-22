tool
class_name AreaPickupSpawningArea
extends Node2D
# Area that pickups spawn within. Can spawn pickups in random positions at random inervals.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

signal pickup_spawned(arena_pickup)

enum PickupSpawnRate {
	NONE,
	SLOW,
	NORMAL,
	FAST,
}

const FAST_MIN_SPAWN_TIME: float = 5.0
const FAST_MAX_SPAWN_TIME: float = 10.0
const NORMAL_MIN_SPAWN_TIME: float = 15.0
const NORMAL_MAX_SPAWN_TIME: float = 20.0
const SLOW_MIN_SPAWN_TIME: float = 25.0
const SLOW_MAX_SPAWN_TIME: float = 30.0
const PICKUP_SCENES: Array = [  # Match indexing to 'ArenaPickup.PickupType'.
	preload("../ExtraBallPickup/ExtraBallPickup.tscn"),
	preload("../RandomBallPickup/RandomBallPickup.tscn"),
	preload("../SmallerBallPickup/SmallerBallPickup.tscn"),
	preload("../BiggerBallPickup/BiggerBallPickup.tscn"),
	preload("../SwitchControlPickup/SwitchControlPickup.tscn"),
	# preload("../HideHighlightPickup/HideHighlightPickup.tscn"),
	# preload("../StunOpponentPickup/StunOpponentPickup.tscn"),
	preload("../BlackHolePickup/BlackHolePickup.tscn"),
	preload("../MysteryPickup/MysteryPickup.tscn"),
]
const PICKUP_ICONS: Array = [  # Match indexing to 'PICKUP_TYPE'.
	preload("res://Assets/GameComponents/ArenaPickups/ExtraBallPickup/art/extra_ball_icon.png"),
	preload("res://Assets/GameComponents/ArenaPickups/RandomBallPickup/art/random_ball_icon.png"),
	preload("res://Assets/GameComponents/ArenaPickups/SmallerBallPickup/art/smaller_ball_icon.png"),
	preload("res://Assets/GameComponents/ArenaPickups/BiggerBallPickup/art/bigger_ball_icon.png"),
	preload("res://Assets/GameComponents/ArenaPickups/SwitchControlPickup/art/switch_control_icon.png"),
	# preload("res://Assets/GameComponents/ArenaPickups/HideHighlightPickup/art/hide_highlight_icon.png"),
	# preload("res://Assets/GameComponents/ArenaPickups/StunOpponentPickup/art/stun_opponent_icon.png"),
	preload("res://Assets/GameComponents/ArenaPickups/BlackHolePickup/art/black_hole_icon.png"),
	preload("res://Assets/GameComponents/ArenaPickups/MysteryPickup/art/mystery_icon.png"),
]

var _spawn_timer: Timer = self._make_spawn_timer()


func _init() -> void:
	self.add_to_group(Globals.ARENA_PICKUP_SPAWNER_GROUP)


func _ready() -> void:
	if !Engine.editor_hint:
		$SpawningArea0.set_frame_color(Color(0.0, 0.0, 0.0, 0.0))
		$SpawningArea1.set_frame_color(Color(0.0, 0.0, 0.0, 0.0))
		
		var _a = ArenaController.connect("game_started", self, "_start_pickup_spawn_cycle")
		var _b = ArenaController.connect("game_ended" , self, "stop_spawning")


func choose_random_pickup(pickup_options: Array) -> int:
	var filtered_options: Array = self._filter_pickup_options(pickup_options)
	return filtered_options[Globals.rng.randi_range(0, filtered_options.size() - 1)] if !filtered_options.empty() else -1


func spawn_pickup(pickup_type: int, pickup_position: Vector2) -> void:
	if GameplayController.get_arena_pickup_spawn_rate() == PickupSpawnRate.NONE:
		return
	
	if pickup_type < 0 || pickup_type > ArenaPickup.PickupType.size() - 1:
		return
	
	var pickup: ArenaPickup = PICKUP_SCENES[pickup_type].instance()
	self.add_child(pickup)
	pickup.set_global_position(pickup_position)

	self.emit_signal("pickup_spawned", pickup)


func randomly_spawn() -> void:
	var pickup_type: int = self.choose_random_pickup(GameplayController.get_allowed_pickups())
	self.spawn_pickup(pickup_type, self._choose_spawn_position())


func stop_spawning() -> void:
	_spawn_timer.stop()


func _choose_spawn_position() -> Vector2:
	var target_spawn_area: ColorRect = (
		$SpawningArea0 if Globals.rng.randf() <= 0.5 else
		$SpawningArea1
	)

	var pos_x: float = Globals.rng.randf_range(target_spawn_area.get_global_rect().position.x, target_spawn_area.get_global_rect().end.x)
	var pos_y: float = Globals.rng.randf_range(target_spawn_area.get_global_rect().position.y, target_spawn_area.get_global_rect().end.y)
	
	return Vector2(pos_x, pos_y)


func _start_pickup_spawn_cycle() -> void:
	var min_time: float = (
		SLOW_MIN_SPAWN_TIME if GameplayController.get_arena_pickup_spawn_rate() == PickupSpawnRate.SLOW else
		FAST_MIN_SPAWN_TIME if GameplayController.get_arena_pickup_spawn_rate() == PickupSpawnRate.FAST else
		NORMAL_MIN_SPAWN_TIME
	)
	var max_time: float = (
		SLOW_MAX_SPAWN_TIME if GameplayController.get_arena_pickup_spawn_rate() == PickupSpawnRate.SLOW else
		FAST_MAX_SPAWN_TIME if GameplayController.get_arena_pickup_spawn_rate() == PickupSpawnRate.FAST else
		NORMAL_MAX_SPAWN_TIME
	)

	_spawn_timer.start(Globals.rng.randf_range(min_time, max_time))


func _filter_pickup_options(pickup_options: Array) -> Array:
	var filtered_options: Array = pickup_options.duplicate(true)

	var all_balls_smallest: bool = ArenaController.game_ball_spawner().all_game_balls_are_tiny()
	var all_balls_biggest: bool = ArenaController.game_ball_spawner().all_game_balls_are_huge()

	for pickup in pickup_options:
		match pickup:
			ArenaPickup.PickupType.SMALLER_BALL:
				if all_balls_smallest:
					filtered_options.erase(pickup)
			ArenaPickup.PickupType.BIGGER_BALL:
				if all_balls_biggest:
					filtered_options.erase(pickup)

	return filtered_options


func _make_spawn_timer() -> Timer:
	var spawn_timer := Timer.new()
	self.add_child(spawn_timer)
	spawn_timer.set_pause_mode(PAUSE_MODE_STOP)
	var _a = spawn_timer.connect("timeout", self, "randomly_spawn")
	var _b = spawn_timer.connect("timeout", self, "_start_pickup_spawn_cycle")
	return spawn_timer
