class_name PerformancePanel
extends Panel
# A debug tool used to show game performance.
#
# @author ethan_hewlett
# @copyright 2024 Heavy Element

var _update_timer: Timer = self._make_update_timer()


func _ready() -> void:
	self._show_panel(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.scancode == KEY_F11:
			Globals.get_tree().set_input_as_handled()
			self._show_panel(!self.is_visible())


func _show_panel(show_panel: bool) -> void:
	self.set_visible(show_panel)
	
	if show_panel:
		_update_timer.start()
	else:
		_update_timer.stop()


func _update_panel() -> void:
	$InfoLabel.set_text(
		"""FPS: %s
		Process time: %s per second
		Physics process time: %s per second
		Draw calls: %s per frame
		---
		Static memory used: %s bytes of %s bytes
		Dynamic memory used: %s bytes of %s bytes
		Graphics memory used: %s
		---
		# of objects: %s
		# of resources: %s
		# of nodes: %s
		# of unparented nodes: %s""" % [
			Performance.get_monitor(Performance.TIME_FPS),
			Performance.get_monitor(Performance.TIME_PROCESS),
			Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
			Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME),
			Performance.get_monitor(Performance.MEMORY_STATIC),
			Performance.get_monitor(Performance.MEMORY_STATIC_MAX),
			Performance.get_monitor(Performance.MEMORY_DYNAMIC),
			Performance.get_monitor(Performance.MEMORY_DYNAMIC_MAX),
			Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),
			Performance.get_monitor(Performance.OBJECT_COUNT),
			Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
			Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
			Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		]
	)


func _make_update_timer() -> Timer:
	var update_timer := Timer.new()
	self.add_child(update_timer)
	update_timer.set_wait_time(0.1)
	var _a = update_timer.connect("timeout", self, "_update_panel")
	return update_timer
