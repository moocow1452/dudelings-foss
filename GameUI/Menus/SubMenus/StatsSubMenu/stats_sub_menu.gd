class_name StatsSubMenu
extends SubMenu
# A sub menu for showing player stats
#
# @author gbryant
# @copyright 2024 Heavy Element

onready var stats: Dictionary = {
	"total_score": {
		"node": $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/total_score,
		"callback": "_default_update"
	},
	"games_played": {
		"node": $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/games_played,
		"callback": "callback_games_played"
	},
	"favorite_game_mode": {
		"node": $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/favorite_game_mode,
		"callback": "callback_favorite_game_mode"
	},
	"give_punch": {
		"node": $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/give_punch,
		"callback": "_default_update"
	},
	"knocked_out": {
		"node": $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/knocked_out,
		"callback": "_default_update"
	},
	"pickups_activated": {
		"node": $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/pickups_activated,
		"callback": "_default_update"
	},
	"pickups_cancelled": {
		"node": $BackgroundPanel/MenuContainer/ScrollContainer/ElementContainer/pickups_cancelled,
		"callback": "_default_update"
	},
}


func _ready() -> void:
	# Call before connecting signals to avoid triggering them.

	self._update_menu()

	# Connect signals.
	var _z = $BackgroundPanel.connect("clicked_outside", self, "queue_free")
	
	stats.total_score.node.call_deferred("grab_focus")

	InputController.button_context_bar().hide_all()
	InputController.button_context_bar().show_close("BACK")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if Globals.focused_menu() != self:
		return


func _update_menu() -> void:
	for element in stats:
		var value = stats[element].node.find_node("Value")
		match(element):
			"games_played":
				callback_games_played(element, value)
			"favorite_game_mode":
				callback_favorite_game_mode(element, value)
			_:
				_default_update(element, value)
		

func _default_update(stat_name, value_node):
	value_node.text = "%s" % PlayerStats.achievement_progression[stat_name]

func callback_games_played(_stat_name, value_node):
	var wins = PlayerStats.achievement_progression.games_won
	var played_to_complete = PlayerStats.achievement_progression.games_played - PlayerStats.achievement_progression.games_quit
	var string = "%s" % wins
	string += "/%s" % abs(played_to_complete - wins)
	value_node.text = string

func callback_favorite_game_mode(_stat_name, value_node):
	var mode_0 = PlayerStats.achievement_progression.mode_0
	var mode_1 = PlayerStats.achievement_progression.mode_1
	var mode_2 = PlayerStats.achievement_progression.mode_2
	var mode_3 = PlayerStats.achievement_progression.mode_3
	var _max = [mode_0, mode_1, mode_2, mode_3].max()
	if(mode_0 == _max):
		value_node.text = "Classic"
	elif(mode_1 == _max):
		value_node.text = "Hoops"
	elif(mode_2 == _max):
		value_node.text = "Volley"
	elif(mode_3 == _max):
		value_node.text = "Pins"
	else:
		value_node.text = "Unknown"


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().show_reset()
	InputController.button_context_bar().show_close()
