class_name HowToPlaySubMenu
extends SubMenu
# A sub menu for displaying how to play the game.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

const MOVE_BUTTONS: String = "[img]res://GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/move_buttons.tres[/img]"
const SNAP_BUTTONS: String = "[img]res://GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/snap_buttons.tres[/img]"
const JUMP_BUTTONS: String = "[img]res://GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/jump_buttons.tres[/img]"
const DASH_BUTTONS: String = "[img]res://GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/dash_buttons.tres[/img]"
const PUNCH_BUTTONS: String = "[img]res://GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/punch_buttons.tres[/img]"
const HTP_TEXTS: Array = [
	"""[center]In a game of Dudelings, your goal is to control the ball and score points.

	First, use %s to cycle through available Dudelings.[/center]""" % [MOVE_BUTTONS],
	"""[center]You can also use %s to snap to the left- and right-most Dudelings, respectively.[/center]""" % [SNAP_BUTTONS],
	"""[center]Hold %s to make your Dudeling jump, the longer you hold %s, the higher you'll jump.[/center]""" % [JUMP_BUTTONS, JUMP_BUTTONS],
	"""[center]When you touch a ball with your Dudeling, it will change to your color.

	Your Dudeling will also “throw” the ball towards the goal if there's a clear shot.

	Note: you can't score on your own goal.[/center]""",
	"""[center]Each team has a pool of stamina which can be spent on special actions. It costs 1 stamina to punch, and 2 to dash.

	If you don't have enough stamina, you can't perform a given action.[/center]""",
	"""[center]Use %s to throw a punch and knock out adjacent Dudelings.

	Knocked out Dudelings cannot be used until they recover.

	Watch out! If your current Dudeling gets knocked out, you'll be frozen in place for a moment.[/center]""" % [PUNCH_BUTTONS],
	"""[center]Press %s to perform a dash.

	Dashes are faster and can come in clutch to prevent a goal or give the ball a little extra umph.[/center]""" % [DASH_BUTTONS],
]
const HTP_VIDEOS: Array = [
	preload("res://Assets/GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/how_to_play_0.ogv"),
	preload("res://Assets/GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/how_to_play_1.ogv"),
	preload("res://Assets/GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/how_to_play_2.ogv"),
	preload("res://Assets/GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/how_to_play_3.ogv"),
	preload("res://Assets/GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/how_to_play_4.ogv"),
	preload("res://Assets/GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/how_to_play_5.ogv"),
	preload("res://Assets/GameUI/Menus/SubMenus/HowToPlaySubMenu/resources/how_to_play_6.ogv"),
]

var _current_slide_index: int = 0

onready var _video_player: VideoPlayer = $BackgroundPanel/MenuContainer/VideoPlayer
onready var _text_label: RichTextLabel = $BackgroundPanel/MenuContainer/CenterContainer/TextLabel


func _ready() -> void:
	var _a = $BackgroundPanel.connect("clicked_outside", self, "queue_free")
	var _b = _video_player.connect("finished", _video_player, "play")

	self._show_slide(0, false)
	
	self.call_deferred("grab_focus")


func _process(_delta: float) -> void:
	if SceneController.is_switching_scenes():
		return

	if self.get_focus_owner() != self:
		return
	
	if Input.is_action_just_pressed("ui_left"):
		self.accept_event()
		self._show_slide(_current_slide_index - 1)
	
	if Input.is_action_just_pressed("ui_right"):
		self.accept_event()
		self._show_slide(_current_slide_index + 1)


func update_button_context_bar() -> void:
	if !is_instance_valid(InputController.button_context_bar()):
		return
	
	InputController.button_context_bar().hide_all()
	
	if _current_slide_index < HTP_VIDEOS.size() - 1:
		InputController.button_context_bar().show_right("NEXT")
	
	if _current_slide_index > 0:
		InputController.button_context_bar().show_left("PREVIOUS")
	
	InputController.button_context_bar().show_close()


func _show_slide(slide_index: int, with_sound: bool = true) -> void:
	if slide_index < 0 || slide_index >= HTP_VIDEOS.size():
		if with_sound:
			AudioController.play_ui_sound(ButtonElement.DISABLED_SOUND)
		
		return
	
	_current_slide_index = slide_index
	
	if with_sound:
		AudioController.play_ui_sound(ButtonElement.PRESSED_SOUND)

	_text_label.set_bbcode(HTP_TEXTS[_current_slide_index])
	_video_player.set_stream(HTP_VIDEOS[_current_slide_index])
	_video_player.play()
	
	self.update_button_context_bar()  ## Call here. Control focus never changes.
