extends Node3D

@export var feet: NodePath;
@export var character: NodePath;

var feet_node: Node;
var character_node: Node;

var footsteep_timer : float = 0;
var footsteep_speed : float = 0.5;
var footsteep_list : Dictionary = {};

var dont_repeat : int = 0;

func _ready() -> void:
	randomize();
	
	if feet != NodePath():
		feet_node = get_node(feet);
	if character != NodePath():
		character_node = get_node(character);
	
	for audio in get_child_count():
		footsteep_list[get_child(audio).name] = get_child(audio);

func _process(_delta) -> void:
	if not feet_node or not character_node:
		return
		
	if footsteep_timer <= 0:
		if character_node.direction:
			if feet_node.is_colliding():
				var collider = feet_node.get_collider();
				var groups = collider.get_groups();
				
				for g in groups:
					if footsteep_list.has(g):
						var footsteep_node = footsteep_list[g];
						
						if footsteep_node.get_child_count() > 0:
							var audio = randi() % footsteep_node.get_child_count();
							
							footsteep_node.get_child(audio).play();
							
							footsteep_timer = 1 - (0.06 * character_node.n_speed);
							break
	else:
		footsteep_timer -= _delta;
