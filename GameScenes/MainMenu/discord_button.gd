extends Button
# A button handler for external links to Discord/Revolt
#
# @author gbryant
# @copyright 2025 Heavy Element

const FOCUSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_focused.ogg")
const PRESSED_SOUND: AudioStreamOGGVorbis = preload("res://Assets/GameUI/MenuElements/audio/ui_pressed.ogg")
onready var sprite = $Sprite
export var href: String = ""
export var start_frame: int = 1
export var hover_frame: int = 0

func _ready():
	var _a  = self.connect("mouse_entered", self, "_on_mouse_entered", [true])
	var _aa = self.connect("focus_entered", self, "_on_mouse_entered", [false])
	var _b  = self.connect("mouse_exited", self, "_on_mouse_exit")
	var _bb = self.connect("focus_exited", self, "_on_mouse_exit")
	var _c = self.connect("pressed", self, "_on_pressed")

func _on_pressed() -> void:
	AudioController.play_ui_sound(PRESSED_SOUND)
	var _a = OS.shell_open(href)

func _on_mouse_entered(grab) -> void:
	AudioController.play_ui_sound(FOCUSED_SOUND)
	if grab == true: self.call_deferred("grab_focus")
	sprite.frame = start_frame
	sprite.scale = Vector2(1.25, 1.25)

func _on_mouse_exit() -> void:
	sprite.frame = hover_frame
	sprite.scale = Vector2(1, 1)
