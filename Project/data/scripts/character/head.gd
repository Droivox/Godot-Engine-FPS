extends Spatial


export var sensibility: float = 0.2 # Mouse sensitivity
export var captured: bool = true # Does not let the mouse leave the screen

#onready var character: MovementPlayer = get_node("..")
onready var max_angle: float = deg2rad(85.0) # Maximum camera angle


func _physics_process(_delta: float) -> void:
	# Calls function to switch between locked and unlocked mouse
	_mouse_toggle()


func _mouse_toggle() -> void:
	# Function to lock or unlock the mouse in the center of the screen
	if Input.is_action_just_pressed("KEY_ESCAPE"):
		# Captured will receive the opposite of the value itself
		captured = not captured

	if captured:
		# Locks the mouse in the center of the screen
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# Unlocks the mouse from the center of the screen
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _camera_rotation(event: InputEvent) -> void:
	# If the mouse is locked
	if captured:
		#var camera: Dictionary = {0: $".", 1: $"."}

		if event is InputEventMouseMotion:
			# Rotates the camera on the x axis
			# camera[0].rotation.x += -deg2rad(event.relative.y * sensibility)
			rotation.x += -deg2rad(event.relative.y * sensibility)

			# Rotates the camera on the y axis
			# camera[1].rotation.y += -deg2rad(event.relative.x * sensibility)
			rotation.y += -deg2rad(event.relative.x * sensibility)

		# Creates a limit for the camera on the x axis
		#camera[0].rotation.x = min(camera[0].rotation.x,  max_angle)
		#camera[0].rotation.x = max(camera[0].rotation.x, -max_angle)
		rotation.x = min(rotation.x,  max_angle)
		rotation.x = max(rotation.x, -max_angle)


func _input(event: InputEvent) -> void:
	# Calls the function to rotate the camera
	_camera_rotation(event)
