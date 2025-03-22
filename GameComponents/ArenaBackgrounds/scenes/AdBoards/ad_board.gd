tool
class_name AdBoard
extends Sprite
# A billboard for showing images. It is paired with 'an ad board player' to allow for the playing of ads.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

export var one_off_ads_sheet: Texture = preload("res://Assets/ArenaBackgrounds/scenes/AdBoards/art/ad_board_one_offs.png") setget set_one_off_ads_sheet, get_one_off_ads_sheet
export var home_team_sheet: Texture = preload("res://Assets/ArenaBackgrounds/scenes/AdBoards/art/ad_board_lets_go_home.png") setget set_home_team_sheet, get_home_team_sheet
export var away_team_sheet: Texture = preload("res://Assets/ArenaBackgrounds/scenes/AdBoards/art/ad_board_lets_go_away.png") setget set_away_team_sheet, get_away_team_sheet


func set_one_off_ads_sheet(new_value: Texture) -> void:
	one_off_ads_sheet = new_value
	self.set_texture(one_off_ads_sheet)


func get_one_off_ads_sheet() -> Texture:
	return one_off_ads_sheet


func set_home_team_sheet(new_value: Texture) -> void:
	home_team_sheet = new_value


func get_home_team_sheet() -> Texture:
	return home_team_sheet


func set_away_team_sheet(new_value: Texture) -> void:
	away_team_sheet = new_value


func get_away_team_sheet() -> Texture:
	return away_team_sheet


func num_ads() -> int:
	return self.get_vframes()


func change_ad(ad_index: int) -> void:
	self.frame_coords.y = clamp(ad_index, 0, self.get_vframes() - 1)


func change_ad_sheet(ad_sheet: Texture, v_frames: int) -> void:
	self.set_texture(ad_sheet)
	self.set_vframes(v_frames)
