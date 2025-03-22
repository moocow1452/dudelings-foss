class_name Dudeling
extends KinematicBody2D
# The script for a single dudeling.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

enum FaceState {
	LOOK_STRAIGHT = 1,
	CELEBRATE = 2,
	LOOK_UP = 4,
	FLINCH = 8,
	STUNNED = 16,
}
enum FaceFrame {
	LOOK_STRAIGHT,
	LOOK_LEFT,
	LOOK_RIGHT,
	LOOK_UP,
	FLINCH,
	CELEBRATE,
	STUNNED,
}

const MIN_MOVE_HEIGHT: float = 0.0  # Position is local to Dudelings Node.
const MAX_MOVE_HEIGHT: float = -620.0  # Position is local to Dudelings Node. Head is at -100.
const JUMP_FORCE: float = -105.0
const DASH_FORCE: float = -180.0
const GRAVITY: float = 9.8
const MAX_MOVE_SPEED: float = -180.0
const MAX_FALL_SPEED: float = 50.0
const HIT_BALL_FORCE: float = 400.0
const DASH_HIT_BALL_FORCE: float = 1000.0  # Make sure this number is smaller than the game balls max move speed.
const FUMBLE_BALL_FORCE: float = 200.0
const JUMP_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/Dudelings/audio/dudeling_jump.ogg")
const DASH_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameComponents/Dudelings/audio/dudeling_dash.ogg")
const SNAP_CLOUD_SCENE: PackedScene = preload("DudelingSnapCloud.tscn")
const FIST_SCENE: PackedScene = preload("DudelingFist.tscn")
const STUN_HALO_SCENE: PackedScene = preload("DudelingStunHalo.tscn")


var controlling_player: int = 0 setget , get_controlling_player

var _face_state: int = -1  # -1 allows for setting correct face anim on '_ready'.
var _y_velocity: float = 0.0
var _y_velocity_last_frame: float = 0.0
var _is_dashing: bool = false
var _stun_halo: AnimatedSprite = null
var _stun_timer: Timer = self._make_stun_timer()
var _player_stun_timer: Timer = self._make_player_stun_timer()
var _check_ball_over_head_timer: Timer = self._make_check_ball_over_head_timer()
var _face_timer: Timer = self._make_face_timer()
var home_team_shader:= load("res://shaders/materials/home_team.tres")
var away_team_shader:= load("res://shaders/materials/away_team.tres")

func get_controlling_player() -> int:
	return controlling_player


func _init() -> void:
	self.add_to_group(Globals.DUDELING_GROUP)


func _ready() -> void:
	var _a = ArenaController.connect("game_started", _check_ball_over_head_timer, "start")
	var _b = $Hitbox.connect("body_entered", self, "_on_Hitbox_body_entered")
	var _c = $Hitbox.connect("body_exited", self, "_on_Hitbox_body_exited")
	var _d = GameplayController.connect("dudeling_jersey_index_changed", self, "change_jersey")

	self.randomize_appearance()
	self.change_jersey(GameplayController.get_dudeling_jersey_index())
	self._change_face_state(0)


func is_under_ball(game_ball: GameBall) -> bool:
	if !is_instance_valid(game_ball):
		return false
	
	return abs(game_ball.get_global_position().x - self.global_position.x) < game_ball.game_ball_radius() + 24.0  # 25.0 is half the with of the dudeling.


func is_under_any_ball() -> bool:
	for game_ball in ArenaController.game_ball_spawner().get_game_balls():
		if !is_instance_valid(game_ball):
			continue
		
		if self.is_under_ball(game_ball):
			return true

	return false


# Works for dash too.
func can_jump() -> bool:
	return !self.is_in_air() && !self.is_stunned()


func goal_side(target_goal_pos: Vector2) -> int:
	return (
		Globals.LEFT if target_goal_pos.x < self.get_global_position().x else
		Globals.RIGHT
	)


func game_ball_side(target_game_ball: GameBall) -> int:
	if !is_instance_valid(target_game_ball):
		return 0
	
	return (
		Globals.LEFT if target_game_ball.get_global_position().x < self.get_global_position().x else
		Globals.RIGHT
	)


## Movement.

func _physics_process(_delta: float) -> void:
	# Apply gravity.
	if self.is_in_air():
		_y_velocity = clamp(_y_velocity + GRAVITY, MAX_MOVE_SPEED, MAX_FALL_SPEED)

	# Move Dudeling.
	self.set_position(Vector2(self.get_position().x , clamp(self.get_position().y + _y_velocity, MAX_MOVE_HEIGHT, MIN_MOVE_HEIGHT)))

	# Set '_is_dashing' false when falling starts.
	if _y_velocity_last_frame < 0.0 && _y_velocity >= 0.0:
		_is_dashing = false

	# Reset '_y_velocity' when on ground.
	if _y_velocity_last_frame > 0.0 && !self.is_in_air():
		_y_velocity = 0.0

	# Set '_y_velocity_last_frame' LAST.
	_y_velocity_last_frame = _y_velocity


func is_in_air() -> bool:
	return self.get_position().y < 0.0  # Position is local to Dudeling Node.


func is_jumping() -> bool:
	return _y_velocity < 0.0


func is_dashing() -> bool:
	return _is_dashing


func is_falling() -> bool:
	return _y_velocity > 0.0


func is_stunned() -> bool:
	return !_stun_timer.is_stopped()


func can_hit_ball(game_ball: GameBall) -> bool:
	if self.get_index() == Globals.min_dudeling_index() || self.get_index() == Globals.max_dudeling_index():
		return self.is_under_ball(game_ball)

	if self.get_index() == Globals.center_dudeling_index() && ArenaController.GameField.HOOP_GAME_FIELD:
		return self.is_under_ball(game_ball)

	if game_ball.get_game_ball_type() == GameBall.GameBallType.BALLOON_BALL && abs(game_ball.get_linear_velocity().length()) < 0.1:  # Check if game ball is moving. Ignore very small movements like bouncing.
		return self.is_under_ball(game_ball)
	
	return self.is_under_ball(game_ball) && self.game_ball_side(game_ball) == self.goal_side(ArenaController.find_goal_pos(Globals.other_player(controlling_player)))


func start_jump(force_adjust_multiplier: float = 1.0) -> void:
	if !self.can_jump():
		return
	
	_y_velocity = JUMP_FORCE * force_adjust_multiplier
	
	self._add_face_state(FaceState.LOOK_UP)

	for body in $Hitbox.get_overlapping_bodies():
		if body.is_in_group(Globals.GAME_BALL_GROUP):
			self._try_hit_ball(body)
			break  # Only hit one ball.
	
	AudioController.play_game_sound(JUMP_SOUND, controlling_player, AudioController.PITCH_SHIFT_FREQUENT)
	InputController.vibrate_controller(controlling_player, 1.0, 0.0, 0.2)
	self.crouch(0.7, 0.2, 0.1)


func start_dash() -> void:
	if !self.can_jump():
		return
	
	_is_dashing = true
	_y_velocity = DASH_FORCE
	
	self._add_face_state(FaceState.LOOK_UP)

	for body in $Hitbox.get_overlapping_bodies():
		if body.is_in_group(Globals.GAME_BALL_GROUP):
			self._try_hit_ball(body)
			break  # Only hit one ball.
	
	AudioController.play_game_sound(DASH_SOUND, controlling_player, AudioController.PITCH_SHIFT_INFREQUENT)
	InputController.vibrate_controller(controlling_player, 1.0, 0.0, 0.3)
	self.crouch(0.6, 0.1, 0.1)
	self.shake(10.0, 0.2, 2)


# This will stop dashing as well.
func stop_jump() -> void:
	if !self.is_jumping():
		return

	self._start_dudeling_fall()


func stop_dash() -> void:
	if !self.is_dashing():
		return

	self.stop_jump()


func _start_dudeling_fall() -> void:
	_y_velocity = 0.0
	self._remove_face_state(FaceState.LOOK_UP)


## Actions.

func give_player_control(target_player: int) -> void:
	if target_player < 1:
		return

	controlling_player = target_player

	self._check_game_ball_overlap()

	self.update_highlight(ArenaController.dudeling_row().player_is_highlighted(controlling_player))
	self._add_face_state(FaceState.LOOK_STRAIGHT)


func remove_player_control() -> void:
	# Do this before setting controlling_player to 0.
	ArenaController.dudeling_row().other_dudeling(controlling_player)._check_game_ball_overlap()
	
	controlling_player = 0
	self.stop_jump()
	
	self.update_highlight(false)
	self._remove_face_state(FaceState.LOOK_STRAIGHT)


func punch(direction: int) -> Object:
	self.tilt(-direction, 10.0, 0.4)

	var fist: DudelingFist = FIST_SCENE.instance()
	$Body.add_child(fist)
	fist.set_position(Vector2(15.0 * direction, -58.0))
	var punch_target: Object = fist.punch(self, direction)
	
	return punch_target


func stun(stun_time: float) -> void:
	self.stop_jump()

	if controlling_player > 0:
		self._add_face_state(FaceState.STUNNED)
		_player_stun_timer.start(ArenaController.dudeling_row().PUNCH_STUN_PLAYER_TIME)

	if !is_instance_valid(_stun_halo):
		_stun_halo = STUN_HALO_SCENE.instance()
		$Body/HeadSprite.add_child(_stun_halo)
		_stun_halo.set_position(Vector2(0.0, -45.0))
		_stun_halo.play("spin")
	
	_stun_timer.start(stun_time)


func end_stun() -> void:
	if is_instance_valid(_stun_halo):
		_stun_halo.queue_free()
		_stun_halo = null

	_stun_timer.stop()
	self._end_player_stun_effect()


func _end_player_stun_effect() -> void:
	self._remove_face_state(FaceState.STUNNED)


func _try_hit_ball(game_ball: GameBall) -> void:
	if !is_instance_valid(game_ball):
		return

	if controlling_player == 0:
		return

	if !self.can_hit_ball(game_ball):
		if self.is_under_ball(game_ball):
			self._start_dudeling_fall()

			# "Fumble" ball.
			var directon_normal: Vector2 = (game_ball.get_global_position() - self.get_global_position()).normalized()
			var total_force: Vector2 = directon_normal * (game_ball.get_linear_velocity().length() + FUMBLE_BALL_FORCE)
			game_ball.apply_impulse(game_ball.game_ball_radius() * -directon_normal, total_force - game_ball.get_linear_velocity())
			InputController.vibrate_controller(controlling_player, 0.0, 1.0, 0.3)
		
		return

	self._hit_ball(game_ball, DASH_HIT_BALL_FORCE if self.is_dashing() else HIT_BALL_FORCE)


func _hit_ball(game_ball: GameBall, hit_force: float) -> void:
	var goal_pos: Vector2 = ArenaController.find_goal_pos(Globals.other_player(controlling_player))

	# Make goalies hit ball different to avoid ball getting stuck.
	if self.get_index() == Globals.min_dudeling_index() || self.get_index() == Globals.max_dudeling_index():
		game_ball.set_global_position(game_ball.get_global_position() + Vector2(0.0, -20.0))
	
	# Make classic goal goalies hit ball different.
	if ArenaController.get_current_game_field_index() == ArenaController.GameField.CLASSIC_GAME_FIELD:
		if (controlling_player == 1 && self.get_index() == Globals.max_dudeling_index()) || (controlling_player == 2 && self.get_index() == Globals.min_dudeling_index()):
			goal_pos = Vector2(640.0, 360.0)

	# Aim higher when targeting volley goals with dudelings that are close to the net.
	if ArenaController.get_current_game_field_index() == ArenaController.GameField.VOLLEY_GAME_FIELD:
		if game_ball.get_global_position().x > 440.0 && game_ball.get_global_position().x < 840.0 && game_ball.get_global_position().y > 540:
			goal_pos = Vector2(640.0, 0.0)

	var directon_normal: Vector2 = (goal_pos - game_ball.get_global_position()).normalized()
	var total_force: Vector2 = directon_normal * (game_ball.get_linear_velocity().length() + hit_force)
	game_ball.apply_impulse(game_ball.game_ball_radius() * -directon_normal, total_force - game_ball.get_linear_velocity())
	
	InputController.vibrate_controller(controlling_player, 0.0, 0.5, 0.4)

	self._start_dudeling_fall()


func _game_ball_entered(game_ball: GameBall) -> void:
	if !is_instance_valid(game_ball):
		return

	self._add_face_state(FaceState.FLINCH)

	if controlling_player == 0:
		return

	game_ball.give_player_control(controlling_player)
	
	if self.is_in_air():
		self._try_hit_ball(game_ball)


func _ball_exited() -> void:
	self._remove_face_state(FaceState.FLINCH)

	if controlling_player > 0:
		ArenaController.dudeling_row().other_dudeling(controlling_player)._check_game_ball_overlap()


func _check_game_ball_overlap() -> void:
	for body in $Hitbox.get_overlapping_bodies():
		if body.is_in_group(Globals.GAME_BALL_GROUP):
			self._game_ball_entered(body)


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GAME_BALL_GROUP):
		self._game_ball_entered(body)


func _on_Hitbox_body_exited(body: Node) -> void:
	if body.is_in_group(Globals.GAME_BALL_GROUP):
		self._ball_exited()


## Appearance.

func update_highlight(show_dudeling_highlight: bool) -> void:
	# if(!show_dudeling_highlight):
	$Body/JerseySprite.frame_coords.x = controlling_player if show_dudeling_highlight else 0


func change_jersey(jersey_index: int) -> void:
	$Body/JerseySprite.frame_coords.y = jersey_index


func randomize_appearance() -> void:
	# Skin.
	var skin_tone: int = Globals.rng.randi_range(0, $Body/BodySprite.get_hframes() - 1)
	$Body/BodySprite.set_frame_coords(Vector2(skin_tone, Globals.rng.randi_range(0, $Body/BodySprite.get_vframes() - 1)))
	$Body/HeadSprite.set_frame_coords(Vector2(skin_tone, Globals.rng.randi_range(0, $Body/HeadSprite.get_vframes() - 1)))

	# Face.
	$Body/HeadSprite/FaceSprite.frame_coords.y = Globals.rng.randi_range(0, $Body/HeadSprite/FaceSprite.get_vframes() - 1)

	# Hair.
	if Globals.rng.randf() <= 0.02:
		# BALD.
		$Body/HeadSprite/HairSprite.queue_free()
		$Body/HeadSprite/UnusualHairSprite.queue_free()
	elif Globals.rng.randf() <= 0.02:
		# UNIQUE.
		var num_frames: int = ($Body/HeadSprite/UnusualHairSprite.get_hframes() * $Body/HeadSprite/UnusualHairSprite.get_vframes()) - 1
		$Body/HeadSprite/UnusualHairSprite.set_frame(Globals.rng.randi_range(0, num_frames))
		$Body/HeadSprite/HairSprite.queue_free()
	else:
		# NORMAL.
		var num_frames: int = ($Body/HeadSprite/HairSprite.get_hframes() * $Body/HeadSprite/HairSprite.get_vframes()) - 1
		$Body/HeadSprite/HairSprite.set_frame(Globals.rng.randi_range(0, num_frames))
		$Body/HeadSprite/UnusualHairSprite.queue_free()


## Animations.

func celebrate(celebrate_time: float = -1.0) -> void:
	self._add_face_state(FaceState.CELEBRATE)
	
	if celebrate_time > 0.0:
		_face_timer.start(celebrate_time)
	else:
		_face_timer.stop()


func stop_celebrating() -> void:
	self._remove_face_state(FaceState.CELEBRATE)


func snap_effect(cloud_direction: int) -> void:
	var snap_cloud: DudelingSnapCloud = SNAP_CLOUD_SCENE.instance()
	ArenaController.game_field().add_child(snap_cloud)
	snap_cloud.set_global_position(self.get_global_position())
	snap_cloud.start(controlling_player, cloud_direction)


func tilt(direction: int, degrees: float, speed: float) -> void:
	var tilt_tween: SceneTreeTween = self.create_tween().set_parallel(true)
	var _a = tilt_tween.tween_property($Body, "rotation_degrees", direction * degrees, speed / 2.0)
	var _b = tilt_tween.chain().tween_property($Body, "rotation_degrees", 0.0, speed / 2.0)


func shake(degrees: float, speed: float, num_loops: int) -> void:
	var shake_tween: SceneTreeTween = self.create_tween().set_parallel(true)
	var _a = shake_tween.tween_property($Body, "rotation_degrees", degrees, speed / 4.0)
	var _b = shake_tween.chain().tween_property($Body, "rotation_degrees", -degrees, speed / 2.0)
	var _c = shake_tween.chain().tween_property($Body, "rotation_degrees", 0.0, speed / 4.0)
	var _d = shake_tween.set_loops(num_loops)


func crouch(crouch_scale: float, time_down: float, time_up: float) -> void:
	var crouch_tween: SceneTreeTween = self.create_tween().set_parallel(true)
	var _a = crouch_tween.tween_property($Body, "scale:y", crouch_scale, time_down)
	var _b = crouch_tween.chain().tween_property($Body, "scale:y", 1.0, time_up)


func _on_check_ball_over_head_timer_timeout() -> void:
	if self.is_under_any_ball():
		self._add_face_state(FaceState.LOOK_UP)
	else:
		self._remove_face_state(FaceState.LOOK_UP)


func _on_face_timer_timeout() -> void:
	if _face_state == 0:
		self._update_face_anim()
	elif self._face_state_contains(FaceState.CELEBRATE):
		self.stop_celebrating()


## Face states.

func _change_face_state(new_value: int) -> void:
	if _face_state ^ new_value:
		_face_state = new_value
		self._update_face_anim()


func _add_face_state(new_state: int) -> void:
	self._change_face_state(_face_state | new_state)


func _remove_face_state(target_state: int) -> void:
	self._change_face_state(_face_state & ~target_state)


func _face_state_contains(target_state: int) -> bool:
	return true if _face_state & target_state else false


func _update_face_anim() -> void:
	if self._face_state_contains(FaceState.STUNNED):
		$Body/HeadSprite/FaceSprite.frame_coords.x = FaceFrame.STUNNED
	elif self._face_state_contains(FaceState.FLINCH):
		$Body/HeadSprite/FaceSprite.frame_coords.x = FaceFrame.FLINCH
	elif self._face_state_contains(FaceState.LOOK_UP):
		$Body/HeadSprite/FaceSprite.frame_coords.x = FaceFrame.LOOK_UP
	elif self._face_state_contains(FaceState.CELEBRATE):
		$Body/HeadSprite/FaceSprite.frame_coords.x = FaceFrame.CELEBRATE
	elif self._face_state_contains(FaceState.LOOK_STRAIGHT):
		$Body/HeadSprite/FaceSprite.frame_coords.x = FaceFrame.LOOK_STRAIGHT
	else:  # Idle.
		$Body/HeadSprite/FaceSprite.frame_coords.x = Globals.rng.randi_range(FaceFrame.LOOK_LEFT, FaceFrame.LOOK_RIGHT)
		_face_timer.start(Globals.rng.randf_range(0.5, 2.0))


## Helpers.

func _make_face_timer() -> Timer:
	var face_timer := Timer.new()
	self.add_child(face_timer)
	face_timer.set_pause_mode(PAUSE_MODE_STOP)
	face_timer.set_one_shot(true)
	var _a = face_timer.connect("timeout", self, "_on_face_timer_timeout")
	return face_timer


func _make_stun_timer() -> Timer:
	var stun_timer := Timer.new()
	self.add_child(stun_timer)
	stun_timer.set_pause_mode(PAUSE_MODE_STOP)
	stun_timer.set_one_shot(true)
	var _a = stun_timer.connect("timeout", self, "end_stun")
	return stun_timer


func _make_player_stun_timer() -> Timer:
	var stun_timer := Timer.new()
	self.add_child(stun_timer)
	stun_timer.set_pause_mode(PAUSE_MODE_STOP)
	stun_timer.set_one_shot(true)
	var _a = stun_timer.connect("timeout", self, "_end_player_stun_effect")
	return stun_timer


func _make_check_ball_over_head_timer() -> Timer:
	var over_head_timer := Timer.new()
	self.add_child(over_head_timer)
	over_head_timer.set_pause_mode(PAUSE_MODE_STOP)
	over_head_timer.set_wait_time(0.1)
	var _a = over_head_timer.connect("timeout", self, "_on_check_ball_over_head_timer_timeout")
	return over_head_timer
