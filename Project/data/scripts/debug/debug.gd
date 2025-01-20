extends CanvasLayer


# Screen variables
var fullscreen: bool = false

# All debug inputs
var input_enter: int  = 0
var input_alt: int    = 0
var input_reload: int = 0

onready var framerate_label: Label = $FramerateLabel
onready var timer_fullscreen: Timer = $TimerFullscreen


func _process(_delta: float) -> void:
	# Calls the function to switch to fullscren or window with Alt and Enter
	_toggle_fullscreen()

	# Calls the function to show the framerate
	_display_framerate()

	# Calls the function to reset the game
	_reload_scene()


func _toggle_fullscreen() -> void:
	# If the timer reaches zero I can change the screen mode
	if not timer_fullscreen.time_left:
		input_enter = Input.is_action_pressed("KEY_ENTER")
		input_alt = Input.is_action_pressed("KEY_ALT")

		if input_alt and input_enter:
			fullscreen = not fullscreen

			OS.window_fullscreen = fullscreen

			# Starts the timer again
			timer_fullscreen.start()


func _display_framerate() -> void:
	# Changes the text of the label to that of the framerate
	framerate_label.text = str(Engine.get_frames_per_second())


func _reload_scene() -> void:
	# Input
	input_reload = Input.is_action_just_pressed("KEY_F6")

	# If I press the reload button
	if input_reload:
		# Reload the scene
		get_tree().reload_current_scene()
