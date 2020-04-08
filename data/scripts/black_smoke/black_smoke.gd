extends Spatial

export(NodePath) var ray;

func _ready():
	ray = get_node(ray);
	
	ray.force_raycast_update();
	
func _process(delta):
	if ray.is_colliding():
		$mesh.global_transform.origin = ray.get_collision_point() + Vector3(0, 0.1, 0);
