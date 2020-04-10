extends Spatial

export(NodePath) var ray;

var ground : bool = false;

func _ready():
	ray = get_node(ray);
	
func _process(delta):
	if not ground:
		if ray.is_colliding():
			$mesh.global_transform.origin = ray.get_collision_point() + Vector3(0, 0.1, 0);
			ground = false;
