extends KinematicBody
class_name MovementPlayer


# All speed variables
var n_speed: float = 4.0  # Normal
var s_speed: float = 12.0 # Sprint
var w_speed: float = 8.0  # Walking
var c_speed: float = 10.0 # Crouch

# Physics variables
var gravity: float         = 50.0 # Gravity force
var jump_height: float     = 15.0 # Jump height
var friction: float        = 25.0 # friction
var floor_max_angle: float = PI/4.0

# All vectors
var linear_velocity: Vector3 = Vector3() # Velocity vector
var direction: Vector3       = Vector3() # Direction Vector
#var acceleration: Vector3    = Vector3() # Acceleration Vector
var player_up: Vector3       = Vector3.UP

onready var head: RayCast = $head
onready var collision: CollisionShape = $collision # Takes the character collision node

# All character inputs
var input_left: int   = 0
var input_right: int  = 0
var input_foward: int = 0
var input_back: int   = 0
var input_crouch: int = 0
var input_sprint: int = 0
var input_jump: int   = 0


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
	input_left   = int(Input.is_action_pressed("KEY_A"))
	input_right  = int(Input.is_action_pressed("KEY_D"))
	input_foward = int(Input.is_action_pressed("KEY_W"))
	input_back   = int(Input.is_action_pressed("KEY_S"))

	# Check is on floor
	if is_on_floor():
		direction = Vector3.ZERO
	else:
		direction = direction.linear_interpolate(Vector3.ZERO, friction * delta)

		# Applies gravity
		linear_velocity.y += -gravity * delta

	var gbasis: Basis = head.global_transform.basis
	direction += (-input_left + input_right) * gbasis.x
	direction += (-input_foward + input_back) * gbasis.z

	direction.y = 0.0
	direction = direction.normalized()

	# Interpolates between the current position and the future position of the character
	var target: Vector3 = direction * n_speed
	var temp_linear_velocity: Vector3 = linear_velocity.linear_interpolate(target, n_speed * delta)

	direction.y = 0.0

	# Applies interpolation to the linear_velocity vector
	linear_velocity.x = temp_linear_velocity.x
	linear_velocity.z = temp_linear_velocity.z

	# Calls the motion function by passing the linear_velocity vector
	linear_velocity = move_and_slide(linear_velocity, player_up, false, 4, floor_max_angle, false)



func _crouch(delta: float) -> void:
	# Inputs
	input_crouch = int(Input.is_action_pressed("KEY_CTRL"))

	# If the head node is not touching the ceiling
	if not head.is_colliding():
		# Get the character's collision shape
		var shape: float = collision.shape.height

		# Changes the shape of the character's collision
		shape = lerp(shape, 2.0 - (input_crouch * 1.5), c_speed  * delta)

		# Apply the new character collision shape
		collision.shape.height = shape


func _jump(_delta: float) -> void:
	# Inputs
	input_jump = int(Input.is_action_pressed("KEY_SPACE"))

	# Makes the player jump if he is on the ground
	if input_jump and is_on_floor():
			linear_velocity.y = jump_height


func _sprint(delta: float) -> void:
	# Inputs
	input_sprint = int(Input.is_action_pressed("KEY_SHIFT"))

	# Make the character sprint
	if not input_crouch: # If you are not crouching
		# switch between sprint and walking
		var toggle_speed: float = w_speed + ((s_speed - w_speed) * input_sprint)

		# Create a character speed interpolation
		n_speed = lerp(n_speed, toggle_speed, 3.0 * delta)
	else:
		# Create a character speed interpolation
		n_speed = lerp(n_speed, w_speed, delta)
