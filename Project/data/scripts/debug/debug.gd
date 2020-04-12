extends CanvasLayer

# Screen variables
var fullscreen : bool = false

# All debug inputs
var input : Dictionary = {};

func _process(_delta) -> void:
	# Calls the function to switch to fullscren or window with Alt and Enter
	_toggle_fullscreen();
	
	# Calls the function to show the framerate
	_display_framerate();
	
	# Calls the function to reset the game
	_reload_scene();

func _toggle_fullscreen() -> void:
	# If you don't have a fullscreen node timer it will create a
	if not has_node("timer_fullscreen"):
		# Creates a timer
		var timer = Timer.new();
		
		# Change timer name to fullscreen
		timer.name = "timer_fullscreen";
		
		# The timer time
		timer.wait_time = 0.2;
		
		# Timer will count once and stop
		timer.one_shot = true;
		
		# Adds the timer to the debug
		add_child(timer);
	
	else: # if you already have the fullscreen node timer
		# Get the fullscreen node timer
		var timer = $"timer_fullscreen";
		
		# If the timer reaches zero I can change the screen mode
		if !timer.time_left:
			input["enter"] = Input.is_action_pressed("KEY_ENTER");
			input['alt']   = Input.is_action_pressed("KEY_ALT");
			
			if input['alt'] and input['enter']:
				fullscreen = !fullscreen;
				
				OS.window_fullscreen = fullscreen;
				
				# Starts the timer again
				timer.start();

func _display_framerate() -> void:
	# If you don't have the framerate label
	if not has_node("framerate_label"):
		# Create a new label
		var framerate_label = Label.new();
		
		# Renames the label to framerate label
		framerate_label.name = "framerate_label";
		
		# Changes the position of the framerate label
		framerate_label.rect_position = Vector2(5, 5)
		
		# Changes the color of the framerate label
		framerate_label.add_color_override("font_color", ColorN("black"))
		
		# Adds the framerate label to the debug
		add_child(framerate_label);
	else:
		# Get the framerate label
		var framerate_label = $"framerate_label";
		
		# Changes the text of the label to that of the framerate
		framerate_label.text = str(Engine.get_frames_per_second());

func _reload_scene() -> void:
	# Input
	input["reload"] = Input.is_action_just_pressed("KEY_F6")
	
	# If I press the reload button
	if input["reload"]:
		# Reload the scene
		get_tree().reload_current_scene();
