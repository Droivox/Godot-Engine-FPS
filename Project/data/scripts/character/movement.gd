extends CharacterBody3D

# All speed variables
var n_speed : float = 04; # Normal
var s_speed : float = 12; # Sprint
var w_speed : float = 08; # Walking
var c_speed : float = 10; # Crouch

# Physics variables
var gravity      : float = 50; # Gravity force
var jump_height  : float = 15; # Jump height
var friction     : float = 25; # friction

# All vectors
var direction    : = Vector3(); # Direction Vector
var acceleration : = Vector3(); # Acceleration Vector

# All character inputs
var input : Dictionary = {};

func _physics_process(_delta) -> void:
	# Function for movement
	_movement(_delta);
	
	# Function for crouch
	_crouch(_delta);
	
	# Function for jump
	_jump(_delta);
	
	# Function for sprint
	_sprint(_delta)

func _movement(_delta) -> void:
	# Inputs
	input["left"]   = int(Input.is_action_pressed("KEY_A"));
	input["right"]  = int(Input.is_action_pressed("KEY_D"));
	input["foward"] = int(Input.is_action_pressed("KEY_W"));
	input["back"]   = int(Input.is_action_pressed("KEY_S"));
	
	# Check is on floor
	if is_on_floor():
		direction = Vector3();
	else:
		direction = direction.lerp(Vector3(), friction * _delta);
		
		# Applies gravity
		velocity.y += -gravity * _delta;
	
	var basis = $"head".global_transform.basis;
	direction += (-input["left"]    + input["right"]) * basis.x;
	direction += (-input["foward"]  +  input["back"]) * basis.z;
	
	direction.y = 0; direction = direction.normalized()
	
	# Interpolates between the current position and the future position of the character
	var target = direction * n_speed; direction.y = 0;
	var temp_velocity = velocity.lerp(target, n_speed * _delta);
	
	# Applies interpolation to the velocity vector
	velocity.x = temp_velocity.x;
	velocity.z = temp_velocity.z;
	
	# Calls the motion function by passing the velocity vector
	set_velocity(velocity)
	set_up_direction(Vector3(0, 1, 0))
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(4)
	set_floor_max_angle(PI/4)
	move_and_slide()
	velocity = velocity;

func _crouch(_delta) -> void:
	# Inputs
	input["crouch"] = int(Input.is_action_pressed("KEY_CTRL"));
	
	# Get the character's head node
	var head = $"head";
	
	# If the head node is not touching the ceiling
	if not head.is_colliding():
		# Takes the character collision node
		var collision = $"collision";
		
		# Get the character's collision shape
		var shape = collision.shape.height;
		
		# Changes the shape of the character's collision
		shape = lerp(shape, 2.0 - (float(input["crouch"]) * 1.5), c_speed * _delta);
		
		# Apply the new character collision shape
		collision.shape.height = shape;

func _jump(_delta) -> void:
	# Inputs
	input["jump"] = int(Input.is_action_pressed("KEY_SPACE"));
	
	# Makes the player jump if he is on the ground
	if input["jump"]:
		if is_on_floor():
			velocity.y = jump_height;

func _sprint(_delta) -> void:
	# Inputs
	input["sprint"] = int(Input.is_action_pressed("KEY_SHIFT"));
	
	# Make the character sprint
	if not input["crouch"]: # If you are not crouching
		# switch between sprint and walking
		var toggle_speed : float = w_speed + ((s_speed - w_speed) * float(input["sprint"]))
		
		# Create a character speed interpolation
		n_speed = lerp(n_speed, toggle_speed, 3.0 * _delta);
	else:
		# Create a character speed interpolation
		n_speed = lerp(n_speed, w_speed, _delta);
