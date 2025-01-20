extends Spatial


export var speed : float = 200


func _ready() -> void:
	var mesh: MeshInstance = $mesh
	var timer: Timer = $timer

	mesh.translation.z = -mesh.mesh.mid_height/2;
	timer.connect("timeout", self, "queue_free");


func _process(delta: float) -> void:
	translation -= (global_transform.basis.z * speed) * delta;
