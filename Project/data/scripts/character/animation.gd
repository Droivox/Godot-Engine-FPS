extends AnimationPlayer;

# Get character's node path
@export var character: NodePath;
var character_node: Node;

func _ready():
	if character != NodePath():
		character_node = get_node(character);

func _process(_delta):
	if character_node:
		# A dynamic animation function for the neck
		_neck_animation(_delta)

		# Calls a function with animations
		_animation()

func _animation() -> void:
	if not character_node:
		return
		
	# If the player presses the jump button
	if character_node.input["jump"]:
		# Checks if the jump animation is active
		if current_animation != "jump":
			# Starts the jump animation
			play("jump", 0.3);

	# If the character is moving
	if character_node.direction:
		# If the current animation is not a walk
		if current_animation != "jump":
			if character_node.input["sprint"]:
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
	if not character_node:
		return
		
	# Neck rotation speed
	var rotation_speed : float = character_node.n_speed * _delta 

	# Get the camera node
	var camera : Node = $"../camera";

	# Creates the angle based on the character's movement
	var angle : float = 2.0 * (float(character_node.input["right"]) + -float(character_node.input["left"]));

	# Apply an interpolation to neck rotation based on angle
	camera.rotation.z = lerp(camera.rotation.z, -deg_to_rad(angle), rotation_speed)
