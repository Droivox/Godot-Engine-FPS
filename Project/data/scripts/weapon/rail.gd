extends Spatial

var speed : float = 200;
export(NodePath) var timer;

func _ready() -> void:
	$mesh.translation.z = -$mesh.mesh.mid_height/2;
	timer = get_node(timer);
	timer.connect("timeout", self, "queue_free");

func _process(_delta) -> void:
	translation -= (global_transform.basis.z * speed) * _delta;
