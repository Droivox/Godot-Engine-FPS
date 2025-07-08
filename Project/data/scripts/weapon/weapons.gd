extends Node3D

# Get character's node path
@export var character: NodePath;

# Get head's node path
@export var head: NodePath;

# Get camera's node path
@export var neck: NodePath;

# Get camera's node path
@export var camera: NodePath;

var character_node: Node;
var head_node: Node;
var neck_node: Node;
var camera_node: Node;

# Load weapon class for make weapons
var weapon = load("res://data/scripts/weapon/weapon.gd");

# All weapons
var arsenal : Dictionary;

# Current weapon
var current : int = 0;

# Dict of inputs
var input : Dictionary = {};

func _ready() -> void:
	set_as_top_level(true);
	
	if character != NodePath():
		character_node = get_node(character);
	if head != NodePath():
		head_node = get_node(head);
	if neck != NodePath():
		neck_node = get_node(neck);
	if camera != NodePath():
		camera_node = get_node(camera);
	
	# Class reference : 
	# owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed;
	
	# Create mk 23 using weapon classs
	arsenal["mk_23"] = weapon.weapon.new(self, "mk_23", 2.0, 12, 999, 12, 40, 1.2);
	
	# Create glock 17 using weapon class
	arsenal["glock_17"] = weapon.weapon.new(self, "glock_17", 3.0, 12, 999, 12, 35, 1.2);
	
	# Create kriss using weapon class
	arsenal["kriss"] = weapon.weapon.new(self, "kriss", 6.0, 32, 999, 33, 25, 1.5);
	
	for w in arsenal:
		arsenal.values()[current]._hide();

func get_camera_node() -> Node:
	return camera_node;

func _physics_process(_delta) -> void:
	if not character_node or not head_node or not camera_node:
		return
		
	# Call weapon function
	_weapon(_delta);
	_change();
	_position(_delta);

func _weapon(_delta) -> void:
	input["shoot"] = int(Input.is_action_pressed("mb_left"));
	input["reload"] = int(Input.is_action_pressed("KEY_R"));
	input["zoom"] = int(Input.is_action_pressed("mb_right"));
	
	arsenal.values()[current]._sprint(character_node.input["sprint"] or character_node.input["jump"], _delta);
	
	if not character_node.input["sprint"] or not character_node.direction:
		if input["shoot"]:
			arsenal.values()[current]._shoot(_delta);
		
		arsenal.values()[current]._zoom(input["zoom"], _delta);
	
	if input["reload"]:
		arsenal.values()[current]._reload();
	
	# Update arsenal
	for w in range(arsenal.size()):
		arsenal.values()[w]._update(_delta);

func _change() -> void:
	# change weapons
	for w in range(arsenal.size()):
		if arsenal.values()[w] != arsenal.values()[current]:
			arsenal.values()[w]._hide();
		else:
			arsenal.values()[w]._draw();

func _position(_delta) -> void:
	var y_lerp = 20;
	var x_lerp = 40;
	
	global_transform.origin = head_node.global_transform.origin;
	
	if not input["zoom"]:
		rotation.x = lerp_angle(rotation.x, camera_node.global_transform.basis.get_euler().x, y_lerp * _delta);
		rotation.y = lerp_angle(rotation.y, camera_node.global_transform.basis.get_euler().y, x_lerp * _delta);
	else:
		rotation = camera_node.global_transform.basis.get_euler();

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			var anim = arsenal.values()[current].anim
			
			if not anim.is_playing():
				if event.keycode == KEY_1:
					current = 0;
				if event.keycode == KEY_2:
					current = 1;
				if event.keycode == KEY_3:
					current = 2;
