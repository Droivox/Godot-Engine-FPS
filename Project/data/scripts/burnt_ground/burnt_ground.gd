extends Spatial


var ground: bool = false
var base: Vector3 = Vector3(0.0, 0.1, 0.0)

onready var mesh: MeshInstance = $mesh
onready var ray: RayCast = $ray


#func _process(_delta: float) -> void:
func _physics_process(_delta: float) -> void:
	if not ground and ray.is_colliding():
		mesh.global_transform.origin = ray.get_collision_point() + base
		ground = false
