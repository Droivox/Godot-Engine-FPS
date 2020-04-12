extends AnimationPlayer;

# Get character's node path
export(NodePath) var character;

func _ready():
	# Get character's node path
	character = get_node(character);

func _process(_delta):
	# A dynamic animation function for the neck
	_neck_animation(_delta)

	# Calls a function with animations
	_animation()

func _animation() -> void:
	# If the player presses the jump button
	if character.input["jump"]:
		# Checks if the jump animation is active
		if current_animation != "jump":
			# Starts the jump animation
			play("jump", 0.3);

	# If the character is moving
	if character.direction:
		# If the current animation is not a walk
		if current_animation != "jump":
			if character.input["sprint"]:
				if current_animation != "sprint":
					play("sprint", 0.3, 1.5);
			else:
				if current_animation != "walk":
					play("walk", 0.3);
	else:
		# If the current animation is not idle
		if current_animation != "idle" and current_animation != "jump":
			# Starts animation with smoothing
			play("idle", 0.3, 0.1);

func _neck_animation(_delta) -> void:
	# Neck rotation speed
	var rotation_speed : float = character.n_speed * _delta 

	# Get the camera node
	var camera : Node = $"../camera";

	# Creates the angle based on the character's movement
	var angle : float = 2 * (character.input["right"] + -character.input["left"]);

	# Apply an interpolation to neck rotation based on angle
	camera.rotation.z = lerp(camera.rotation.z, -deg2rad(angle), rotation_speed)
