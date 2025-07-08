extends Node3D

@export var ray: NodePath;
var ray_node: Node;

var ground : bool = false;

func _ready():
	if ray != NodePath():
		ray_node = get_node(ray);
	
func _process(delta):
	if not ray_node:
		return
		
	if not ground:
		if ray_node.is_colliding():
			$mesh.global_transform.origin = ray_node.get_collision_point() + Vector3(0, 0.1, 0);
			ground = false;
