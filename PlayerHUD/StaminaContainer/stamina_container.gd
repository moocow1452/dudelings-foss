class_name StaminaContainer
extends TextureRect
# A HUD element that shows the current stamina for a target player.
#
# @author ethan_hewlett
# @copyright 2023 Heavy Element
const PITCH_SCALE: Array = [0.9, 1.0, 1.2]
const STAMINA_CHARGE_LOW_SOUND: AudioStreamOGGVorbis = preload("res://Assets/PlayerHUD/StaminaContainer/audio/stamina_recharge_low.ogg")
const STAMINA_CHARGE_MID_SOUND: AudioStreamOGGVorbis = preload("res://Assets/PlayerHUD/StaminaContainer/audio/stamina_recharge_mid.ogg")
const STAMINA_CHARGE_FULL_SOUND: AudioStreamOGGVorbis = preload("res://Assets/PlayerHUD/StaminaContainer/audio/stamina_recharge_full.ogg")

export(int, 0, 2) var target_player setget set_target_player, get_target_player


func set_target_player(new_value: int) -> void:
	target_player = new_value


func get_target_player() -> int:
	return target_player


func _ready() -> void:
	var _a = ArenaController.dudeling_row().connect("stamina_changed", self, "_update_stamina_bar")
	self._update_stamina_bar(target_player, DudelingRow.TOTAL_STAMINA, DudelingRow.TOTAL_STAMINA)


func _update_stamina_bar(player: int, old_value: int, new_value: int) -> void:
	if target_player != player:
		return

	var start_index: int = old_value if old_value < new_value else new_value
	var end_index: int = new_value if old_value < new_value else old_value

	$StaminaContainerLight0.set_charged(new_value >= 1, start_index < 1 && 1 <= end_index)
	$StaminaContainerLight1.set_charged(new_value >= 2, start_index < 2 && 2 <= end_index)
	$StaminaContainerLight2.set_charged(new_value >= 3, start_index < 3 && 3 <= end_index)

	if old_value < new_value:
		var audio_stream: AudioStreamOGGVorbis = (
			STAMINA_CHARGE_LOW_SOUND if new_value == 1 else
			STAMINA_CHARGE_MID_SOUND if new_value == 2 else
			STAMINA_CHARGE_FULL_SOUND
		)
		$AudioStreamPlayer2D.set_stream(audio_stream)
		$AudioStreamPlayer2D.set_pitch_scale(PITCH_SCALE[new_value - 1])
		$AudioStreamPlayer2D.play()
