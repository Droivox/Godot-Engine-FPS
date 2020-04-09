extends Spatial

# Get character node path
export(NodePath) var character;

# Get head node path
export(NodePath) var head;

# Get camera node path
export(NodePath) var camera;

# Load weapon class for make weapons
var weapon = load("res://data/scripts/weapon/weapon.gd");

# All weapons
var arsenal : Dictionary;

# Current weapon
var current : int = 1;

# Dict of inputs
var input : Dictionary = {};

func _ready() -> void:
	set_as_toplevel(true);
	
	# Get camera node from path
	camera = get_node(camera);
	
	# Get head node from path
	head = get_node(head);
	
	# Get head node from path
	character = get_node(character);
	
	# Create mk 23 using weapon class
	arsenal["mk_23"] = weapon.weapon.new(self, "mk_23", 2.0, 12, 999, 12);
	
	# Create glock 17 using weapon class
	arsenal["glock_17"] = weapon.weapon.new(self, "glock_17", 3.0, 12, 999, 12);
	
	# Create kriss using weapon class
	arsenal["kriss"] = weapon.weapon.new(self, "kriss", 6.0, 32, 999, 33);

func _process(_delta) -> void:
	# Call weapon function
	_weapon(_delta);
	_change();
	_position(_delta);

func _weapon(_delta) -> void:
	input["shoot"] = int(Input.is_action_pressed("mb_left"));
	input["reload"] = int(Input.is_action_pressed("KEY_R"));
	input["zoom"] = int(Input.is_action_pressed("mb_right"));
	
	arsenal.values()[current]._sprint(character.input["run"] or character.input["jump"], _delta);
	
	if not character.input["run"] or not character.direction:
		if input["shoot"]:
			arsenal.values()[current]._shoot();
		
		arsenal.values()[current]._zoom(input["zoom"], _delta);
	
	if input["reload"]:
		arsenal.values()[current]._reload();
	
	# Update current weapon
	arsenal.values()[current]._update(_delta);

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
	
	global_transform.origin = head.global_transform.origin;
	
	if not input["zoom"]:
		rotation.x = lerp_angle(rotation.x, camera.global_transform.basis.get_euler().x, y_lerp * _delta);
		rotation.y = lerp_angle(rotation.y, camera.global_transform.basis.get_euler().y, x_lerp * _delta);
	else:
		rotation = camera.global_transform.basis.get_euler();

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			var anim = arsenal.values()[current].anim
			
			if not anim.is_playing():
				if event.scancode == KEY_1:
					current = 0;
				if event.scancode == KEY_2:
					current = 1;
				if event.scancode == KEY_3:
					current = 2;
