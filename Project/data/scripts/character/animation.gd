extends AnimationPlayer;

# Get character's node path
export(NodePath) var character;

func _ready() -> void:
	# Get character's node path
	character = get_node(character);

func _process(delta: float) -> void:
	# A dynamic animation function for the neck
	_neck_animation(delta)

	# Calls a function with animations
	_animation()

func _animation() -> void:
	# If the player presses the jump button
	if character.input["jump"] and current_animation != "jump":
		# Checks if the jump animation is active
		# Starts the jump animation
		play("jump", 0.3)

	# If the character is moving
	if character.direction and current_animation != "jump":
		# If the current animation is not a walk
		if character.input["sprint"]:
			if current_animation != "sprint":
				play("sprint", 0.3, 1.5)
		else:
			if current_animation != "walk":
				play("walk", 0.3)
	else:
		# If the current animation is not idle
		if current_animation != "idle" and current_animation != "jump":
			# Starts animation with smoothing
			play("idle", 0.3, 0.1);

func _neck_animation(delta: float) -> void:
	# Neck rotation speed
	var rotation_speed : float = character.n_speed * delta 

	# Get the camera node
	var camera : Node = $"../camera";

	# Creates the angle based on the character's movement
	var angle : float = 2.0 * (character.input["right"] + -character.input["left"]);

	# Apply an interpolation to neck rotation based on angle
	camera.rotation.z = lerp(camera.rotation.z, -deg2rad(angle), rotation_speed)
