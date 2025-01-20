extends Spatial
class_name Weapons

const Y_LERP: float = 20.0
const X_LERP: float = 40.0

# Get character
onready var character: MovementPlayer = get_parent()

# Get head
onready var head: RayCast = get_node("%head")

# Get camera
#onready var neck: Spatial = get_node("%head/neck")

# Get camera
onready var camera: CharacterCamera = get_node("%head/neck/camera")

# Load weapon class for make weapons
var weapon = load("res://data/scripts/weapon/weapon.gd")

# All weapons
var arsenal: Dictionary = {}

# Current weapon
var current: int = 0

# Dict of inputs
var input_shoot: int  = 0
var input_reload: int = 0
var input_zoom: int   = 0


func get_camera() -> CharacterCamera:
	return camera


func get_character() -> MovementPlayer:
	return character


func _ready() -> void:
	set_as_toplevel(true)

	# Class reference : 
	# owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed

	# Create mk 23 using weapon classs
	arsenal["mk_23"] = weapon.Weapon.new(self, "mk_23", 2.0, 12, 999, 12, 40, 1.2)

	# Create glock 17 using weapon class
	arsenal["glock_17"] = weapon.Weapon.new(self, "glock_17", 3.0, 12, 999, 12, 35, 1.2)

	# Create kriss using weapon class
	arsenal["kriss"] = weapon.Weapon.new(self, "kriss", 6.0, 32, 999, 33, 25, 1.5)

	for w in arsenal:
		arsenal.values()[current]._hide()


func _physics_process(delta: float) -> void:
	# Call weapon function
	_weapon(delta)
	_change()
	_position(delta)


func _weapon(delta: float) -> void:
	input_shoot = int(Input.is_action_pressed("mb_left"))
	input_reload = int(Input.is_action_pressed("KEY_R"))
	input_zoom = int(Input.is_action_pressed("mb_right"))

	var current_arsenal = arsenal.values()[current]

	current_arsenal._sprint(character.input_sprint or character.input_jump, delta)

	if not character.input_sprint or not character.direction:
		if input_shoot:
			current_arsenal._shoot(delta)
		
		current_arsenal._zoom(input_zoom, delta)

	if input_reload:
		current_arsenal._reload()

	# Update arsenal
	for w in range(arsenal.size()):
		arsenal.values()[w]._update(delta)


func _change() -> void:
	# change weapons
	for w in range(arsenal.size()):
		if arsenal.values()[w] != arsenal.values()[current]:
			arsenal.values()[w]._hide()
		else:
			arsenal.values()[w]._draw()


func _position(delta: float) -> void:
	global_transform.origin = head.global_transform.origin
	
	if not input_zoom:
		var euler = camera.global_transform.basis.get_euler()
		rotation.x = lerp_angle(rotation.x, euler.x, Y_LERP * delta)
		rotation.y = lerp_angle(rotation.y, euler.y, X_LERP * delta)
	else:
		rotation = camera.global_transform.basis.get_euler()


func _unhandled_input(event) -> void:
	if event is InputEventKey and event.pressed:
		var anim: AnimationPlayer = arsenal.values()[current].anim

		if not anim.is_playing():
			if event.scancode == KEY_1:
				current = 0
			elif event.scancode == KEY_2:
				current = 1
			elif event.scancode == KEY_3:
				current = 2
