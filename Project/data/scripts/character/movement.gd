extends KinematicBody

# All speed variables
var n_speed : float = 4.0 # Normal
var s_speed : float = 12.0 # Sprint
var w_speed : float = 8.0 # Walking
var c_speed : float = 10.0 # Crouch

# Physics variables
var gravity      : float = 50.0 # Gravity force
var jump_height  : float = 15.0 # Jump height
var friction     : float = 25.0 # friction

# All vectors
var velocity     := Vector3() # Velocity vector
var direction    := Vector3() # Direction Vector
var acceleration := Vector3() # Acceleration Vector

# All character inputs
var input : Dictionary = {}

func _physics_process(delta: float) -> void:
	# Function for movement
	_movement(delta)

	# Function for crouch
	_crouch(delta)

	# Function for jump
	_jump(delta)

	# Function for sprint
	_sprint(delta)

func _movement(delta: float) -> void:
	# Inputs
	input["left"]   = int(Input.is_action_pressed("KEY_A"))
	input["right"]  = int(Input.is_action_pressed("KEY_D"))
	input["foward"] = int(Input.is_action_pressed("KEY_W"))
	input["back"]   = int(Input.is_action_pressed("KEY_S"))

	# Check is on floor
	if is_on_floor():
		direction = Vector3()
	else:
		direction = direction.linear_interpolate(Vector3.ZERO, friction * delta)

		# Applies gravity
		velocity.y += -gravity * delta

	var basis = $"head".global_transform.basis
	direction += (-input["left"]    + input["right"]) * basis.x
	direction += (-input["foward"]  +  input["back"]) * basis.z

	direction.y = 0; direction = direction.normalized()

	# Interpolates between the current position and the future position of the character
	var target = direction * n_speed; direction.y = 0
	var temp_velocity = velocity.linear_interpolate(target, n_speed * delta)

	# Applies interpolation to the velocity vector
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z

	# Calls the motion function by passing the velocity vector
	# Vector3(0, 1, 0)
	velocity = move_and_slide(velocity, Vector3.UP, false, 4.0, PI / 4.0, false)

func _crouch(delta: float) -> void:
	# Inputs
	input["crouch"] = int(Input.is_action_pressed("KEY_CTRL"))

	# Get the character's head node
	var head = $"head"

	# If the head node is not touching the ceiling
	if not head.is_colliding():
		# Takes the character collision node
		var collision = $"collision"
		
		# Get the character's collision shape
		var shape = collision.shape.height
		
		# Changes the shape of the character's collision
		shape = lerp(shape, 2 - (input["crouch"] * 1.5), c_speed  * delta)
		
		# Apply the new character collision shape
		collision.shape.height = shape

func _jump(delta: float) -> void:
	# Inputs
	input["jump"] = int(Input.is_action_pressed("KEY_SPACE"))

	# Makes the player jump if he is on the ground
	if input["jump"] and is_on_floor():
		velocity.y = jump_height

func _sprint(delta: float) -> void:
	# Inputs
	input["sprint"] = int(Input.is_action_pressed("KEY_SHIFT"))

	# Make the character sprint
	if not input["crouch"]: # If you are not crouching
		# switch between sprint and walking
		var toggle_speed : float = w_speed + ((s_speed - w_speed) * input["sprint"])

		# Create a character speed interpolation
		n_speed = lerp(n_speed, toggle_speed, 3 * delta)
	else:
		# Create a character speed interpolation
		n_speed = lerp(n_speed, w_speed, delta)
